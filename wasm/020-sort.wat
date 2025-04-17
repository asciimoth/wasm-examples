;; TODO: Add mor sorting algos
(module
    (import "import" "memory" (memory 1 2))

    (type $sortType (func (param i32 i32 i32)))
    (type $compType (func (param i32 i32) (result i32)))

    (table (export "table") 4 funcref)
    (elem (i32.const 0) func $bubble)
    (elem (i32.const 1) func $selection)
    (elem (i32.const 2) func $i32min)
    (elem (i32.const 3) func $i32max)

    (func $i32min (param i32 i32) (result i32)
        (if (i32.lt_u (local.get 1) (local.get 0))
            (then (return (local.get 1)))
        )
        local.get 0
    )

    (func $i32max (param i32 i32) (result i32)
        (if (i32.lt_u (local.get 0) (local.get 1))
            (then (return (local.get 1)))
        )
        local.get 0
    )

    (func $swap (param i32 i32)
        (local $a i32)
        (local $b i32)
        (local.set $a (i32.load (local.get 0)))
        (local.set $b (i32.load (local.get 1)))
        (i32.store (local.get 0) (local.get $b))
        (i32.store (local.get 1) (local.get $a))
    )

    (func $findMinMaxAddr
        (param $from i32) (param $to i32) (param $comparator i32) (result i32)
        (local $best i32)
        (local $addr i32)
        (local.set $best (i32.load (local.get $from)))
        (local.set $addr (local.get $from))
        (loop $loop
            (if
                (i32.ne
                    (local.get $best)
                    (call_indirect
                        (type $compType)
                        (i32.load (local.get $from)) (local.get $best)
                        (local.get $comparator)
                    )
                )
                (then
                    (local.set $best (i32.load (local.get $from)))
                    (local.set $addr (local.get $from))
                )
            )
            ;;
            (local.set $from (i32.add (local.get $from) (i32.const 4)))
            (br_if $loop (i32.lt_u (local.get $from) (local.get $to)))
        )
        local.get $addr
    )

    (func $bubble
        (param $from i32) (param $count i32) (param $comparator i32)
        (local $pointer i32)
        (local $pointer1 i32)
        (local $cur i32)
        (local $next i32)
        (local $to i32)
        (local $continue i32)
        (local.set $to (i32.mul (local.get $count) (i32.const 4)))
        (loop $loop
            (local.set $continue (i32.const 0))
            (local.set $pointer (local.get $from))
            (loop $pass
                (local.set $pointer1 (call $i32min
                        (i32.add (local.get $pointer) (i32.const 4))
                        (i32.sub (local.get $to) (i32.const 4))
                ))
                (local.set $cur (i32.load (local.get $pointer)))
                (local.set $next (i32.load (local.get $pointer1)))
                (if
                    (i32.ne
                        (local.get $cur)
                        (call_indirect
                            (type $compType)
                            (local.get $cur) (local.get $next)
                            (local.get $comparator)
                        )
                    )
                    (then
                        ;; Swap
                        (call $swap (local.get $pointer) (local.get $pointer1))
                        (local.set $continue (i32.const 1))
                    )
                )
                (local.set $pointer (i32.add (local.get $pointer) (i32.const 4)))
                (br_if $pass (i32.lt_u (local.get $pointer) (local.get $to)))
            )
            (br_if $loop (local.get $continue))
        )
    )

    (func $selection
        (param $from i32) (param $count i32) (param $comparator i32)
        (local $to i32)
        (local.set $to (i32.mul (local.get $count) (i32.const 4)))
        (loop $loop
            (call $swap
                (local.get $from)
                (call $findMinMaxAddr
                    (local.get $from) (local.get $to) (local.get $comparator)
                )
            )
            (local.set $from (i32.add (local.get $from) (i32.const 4)))
            (br_if $loop (i32.lt_u (local.get $from) (local.get $to)))
        )
    )

    (func $sort (export "sort")
        (param $algo i32) (param $comparator i32)
        (param $from i32) (param $count i32)
        (call_indirect
            (type $sortType)
            (local.get $from) (local.get $count) (local.get $comparator)
            (local.get $algo)
        )
    )
)
