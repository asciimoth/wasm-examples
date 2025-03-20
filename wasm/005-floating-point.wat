;; There are two floating point types in  wasm: f32 and f64
;; Both are signed (ofc)
;; Both are corresponds to IEEE 754
;;   https://ieeexplore.ieee.org/document/8766229

;; All examples in this file works same for f32

;; If you feel confused about floats math and its quirks, check this:
;; https://matloka.com/blog/floating-point-101
(module
  ;; const ops work same for floating numbers as for integers
  (func (export "constDec") (result f64)
    f64.const 42.42
  )
  (func (export "constHex") (result f64)
    f64.const -0x2A.6B851EB851EB851EB852
  )
  (func (export "constDecExpoent") (result f64)
    f64.const 42_000.5e-3
  )
  (func (export "constInf") (result f64)
    f64.const inf
  )
  (func (export "constNeInf") (result f64)
    f64.const -inf
  )
  (func (export "constNaN") (result f64)
    f64.const -nan:0x1234
    ;; You can include arbitrary payload data into IEEE 754 NaN floats
    ;; There are some smart hacks using this known in industry
  )

  (func (export "add") (param f64 f64) (result f64)
    (f64.add (local.get 0) (local.get 1))
  )

  (func (export "sub") (param f64 f64) (result f64)
    (f64.sub (local.get 0) (local.get 1))
  )

  (func (export "mul") (param f64 f64) (result f64)
    (f64.mul (local.get 0) (local.get 1))
  )

  (func (export "div") (param f64 f64) (result f64)
    (f64.div (local.get 0) (local.get 1))
  )

  (func (export "abs") (param f64) (result f64)
    (f64.abs (local.get 0))
  )

  (func (export "neg") (param f64) (result f64)
    (f64.neg (local.get 0))
  )

  (func (export "ceil") (param f64) (result f64)
    (f64.ceil (local.get 0))
  )

  (func (export "floor") (param f64) (result f64)
    (f64.floor (local.get 0))
  )

  (func (export "nearest") (param f64) (result f64)
    (f64.nearest (local.get 0))
  )

  (func (export "trunc") (param f64) (result f64)
    (f64.trunc (local.get 0))
  )

  (func (export "sqrt") (param f64) (result f64)
    (f64.sqrt (local.get 0))
  )

  (func (export "min") (param f64 f64) (result f64)
    (f64.min (local.get 0) (local.get 1))
  )

  (func (export "max") (param f64 f64) (result f64)
    (f64.max (local.get 0) (local.get 1))
  )

  (func (export "copysign") (param f64 f64) (result f64)
    ;; copysign A B - copy sign from B to A
    ;; copysign(4.2, 6.9) => 4.2
    ;; copysign(-4.2, 6.9) => 4.2
    ;; copysign(4.2, -6.9) => -4.2
    (f64.copysign (local.get 0) (local.get 1))
  )
)
