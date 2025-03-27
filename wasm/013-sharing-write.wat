(module
    (import "import" "glob" (global $glob (mut i32)))
    ;; Whe should mark imported memory as "shared" to allow simultaneous access
    ;; from multiple modules.
    ;; Also shared memory must have max size
    (import "import" "mem" (memory 1 1 shared))

    (func (export "store") (param $offset i32) (param $value i32)
        ;; Place i32 $value in memory at $offset
        (i32.store (local.get $offset) (local.get $value))
    )

    (func (export "set") (param i32)
        local.get 0
        global.set $glob
    )
)