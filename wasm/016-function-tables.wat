(module
    ;; We must define function type to use it in inderect calls
    (type $math (func (param i32 i32) (result i32)))

    ;; Creating table with size 2
    (table (export "table") 2 funcref)
    ;; Tables can have max size like memory: (table 2 10 funcref)
    ;; Currently tables can be used only to store function references but
    ;; their functionality can be extended in future

    ;; `elem` sections are defining table elements
    ;; `declare` keyword means that we register a function for usage in
    ;; table but do not adding it there for now
    (elem declare func $add)
    ;; To add element in table we should specify it position (aka offset)
    (elem (i32.const 0) func $sub)

    (func $add (param i32 i32) (result i32)
        (i32.add (local.get 0) (local.get 1))
    )

    (func $sub (param i32 i32) (result i32)
        (i32.sub (local.get 0) (local.get 1))
    )

    ;; Stores the function $funcID at $elemID in table
    (func $store (export "store") (param i32) (param funcref)
        (table.set (local.get 0) (local.get 1))
    )

    ;; Call one off functions from table by its position (aka offset)
    (func (export "indirect") (param $func i32) (param i32 i32) (result i32)
        (call_indirect (type $math) (local.get 1) (local.get 2) (local.get $func))
    )

    (func $initfunc
        ;; Adding $add function to table at 1 offset
        (call $store (i32.const 1) (ref.func $add))
    )

    ;; Tables and elements are like memory and data segments
    ;; Elements can be passive and can be dropped
    ;; Tables have dynamic size, can grows, can be inited with passive elements
    (func (export "size") (result i32)
        table.size
    )
    ;; We should specify func ref to fill newly created table cells
    ;; It can also be ref.null btw
    (func (export "grow") (param funcref) (param i32) (result i32)
        (table.grow (local.get 0) (local.get 1))
    )

    (start $initfunc)
)
