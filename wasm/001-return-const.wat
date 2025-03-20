(module
  (func $constDecimal (result i32)
    ;; There is no explicit return operation in wasm
    ;; All data leaved on stack of function at it's execution end is it's ret value
    ;; Y.const X - put value X of type Y  on stack
    i32.const 42 ;; put 42 on stack
    ;; You can also add underscores in numbers for readability: 1_000_000
  )
  (func $constHex (result i32)
    ;; You can also write numbers in hecadecimal format
    i32.const -0x2A
  )
  (export "constDecimal" (func $constDecimal))
  (export "constHex" (func $constHex))
)
