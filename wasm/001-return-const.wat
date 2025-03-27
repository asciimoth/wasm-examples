(module
  (func $constDecimal (result i32)
    ;; There is no explicit return operation in wasm
    ;; All data left on stack of a function at its execution end is its ret value
    ;; Y.const X - puts value X of type Y on stack
    i32.const 42 ;; puts 42 on stack
    ;; You can also add underscores in numbers for readability: 1_000_000
  )
  (func $constHex (result i32)
    ;; You can also write numbers in hexadecimal format
    i32.const -0x2A
  )
  (export "constDecimal" (func $constDecimal))
  (export "constHex" (func $constHex))
)
