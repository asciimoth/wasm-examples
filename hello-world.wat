(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write 
    (param i32)
    (param i32)
    (param i32)
    (param i32)
    (result i32)
  ))
  (memory (export "memory") 1)
  (data (i32.const 0) "Hello world!\n")
  (func $main (export "_start")
    (i32.store (i32.const 15) (i32.const 0))
    (i32.store (i32.const 19) (i32.const 14))

    (i32.const 1)
    (i32.const 15)
    (i32.const 1)
    (i32.const 42)

    (call $fd_write)

    call $exit
  )
)