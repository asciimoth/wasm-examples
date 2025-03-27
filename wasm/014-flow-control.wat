(module
    (import "import" "setResult" (func $setResult (param i32)))

    (func (export "resultIf") (param i32)
        local.get 0
        ;; `if` operation pops i32 element from stack and execute code block
        ;; untill `end` if element was non zero.
        if
            i32.const 42
            call $setResult
        end

        ;; You can also use S-expressions and `then` keyword to achive more
        ;; "familiar" syntax.
        ;; param xor 0xFFFFFFFF is same for !param
        (if (i32.xor (local.get 0) (i32.const 0xFFFFFFFF))
            (then
                i32.const 69
                call $setResult
            )
        )

        ;; There is of course `else` available too.
        (if (local.get 0)
            (then
                i32.const 314
                call $setResult
            )
            (else
                i32.const 271
                call $setResult
            )
        )
    )

    (func (export "returnIf") (param i32) (result i32)
        ;; This code looks normal, but it fails at compile time.
        ;; Thats because all if-else constructions in wasm should be balanced
        ;; which means for each `if` branch that alters stack there must be
        ;; else branch that alters it same way (psuh/pop same count of elements
        ;; of same types).
        ;; Thats why in `resultIf` function we was returning results via
        ;; setResult function call which was leaving stack in same state that
        ;; was before `if`.
        ;; local.get 0
        ;; if
        ;;     i32.const 42
        ;; end
        ;; (i32.xor (local.get 0) (i32.const 0xFFFFFFFF))
        ;; if
        ;;     i32.const 69
        ;; end

        ;; This code is fully balanced because both branches push one i32 value.
        (if (result i32) (local.get 0)
            (then
                i32.const 42
            )
            (else
                i32.const 69
            )
        )
    )

    (func (export "unreachable") (param i32) (result i32)
        (if (result i32) (local.get 0)
            (then
                i32.const 42
            )
            (else
                ;; Unreachable tells runtime that this branch should be never
                ;; executed. It it is, runtime will immediately fail.
                ;; Unreachable keyword allow us write disbalanced if-then-else
                ;; construction in cost of a promise that this brnch was never
                ;; reached.
                unreachable
            )
        )
    )
)
