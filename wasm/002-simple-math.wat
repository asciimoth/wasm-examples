;; All examples in this file works same for i64
(module
  ;; We can add export right into function definition instead of separate command
  (func (export "addi32") (param $a i32) (param $b i32) (result i32)
    local.get $a ;; Put (push) first arg on stack
    local.get $b ;; Put (push) second arg on stack
    i32.add ;; Grab (pop) two values from stack's top, put (push) back their summ
    ;; Note that integers in wasm (i32, i64) are not signed or unsigned by themselfs.
    ;; Their interpretation depends on individual operations.
    ;; For addition there is no matter if ints are signed or unsigned but for
    ;;   some other instructions (e.g. division) there are two variants for
    ;;   signed and unsigned calculations.
  )

  (func (export "subi32") (param $a i32) (param $b i32) (result i32)
    ;; We can also write all this as one expression.
    ;; It is same for:
    ;;   local.get $a
    ;;   local.get $b
    ;;   i32.sub
    (i32.sub (local.get $a) (local.get $b)) ;; a - b
    ;; Substraction also work same for signed and unsigned ints
  )

  (func (export "muli32") (param i32) (param i32) (result i32)
    ;; Names started with $ are just aliases for number IDs and you can use
    ;;   those IDs directly
    ;; Anyway all names repalce with IDs at compilation time
    (i32.mul (local.get 0) (local.get 1)) ;; firstArg * secondArg
  )

  ;; You can also enumerate all args in one param expression
  (func (export "divsi32") (param i32 i32) (result i32)
    ;; Division unlike addition, substraction and multiplication is aware about
    ;;   integers sign.
    ;; So there is two operations for i32 deivision:
    ;;   div_s - div two numbers treating them as signed 
    ;;   div_u - div two numbers treating them as unsigned
    ;; Here we show only signed example coz js anyway treat wasm functions args
    ;;   and return values as signed.
    ;; Thus div_u usage demostration will be problematic.
    ;; In future if you see any operation with _s or _u postfix, know that
    ;;   it has sibling with opposite one.
    (i32.div_s (local.get 0) (local.get 1)) ;; firstArg / secondArg
    ;; Also note that i32.div_s produce i32 integer value that can not store
    ;;   division remainder which is just lost. And result is rounded to floor.
    ;; To get remainder itself (a % b in C) there is i32.rem_s and i32.rem_u
  )
)