;; All examples in this file works same for i64
(module
  ;; Equal zero
  (func (export "eqzi32") (param i32) (result i32)
    ;; Return 1 if arg == 0 else 0
    ;; Nothing non ordinary
    (i32.eqz (local.get 0))
  )

  ;; Equal each  other
  (func (export "eqi32") (param i32 i32) (result i32)
    ;; Return 1 if arg0 == arg1 else 0
    (i32.eq (local.get 0) (local.get 1))
  )

  ;; NOT Equal each  other
  (func (export "nei32") (param i32 i32) (result i32)
    ;; Return 1 if arg0 == arg1 else 0
    (i32.ne (local.get 0) (local.get 1))
  )

  ;; Greater
  (func (export "gtsi32") (param i32 i32) (result i32)
    ;; Return 1 if arg0 > arg1 else 0
    (i32.gt_s (local.get 0) (local.get 1))
  )
  ;; Greater or equal
  (func (export "gesi32") (param i32 i32) (result i32)
    ;; Return 1 if arg0 >= arg1 else 0
    (i32.ge_s (local.get 0) (local.get 1))
  )

  ;; Less
  (func (export "ltsi32") (param i32 i32) (result i32)
    ;; Return 1 if arg0 < arg1 else 0
    (i32.lt_s (local.get 0) (local.get 1))
  )
  ;; Less  or eqal
  (func (export "lesi32") (param i32 i32) (result i32)
    ;; Return 1 if arg0 <= arg1 else 0
    (i32.le_s (local.get 0) (local.get 1))
  )
)
