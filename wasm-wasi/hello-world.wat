;; Compile: wat2wasm hello-world.wat
;; Run:     wasmer run hello-world.wasm
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write 
    (param i32) ;; descriptor
    (param i32) ;; iovec array pointer
    (param i32) ;; number of iovec entries
    (param i32) ;; where to write number of bytes written
    (result i32) ;; Operation status; zero - ok, non zero - err
  ))
  (memory (export "memory") 1)
  ;; Put text in memory at 0 offset
  (data (i32.const 0) "Hello world!\n")
  (;
    Techincally this code is not correct.
    In real world fd_write may not be able to write whole buffer to file at a single try.
    So *real* code should call fd_write in loop, untill all data is wrtitten.
    But "Hello world!\n" string is short enouth to be fully written with one call in almost all cases.
  ;)
  (func $main (export "_start")
    ;; Set up iovec structure with offset 13
    ;; - iov_base offset 0 (13+0)
    ;; - iov_len offset 4 (13+4)
    (i32.store (i32.const 15) (i32.const 0))  ;; buffer start
    (i32.store (i32.const 19) (i32.const 14)) ;; buffer length

    ;; Putting args for fd_write on stack
    (i32.const 1)  ;; stdout
    (i32.const 15) ;; iovec array at addr 13
    (i32.const 1)  ;; number of iovec entries
    (i32.const 42) ;; addr to write number of bytes written; 42 - unused adress for now

    (call $fd_write)

    ;; fd_write returns one number - error/success
    ;; just "return" it from program
    call $exit
  )
)