(module
    (func (export "select") (param i32 i32 i32) (result i32)
        local.get 0
        local.get 1
        local.get 2
        ;; Pops 3 elements from stack:
        ;;   - arg 0
        ;;   - arg 1
        ;;   - condition
        ;; Pushes back:
        ;;   - arg 0 if condition != 0
        ;;   - arg 1 if condition == 0
        ;; Both args should be the same type
        ;; Condition should be i32
        select
    )
)