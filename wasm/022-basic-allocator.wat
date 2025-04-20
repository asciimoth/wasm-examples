(;
    init
    inherit
    destroy
    alloc
    free
    realloc

    basic
    proxy
;)
(module
    (global $pageSize i32 (i32.const 65536))

    (memory (export "memory") 1)

    ;; If necessary, extends memory (memory.grow) so
    ;;   $addr comes to be within its limits
    (func $fitMemSize (export "fitMemSize") (param $addr i32) (result i32)
        (local.set $addr (i32.add (local.get $addr) (i32.eqz (local.get $addr))))
        (memory.grow
            (i32.sub
                (i32.add
                    (i32.div_u (local.get $addr) (global.get $pageSize))
                    (i32.eqz (i32.eqz (i32.rem_u
                        (local.get $addr) (global.get $pageSize)
                    )))
                )
                (memory.size)
            )
        )
    )

    (;
        defragment(point)
        free(point begin)
        realloc(point begin) -> newBegin
    ;)

    ;; Create allocator that owns memory slice from $begin to $end (exclusive)
    ;; Returns "pointer to allocator"
    ;; ($end-$begin) should be at least 10
    (func $init (export "init") (param $begin i32) (param $end i32) (result i32)
        ;; Fit memory
        (if (i32.eq
                (call $fitMemSize (i32.add (local.get $begin) (i32.const 9)))
                (i32.const -1)
            )
            ;; Error: faild to pre-allocate enouth memory
            (then unreachable)
        )
        ;; Save $end position
        (i32.store (local.get $begin) (local.get $end))
        ;; Mark all owned memory as free
        (i32.store8 (i32.add (local.get $begin) (i32.const 4)) (i32.const 0))
        (i32.store (i32.add (local.get $begin) (i32.const 5)) (local.get $end))
        ;; For basic allocator, its pointer is same for $begin
        local.get $begin
    )

    (func $getNextSegment (export "getNextSegment")
        (param $segment i32) (result i32)
        (i32.load (i32.add (local.get $segment) (i32.const 1)))
    )

    (func $getSegmentSize (export "getSegmentSize")
        (param $segment i32) (result i32)
        (i32.sub
            (i32.load (i32.add (local.get $segment) (i32.const 1)))
            (i32.add (local.get $segment) (i32.const 5))
        )
    )

    (func $isLastSegment (export "isLastSegment")
        (param $allocator i32) (param $segment i32) (result i32)
        (i32.ge_u
            (i32.load (i32.add (local.get $segment) (i32.const 1)))
            (i32.load (local.get $allocator))
        )
    )

    (func $isFree (export "isFree")
        (param $segment i32) (result i32)
        ;; 0 - free
        ;; 1 - in use
        (i32.eqz (i32.load8_u (local.get $segment)))
    )

    (func $markSegmentFree (export "markSegmentFree")
        (param $segment i32)
        (i32.store8 (local.get $segment) (i32.const 0))
    )

    (func $markSegmentUsed (export "markSegmentUsed")
        (param $segment i32)
        (i32.store8 (local.get $segment) (i32.const 1))
    )

    ;; Returns 1 if ok and 0 if failed
    (func $splitSegmentIfNeeded (export "splitSegmentIfNeeded")
        (param $segment i32) (param $size i32) (result i32)
        (local $segSize i32)
        (local $newSeg i32)
        (local.set $segSize (i32.sub
            (i32.load (i32.add (local.get $segment) (i32.const 1)))
            (i32.add (local.get $segment) (i32.const 5))
        ))
        ;; If $size > $segSize we have problems
        (if (i32.gt_u (local.get $size) (local.get $segSize))
            (then (return (i32.const 0)))
        )
        ;; And same if current segment is in use
        (if (i32.eqz (call $isFree (local.get $segment)))
            (then (return (i32.const 0)))
        )
        ;; If $segSize-$size is too small to be splitted, just return OK
        (if (i32.lt_u
                (i32.sub (local.get $segSize) (local.get $size))
                (i32.const 6)
            )
            (then (return (i32.const 1)))
        )
        (local.tee $newSeg (i32.add
            (i32.add (local.get $segment) (i32.const 5)) (local.get $size)
        ))
        (call $fitMemSize (i32.add (i32.const 5)))
        ;; Mark new segment as free
        (i32.store8 (i32.add (local.get $newSeg) (i32.const 4)) (i32.const 0))
        ;; "Connect" new segment with next segment
        (i32.store
            (i32.add (local.get $newSeg) (i32.const 1))
            (i32.load (i32.add (local.get $segment) (i32.const 1)))
        )
        (call $markSegmentFree (local.get $newSeg))
        ;; "Connect" current segment with new segment
        (i32.store
            (i32.add (local.get $segment) (i32.const 1))
            (local.get $newSeg)
        )
        (return (i32.const 1))
    )

    ;; Join segment with next one if possible
    ;; If it is last segment, do nothing
    ;; If this or next segment is in use, do nothing
    (func $joinSegments (export "joinSegments")
        (param $allocator i32) (param $segment i32)
        (if (call $isLastSegment (local.get $allocator) (local.get $segment))
            (then return)
        )
        (if (i32.eqz (call $isFree (local.get $segment))) (then return))
        (if
            (i32.eqz (call $isFree (call $getNextSegment (local.get $segment))))
            (then return)
        )
        (i32.store
            (i32.add (local.get $segment) (i32.const 1))
            (i32.load (i32.add
                (call $getNextSegment (local.get $segment))
                (i32.const 1)
            ))
        )
    )

    ;; first result - allocated slice pointer
    ;; second result - status code
    ;;   1 - ok
    ;;   0 - failed
    (func $alloc (export "alloc")
        (param $allocator i32) (param $size i32) (result i32 i32)
        (local $segment i32)
        (local.set $segment (i32.add (local.get $allocator) (i32.const 4)))
        (loop $loop
            (if
                (call $splitSegmentIfNeeded
                    (local.get $segment)
                    (local.get $size)
                )
                (then
                    (call $markSegmentUsed (local.get $segment))
                    (call $fitMemSize
                        (i32.add
                            (i32.add (local.get $segment) (i32.const 5))
                            (local.get $size)
                        )
                    )
                    (return
                        (i32.add (local.get $segment) (i32.const 5))
                        (i32.const 1)
                    )
                )
            )
            (if
                (call $isLastSegment
                    (local.get $allocator)
                    (local.get $segment)
                )
                (then (return (i32.const 0) (i32.const 0)))
            )
            (local.set $segment (call $getNextSegment (local.get $segment)))
            (br $loop)
        )
        (i32.const 0) (i32.const 0)
    )

    (func $defragment (param $allocator i32)
        (local $segment i32)
        (local.set $segment (i32.add (local.get $allocator) (i32.const 4)))
        (loop $loop
            (call $joinSegments
                (local.get $allocator) (local.get $segment)
            )
            (if
                (call $isLastSegment
                    (local.get $allocator)
                    (local.get $segment)
                )
                (then return)
            )
            (local.set $segment (call $getNextSegment (local.get $segment)))
            (br $loop)
        )
    )

    (func $free (export "free")
        (param $allocator i32) (param $segment i32)
        (call $markSegmentFree (i32.sub (local.get $segment) (i32.const 5)))
        (call $defragment (local.get $allocator))
    )

    (func $realloc (export "realloc")
        (param $allocator i32) (param $segment i32) (result i32)
        (local $size i32)
        (local $new i32)
        (local.set $size (call $getSegmentSize
            (i32.sub (local.get $segment) (i32.const 5))
        ))
        (call $alloc (local.get $allocator) (local.get $size) )
        ;; Failed to allocate new segment
        (if (i32.eqz)
            (then (return (local.get $segment)))
        )
        (local.set $new)
        (memory.copy
            (local.get $new) (local.get $segment) (local.get $size)
        )
        (call $free (local.get $allocator) (local.get $segment))
        (local.get $new)
    )
)
