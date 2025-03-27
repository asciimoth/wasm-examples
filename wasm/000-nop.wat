(module
  ;; The main thing that WASM module contains is functions
  (func $nothing
    ;; Nop operation does literally nothing
    nop
    ;; You can repeat it any times anywhere and only thing changed is size of your code
    nop
    nop
    nop
    nop
    ;; If you are curious why no op exists, check rationale:
    ;; https://github.com/WebAssembly/design/blob/main/Rationale.md#nop
  )

  ;; Function may be exported explicitly to become callable from outer world
  (export "doNothing" (func $nothing))
)