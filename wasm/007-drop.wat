(module
    ;; Returns second param
    (func (export "drop") (param i32 i32) (result i32)
        local.get 1
        local.get 0
        drop ;; Just pops value. Does not push anything back.
    )
)