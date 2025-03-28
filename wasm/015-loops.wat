(module
    (import "import" "addResult" (func $addResult (param i32)))
    (memory (export "mem") 1)
    (data (i32.const 200) "HelloWorld!")

    (func (export "countup") (param $start i32) (param $count i32)
        ;; Loops in wasm works quite specifically
        ;; There is no classical loop with pre-condition or post-condition
        ;; All you have is a contructions that denotes block of code
        ;; And you should explicitly rerun it with specific operations if you
        ;; need
        ;; First of such contructions is `loop`
        ;; Despite its name the content of `loop` executed only once
        ;; unless additional instructions are called
        (loop $loop
            (call $addResult (local.get $start))
            (local.set $start (i32.add (local.get $start) (i32.const 1)))
            (local.set $count (i32.add (local.get $count) (i32.const -1)))
            ;; `br` (branch) intruction and its siblings is equivalent of
            ;; continue in typical language.
            ;; `br_if`, as you may guess, rerun loop if some condition is true
            (br_if $loop (i32.gt_s (local.get $count) (i32.const 0)))
            ;; You must explicitly specify loop that you want to rerun cause
            ;; there may be multiple nested loops
        )
    )

    (func (export "coundown") (param $start i32) (param $count i32)
        (loop $loop
            ;; `block` works like `loop` but br called for block works like
            ;; break instead of continue
            (block $exit
                (call $addResult (local.get $start))
                (local.set $start (i32.add (local.get $start) (i32.const -1)))
                (local.set $count (i32.add (local.get $count) (i32.const -1)))
                ;; Conditional break
                (br_if $exit (i32.eqz (local.get $count)))
                ;; Unconditional continue
                (br $loop)
            )
        )
    )

    ;; This is how memory was handled before the memory.copy and memory.fill
    ;; instructions were added
    ;; And it is good example of loops usage
    (func (export "memCopy")
        (param $offsetSrc i32) (param $offsetDst i32) (param $size i32)
        ;; Early return if $size == 0
        (if (i32.eqz (local.get $size)) (then return))
        ;; Early return if $offsetDst == offsetSrc
        (if (i32.eq (local.get $offsetDst) (local.get $offsetSrc)) (then return))
        ;; Check if destination address is before or after source address
        (if (i32.lt_u (local.get $offsetDst) (local.get $offsetSrc))
            (then
                ;; Forward copy; dest < src
                (block $exit
                    (loop $copy
                        ;; Finish if there is no remaining bytes to copy
                        (if (i32.eqz (local.get $size)) (then (br $exit)))
                        ;; Copy single byte
                        (i32.store8 (local.get $offsetDst) (i32.load8_u (local.get $offsetSrc)))
                        ;; Increment $offsetSrc and $offsetDst
                        (local.set $offsetSrc (i32.add (local.get $offsetSrc) (i32.const 1)))
                        (local.set $offsetDst (i32.add (local.get $offsetDst) (i32.const 1)))
                        ;; Decrement size
                        (local.set $size (i32.sub (local.get $size) (i32.const 1)))
                        ;; Continue
                        (br $copy)
                    )
                )
            )
            (else
                ;; Backward copy; dest >= src
                ;; Adjust pointers to the end of the segments
                (local.set $offsetSrc (i32.add (local.get $offsetSrc) (local.get $size)))
                (local.set $offsetDst (i32.add (local.get $offsetDst) (local.get $size)))
                (block $exit
                    (loop $copy
                        ;; Finish if there is no remaining bytes to copy
                        (if (i32.eqz (local.get $size)) (then (br $exit)))
                        ;; Decrement $offsetSrc and $offsetDst
                        (local.set $offsetSrc (i32.sub (local.get $offsetSrc) (i32.const 1)))
                        (local.set $offsetDst (i32.sub (local.get $offsetDst) (i32.const 1)))
                        ;;Copy single byte
                        (i32.store8 (local.get $offsetDst) (i32.load8_u (local.get $offsetSrc)))
                        ;; Decrement size
                        (local.set $size (i32.sub (local.get $size) (i32.const 1)))
                        ;; Continue
                        (br $copy)
                    )
                )
            )
        )
    )

    (func (export "memFill") (param $start i32) (param $count i32) (param $value i32)
        ;; We'll use $start as current pointer
        (local $end i32)
        ;; Early return if $cout == 0
        (if (i32.eqz (local.get $count)) (then return))
        (local.set $end (i32.add (local.get $start) (local.get $count)))
        (loop $loop
            local.get $start
            local.get $value
            i32.store8
            ;; Increment
            (local.set $start (i32.add (local.get $start) (i32.const 1)))
            ;; Continue if $start != $end
            (br_if $loop (i32.ne (local.get $start) (local.get $end)))
        )
    )
)
