(module
  ;; Main thing WASM module contatin is funtions
  (func $nothing
    ;; Nop opreration do literally nothing
    nop
    ;; You can repeat it any times anywhere and only thing changed is size of your code
    nop
    nop
    nop
    nop
  )
  ;; Function may be explicitly export to become callable from outer world
  (export "doNothing" (func $nothing))
)