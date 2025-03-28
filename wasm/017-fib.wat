(module
    (memory (export "mem") 1)

    (func $fib (param $offset i32) (param $count i32)
        (if (i32.eqz (local.get $count)) (then return))
        (i32.store (local.get $offset) (i32.add
            (i32.load (i32.sub (local.get $offset) (i32.const 4)))
            (i32.load (i32.sub (local.get $offset) (i32.const 8)))
        ))
        (call $fib
            (i32.add (local.get $offset) (i32.const 4))
            (i32.sub (local.get $count) (i32.const 1))
        )
    )

    (func (export "fib") (param $offset i32) (param $count i32)
        (if (i32.gt_u (local.get $count) (i32.const 0)) (then
            (i32.store (local.get $offset) (i32.const 0))
            (local.set $count (i32.sub (local.get $count) (i32.const 1)))
            (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
        ))
        (if (i32.gt_u (local.get $count) (i32.const 0)) (then
            (i32.store (local.get $offset) (i32.const 1))
            (local.set $count (i32.sub (local.get $count) (i32.const 1)))
            (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
        ))
        (call $fib (local.get $offset) (local.get $count))
    )
)
