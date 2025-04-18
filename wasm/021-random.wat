;; Check also https://github.com/cristian-5/pcg-random-wasm
;; TODO: Add mo algos
(module
    ;; XorShift algo for 32-bit numbers
    (func $xor32 (export "xor32") (param $inp i32) (result i32)
        ;; inp = inp xor (inp << 13)
        (local.set $inp (i32.xor (local.get $inp) (i32.shl (local.get $inp) (i32.const 13))))
        ;; inp = inp xor (inp >> 17)
        (local.set $inp (i32.xor (local.get $inp) (i32.shr_u (local.get $inp) (i32.const 17))))
        ;; return inp xor (inp << 5)
        (i32.xor (local.get $inp) (i32.shl (local.get $inp) (i32.const 5)))
    )
)
