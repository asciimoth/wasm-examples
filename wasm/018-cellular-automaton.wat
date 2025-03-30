(module
    (;
                           offset  | data
                                 0 | colsCount
                                 4 | rowsCount
                                 8 | frameNom (0|1)
                                16 | ruleId
                                20 | frame1
            colsCount*rowsCount+20 | frame2
        (colsCount*rowsCount)*2+20 | output
    ;)

    (type $getCellType (func
        (param $c i32) (param $r i32) (param $a i32) (result i32))
    )
    (type $rule (func
        (param $c i32) (param $r i32) (param $a i32) 
        (param $getter i32) (result i32))
    )

    (import "import" "extGetCell" (func $extGetCell (type $getCellType)))

    ;; Directions
    (global $upLeft (export "upLeft") (mut i64)
        (i64.const 0xFFFFFFFF_FFFFFFFF))
    (global $up (export "up") (mut i64)
        (i64.const 0x00000000_FFFFFFFF))
    (global $upRight (export "upRight") (mut i64)
        (i64.const 0x00000001_FFFFFFFF))
    (global $right (export "right") (mut i64)
        (i64.const 0x00000001_00000000))
    (global $downRight (export "downRight") (mut i64)
        (i64.const 0x00000001_00000001))
    (global $down (export "down") (mut i64)
        (i64.const 0x00000000_00000001))
    (global $downLeft (export "downLeft") (mut i64)
        (i64.const 0xFFFFFFFF_00000001))
    (global $left (export "left") (mut i64)
        (i64.const 0xFFFFFFFF_00000000))

    (memory (export "mem") 1)

    (table (export "table") 3 funcref)
    (elem (i32.const 0) func $extGetCell)
    (elem (i32.const 1) func $getCell)
    (elem (i32.const 2) func $b3s23)

    (func $setStruct (export "setStruct")
        (param $offset i32) (param $cols i32) (param $rows i32)
        (param $frame i32) (param $rule i32)
        (i32.store (local.get $offset) (local.get $cols))
        (i32.store (i32.add (local.get $offset) (i32.const 4)) (local.get $rows))
        (i32.store (i32.add (local.get $offset) (i32.const 8)) (local.get $frame))
        (i32.store (i32.add (local.get $offset) (i32.const 16)) (local.get $rule))
    )

    (func $getCellPos (export "getCellPos")
        (param $c i32) (param $r i32) (param $a i32) (param $i i32) (result i32)
        (local $cols i32)
        (local $rows i32)
        ;; Get dimensions
        (local.tee $cols (i32.load (local.get $a)))
        (local.tee $rows (i32.load (i32.add (local.get $a) (i32.const 4))))
        ;; Get frameNom
        (if (result i32) (local.get $i)
            (then
                (i32.eqz
                    (i32.load (i32.add (local.get $a) (i32.const 8)))
                )
            )
            (else
                (i32.load (i32.add (local.get $a) (i32.const 8)))
            )
        )
        ;; Get current frame start offset
        (i32.mul) (i32.mul)
        (i32.const 20)
        (i32.add)
        ;; Calculate position
        (i32.add
            (i32.add
                (i32.mul (local.get $r) (local.get $cols))
                (local.get $c)
            )
            (local.get $a)
        )
        (i32.add)
    )

    ;; c r cols rows
    (func $isOutOfBounds (export "isOutOfBounds") (param i32 i32 i32) (result i32)
        (local $cols i32)
        (local $rows i32)
        ;; Get dimensions
        (local.set $cols (i32.load (local.get 2)))
        (local.set $rows (i32.load (i32.add (local.get 2) (i32.const 4))))
        ;; Check
        (i32.lt_s (local.get 0) (i32.const 0))
        (i32.lt_s (local.get 1) (i32.const 0))
        (i32.ge_s (local.get 0) (local.get $cols))
        (i32.ge_s (local.get 1) (local.get $rows))
        (i32.or) (i32.or) (i32.or)
    )

    (func $getCell (export "getCell") (type $getCellType)
        (if (call $isOutOfBounds
            (local.get 0) (local.get 1) (local.get 2))
            (then (return (i32.const 0)))
        )
        (i32.load8_u (call $getCellPos (local.get 0) (local.get 1) (local.get 2) (i32.const 0)))
    )

    (func $setCell (export "setCell") (param $c i32) (param $r i32) (param $a i32) (param $i i32) (param $v i32)
        (if (call $isOutOfBounds
            (local.get 0) (local.get 1) (local.get 2))
            (then return)
        )
        (i32.store8 (call $getCellPos (local.get $c) (local.get $r) (local.get $a) (local.get $i)) (local.get $v) )
    )

    (func $move (export "move") (param i32 i32 i64) (result i32 i32)
        (i32.add (local.get 0) (i32.wrap_i64 (i64.shr_u (local.get 2) (i64.const 32))))
        (i32.add (local.get 1) (i32.wrap_i64 (local.get 2)))
    )

    ;; 0 -> " "
    ;; 1 -> "#"
    (func $toChar (export "toChar") (param i32) (result i32)
        (i32.add (i32.const 32) (i32.mul (i32.const 11) (local.get 0)))
    )

    (func $render (export "render") (param i32) (result i32 i32)
        (local $cols i32)
        (local $rows i32)
        (local $tOff i32) ;; TextOffset
        (local $ctOff i32) ;; Current text offset
        (local $fOff i32) ;; FrameOffset
        (local $fEnd i32) ;; FrameEnd
        (local $inrow i32)
        ;; Get dimensions
        (local.tee $tOff (i32.add (local.get 0) (i32.add (i32.const 20) (i32.mul (i32.mul
            (local.tee $cols (i32.load (local.get 0)))
            (local.tee $rows (i32.load (i32.add (local.get 0) (i32.const 4))))
        ) (i32.const 2)))))
        (local.set $ctOff)
        (local.set $fOff (i32.add (i32.add (local.get 0) (i32.const 20)) (i32.mul (
            i32.load (i32.add (local.get 0) (i32.const 8))
        ) (
            i32.mul (local.get $cols) (local.get $rows)
        ))))
        (local.set $fEnd (i32.add (local.get $fOff)
            (i32.mul (local.get $cols) (local.get $rows))))
        (local.set $inrow (i32.const 0))
        (loop $loop
            (block $block
                (i32.store8 (local.get $ctOff)
                    (call $toChar (i32.load8_u (local.get $fOff)))
                )
                (local.set $ctOff (i32.add (local.get $ctOff) (i32.const 1)))
                (local.tee $fOff (i32.add (local.get $fOff) (i32.const 1)))
                (local.set $inrow (i32.add (local.get $inrow) (i32.const 1)))
                (if
                    (i32.eq (local.get $inrow) (local.get $cols))
                    (then
                        (i32.store8 (local.get $ctOff) (i32.const 10))
                        (local.set $ctOff (i32.add (local.get $ctOff) (i32.const 1)))
                        (local.set $inrow (i32.const 0))
                    )
                )
                (br_if $block (i32.eq (local.get $fEnd)))
                (br $loop)
            )
        )
        (local.get $tOff)
        (local.get $ctOff)
    )

    ;; Aka Conway's Game Of Life
    (func $b3s23 (export "b3s23") (type $rule)
        (local $count i32)
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $upLeft))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $up))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $upRight))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $right))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $downRight))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $down))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $downLeft))
            (local.get 2) (local.get 3)
        )
        (call_indirect (type $getCellType)
            (call $move (local.get 0) (local.get 1) (global.get $left))
            (local.get 2) (local.get 3)
        )
        (i32.add) (i32.add) (i32.add) (i32.add)
        (i32.add) (i32.add) (i32.add)
        (local.set $count)

        (if (result i32)
            (call_indirect (type $getCellType)
             (local.get 0) (local.get 1) (local.get 2) (local.get 3)
            )
            (then
                (i32.or
                    (i32.eq (local.get $count) (i32.const 2))
                    (i32.eq (local.get $count) (i32.const 3))
                )
            )
            (else
                (i32.eq (local.get $count) (i32.const 3))
            )
        )
    )

    (func $step (export "step") (param $inf i32)
        (local $cols i32)
        (local $rows i32)
        (local $col i32)
        (local $row i32)
        ;; Get dimensions
        (local.set $cols (i32.load (local.get $inf)))
        (local.set $rows (i32.load (i32.add (local.get $inf) (i32.const 4))))
        (local.set $row (i32.const 0))
        (loop $rloop
            (local.set $col (i32.const 0))
            (loop $cloop
                (call $setCell
                    (local.get $col)
                    (local.get $row)
                    (local.get $inf)
                    (i32.const 1)
                    (call_indirect (type $rule)
                        (local.get $col) (local.get $row)
                        (local.get $inf) (i32.const 1)
                        (i32.load (i32.add (local.get $inf) (i32.const 16)))
                    )
                )
                (local.set $col (i32.add (local.get $col) (i32.const 1)))
                (br_if $cloop (i32.lt_s (local.get $col) (local.get $cols)))
            )
            (local.set $row (i32.add (local.get $row) (i32.const 1)))
            (br_if $rloop (i32.lt_s (local.get $row) (local.get $rows)))
        )
        ;; Switch frameNom
        (i32.store
            (i32.add (local.get $inf) (i32.const 8))
            (i32.eqz (i32.load (i32.add (local.get $inf) (i32.const 8))))
        )
    )
)
