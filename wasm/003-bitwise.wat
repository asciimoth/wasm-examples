;; All examples in this file works same for i64

;; I HIGHLY RECOMMEND to take a look at tests (003-bitwise-test.js).
;; There are a lot of notes about bitwise math.
(module
  ;; Bitwiswe and gate
  (func (export "andi32") (param i32 i32) (result i32)
    (i32.and (local.get 0) (local.get 1))
  )

  ;; Bitwiswe or gate
  (func (export "ori32") (param i32 i32) (result i32)
    (i32.or (local.get 0) (local.get 1))
  )

  ;; Bitwiswe xor gate
  (func (export "xori32") (param i32 i32) (result i32)
    (i32.xor (local.get 0) (local.get 1))
  )

  ;; Shift left
  (func (export "shli32") (param i32 i32) (result i32)
    (i32.shl (local.get 0) (local.get 1)) ;; Shift arg0 to left arg1 times
  )

  ;; Shift right unsigned
  (func (export "shrui32") (param i32 i32) (result i32)
    (i32.shr_u (local.get 0) (local.get 1))
  )
  ;; Shift right signed
  (func (export "shrsi32") (param i32 i32) (result i32)
    (i32.shr_s (local.get 0) (local.get 1))
  )

  ;; Rotate left
  (func (export "rotli32") (param i32 i32) (result i32)
    (i32.rotl (local.get 0) (local.get 1))
  )

  ;; Rotate right
  (func (export "rotri32") (param i32 i32) (result i32)
    (i32.rotr (local.get 0) (local.get 1))
  )

  ;; Count leading zeros
  (func (export "clzi32") (param i32) (result i32)
    (i32.clz (local.get 0))
  )

  ;; Count traling zeros
  (func (export "ctzi32") (param i32) (result i32)
    (i32.ctz (local.get 0))
  )

  ;; Pops count
  (func (export "popcnti32") (param i32) (result i32)
    (i32.popcnt (local.get 0))
  )
)
