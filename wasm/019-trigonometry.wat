;; This implemetation use Taylor series method and trying to be human-redable
;; For size-optimized implementation check: https://gist.github.com/going-digital/02e46c44d89237c07bc99cd440ebfa43
;; TODO: Add log
;; TODO: Add exp
(module
    (memory 1)
    (global $factTableOffset i32 (i32.const 0))
    (global $maxFact f64 (f64.const 18))
    (global $taylorCount i32 (i32.const 7))
    (global $PI f64 (f64.const 3.14159265358979323846))
    (global $PI2 f64 (f64.const 6.28318530717958647692))
    (global $PI0.5 f64 (f64.const 1.57079632679489661923))
    (global $PI1.5 f64 (f64.const 4.71238898038468985769))

    ;; Power: $base^$exp
    (func $pow (export "pow") (param $base f64) (param $exp i32) (result f64)
        (local $result f64)  ;; accumulator for the result
        (local $a f64)       ;; copy of the base
        (local $e i32)       ;; copy of the exponent

        ;; Initialize variables
        (local.set $result (f64.const 1))
        (local.set $a (local.get $base))
        (local.set $e (local.get $exp))

        ;; If exponent is negative, invert the base and negate the exponent
        (if (i32.lt_s (local.get $e) (i32.const 0))
            (then
                (local.set $a (f64.div (f64.const 1) (local.get $a)))
                (local.set $e (i32.mul (local.get $e) (i32.const -1)))
            )
        )

        ;; Exponentiation by squaring
        (block $exit
            (loop $loop
                ;; Exit loop when exponent becomes zero
                (br_if $exit (i32.eq (local.get $e) (i32.const 0)))
                ;; If the current exponent is odd, multiply the accumulator by base
                (if (i32.eq (i32.and (local.get $e) (i32.const 1)) (i32.const 1))
                    (then
                        (local.set $result (f64.mul (local.get $result) (local.get $a)))
                    )
                )
                ;; Square the base
                (local.set $a (f64.mul (local.get $a) (local.get $a)))
                ;; Divide exponent by 2 (unsigned shift)
                (local.set $e (i32.shr_u (local.get $e) (i32.const 1)))
                (br $loop)
            )
        )
        (local.get $result)
    )

    (func $fillFactTable
        (local $offset i32)
        (local $val f64)
        (local $step f64)
        (local.set $offset (global.get $factTableOffset))
        (f64.store (local.get $offset) (f64.const 1))
        (local.set $offset (i32.add (local.get $offset) (i32.const 8)))
        (f64.store (local.get $offset) (f64.const 1))
        (local.set $val (f64.const 1))
        (local.set $step (f64.const 1))
        (loop $loop
            (local.set $offset (i32.add (local.get $offset) (i32.const 8)))
            (f64.store (local.get $offset) (local.tee $val
                (f64.mul
                    (local.get $val)
                    (local.tee $step (f64.add (local.get $step) (f64.const 1)))
                )
            ))
            (br_if $loop (f64.lt (local.get $step) (global.get $maxFact)))
        )
    )

    (func $fact (export "fact") (param $n i32) (result f64)
        (f64.load (i32.add (global.get $factTableOffset) (i32.mul (local.get $n) (i32.const 8))))
    )

    (func $radianNorm (export "radianNorm") (param $x f64) (result f64)
        ;; Check 0 >= $x <= 2PI
        (if (i32.and
            (f64.ge (local.get $x) (f64.const 0.0))
            (f64.le (local.get $x) (global.get $PI2)))
            ;; $x can be used as is
            (then (return (local.get $x)))
        )

        ;; Adjust $x to [0 2PI]
        (f64.sub (local.get $x) (f64.mul
            (global.get $PI2)
            (f64.floor (f64.div (local.get $x) (global.get $PI2)))
        ))
    )

    ;; sin(x) = x - (x^3)/3! + (x^5)/5! - (x^7)/7! + (x^9)/9! - ...
    (func $rawSin (param $x f64) (result f64)
        (local $result f64)
        (local $step i32)
        (local $stepResult f64)
        (local $stepBase i32)

        (local.set $result (local.get $x))
        (local.set $step (i32.const 1))

        ;; Loop for $step in [1 $taylorCount)
        (loop $taylor
            ;; Workout ($step * 2) + 1
            (local.set $stepBase (i32.add
                ;; $step * 2
                (i32.shl (local.get $step) (i32.const 1))
                (i32.const 1)
            ))

            ;; $stepResult = ($x^$stepBase)/$stepBase!
            (local.set $stepResult (f64.div
                ;; $x^$stepBase
                (call $pow (local.get $x)
                    (local.get $stepBase)
                )
                ;; $stepBase!
                (call $fact (local.get $stepBase))
            ))

            ;; If $step odd
            (if (i32.and (local.get $step) (i32.const 1))
                (then
                    ;; $result -= $stepResult
                    (local.set $result (f64.sub (local.get $result) (local.get $stepResult)))
                )
                (else
                    ;; $result += $stepResult
                    (local.set $result (f64.add (local.get $result) (local.get $stepResult)))
                )
            )

            ;; Increment $step
            ;; Continue if $step <= $taylorCount
            (br_if $taylor (i32.le_u
                (local.tee $step (i32.add (local.get $step) (i32.const 1)))
                (global.get $taylorCount)
            ))
        )

        local.get $result
    )

    ;; cos(x) = 1 + (x^2)/2! - (x^4)/4! + (x^6)/6! - (x^8)/8! + ...
    (func $rawCos (param $x f64) (result f64)
        (local $result f64)
        (local $step i32)
        (local $stepResult f64)
        (local $stepBase i32)

        (local.set $result (f64.const 1))
        (local.set $step (i32.const 1))

        ;; Loop for $step in [1 $taylorCount)
        (loop $taylor
            ;; Workout ($step * 2) + 1
            (local.set $stepBase
                ;; $step * 2
                (i32.shl (local.get $step) (i32.const 1))
            )

            ;; $stepResult = ($x^$stepBase)/$stepBase!
            (local.set $stepResult (f64.div
                ;; $x^$stepBase
                (call $pow (local.get $x)
                    (local.get $stepBase)
                )
                ;; $stepBase!
                (call $fact (local.get $stepBase))
            ))

            ;; If $step odd
            (if (i32.and (local.get $step) (i32.const 1))
                (then
                    ;; $result -= $stepResult
                    (local.set $result (f64.sub (local.get $result) (local.get $stepResult)))
                )
                (else
                    ;; $result += $stepResult
                    (local.set $result (f64.add (local.get $result) (local.get $stepResult)))
                )
            )

            ;; Increment $step
            ;; Continue if $step <= $taylorCount
            (br_if $taylor (i32.le_u
                (local.tee $step (i32.add (local.get $step) (i32.const 1)))
                (global.get $taylorCount)
            ))
        )

        local.get $result
    )

    (func $sin (export "sin") (param $x f64) (result f64)
        ;; Mod the radian angle (0 to 360 degrees)
        (local.set $x (call $radianNorm (local.get $x)))

        ;; If $x <= to PI*0.5 (90 degrees)
        (if (f64.le (local.get $x) (global.get $PI0.5))
            (then
                ;; Just return sin as is
                (return (call $rawSin (local.get $x)))
            )
        )

        ;; If $x <= PI (180 degrees)
        (if (f64.le (local.get $x) (global.get $PI))
            (then
                ;; Return cos($x - PI/2)
                (return (call $rawCos (f64.sub (local.get $x) (global.get $PI0.5))))
            )
        )

        ;; If $x <= PI*1.5 (270 degrees)
        (if (f64.le (local.get $x) (global.get $PI1.5))
            (then
                ;; sin($x - PI)*-1
                (return (f64.neg (call $rawSin (f64.sub (local.get $x) (global.get $PI)))))
            )
        )

        ;; $x < PI*2 (360 degrees)

        ;; cos($x - PI * 1.5)*-1
        (f64.neg (call $rawCos (f64.sub (local.get $x) (global.get $PI1.5))))
    )

    (func $cos (export "cos") (param $x f64) (result f64)
        ;; Mod the radian angle (0 to 360 degrees)
        (local.set $x (call $radianNorm (local.get $x)))

        ;; If $x <= to PI*0.5 (90 degrees)
        (if (f64.le (local.get $x) (global.get $PI0.5))
            (then
                ;; Just return cos as is
                (return (call $rawCos (local.get $x)))
            )
        )

        ;; If $x <= PI (180 degrees)
        (if (f64.le (local.get $x) (global.get $PI))
            (then
                ;; Return sin($x - PI/2)*-1
                (return (f64.neg (call $rawSin (f64.sub (local.get $x) (global.get $PI0.5)))))
            )
        )

        ;; If $x <= PI*1.5 (270 degrees)
        (if (f64.le (local.get $x) (global.get $PI1.5))
            (then
                ;; cos($x - PI)*-1
                (return (f64.neg (call $rawCos (f64.sub (local.get $x) (global.get $PI)))))
            )
        )

        ;; $x < PI*2 (360 degrees)

        ;; sin($x - PI * 1.5)
        (call $rawSin (f64.sub (local.get $x) (global.get $PI1.5)))
    )

    (start $fillFactTable)
)