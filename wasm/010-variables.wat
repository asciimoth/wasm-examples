(module
    ;; Globals must have init value
    (global $global1 (mut i32) (i32.const 101))
    ;; Globals can be exported just like the functions
    (global $global2 (export "glob2") (mut i32) (i32.const 404))

    (func (export "g1set") (param i32)
        local.get 0
        global.set $global1
    )
    (func (export "g1get") (result i32)
        global.get $global1
    )
    (func (export "g2set") (param i32)
        local.get 0
        global.set $global2
    )

    (func (export "select") (param i32) (result i32)
        global.get $global1
        global.get $global2
        local.get 0
        select
    )

    (func (export "mul") (param i32 i32 i32) (result i32)
        ;; Function params are local variables (as you know from prev examples)
        ;; But you can also create any amount of additional function-local vars
        ;; of any type (i32, i64, f32, f64, v128)
        (local $somename i32)
        local.get 0
        local.set $somename
        local.get 1
        local.get 2
        i32.mul
        local.get $somename
        i32.mul
    )
)
