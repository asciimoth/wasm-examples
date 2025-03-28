;; Example compiles only with --enable-threads flag
(module
    (import "import" "glob" (global $glob (mut i32)))
    ;; We should mark imported memory as "shared" to allow simultaneous access
    ;; from multiple modules
    ;; Also the shared memory must have a max size
    (import "import" "mem" (memory 1 1 shared))

    (func (export "load") (param $offset i32) (result i32)
        ;; Load i32 value from memory at $offset
        (i32.load (local.get $offset))
    )

    (func (export "get") (result i32)
        global.get $glob
    )
)