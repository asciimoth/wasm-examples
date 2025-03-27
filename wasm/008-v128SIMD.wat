;; TODO: Move this example AFTER variables, functions and drop examples
(module
    ;; Single Instruction Multiple Data in general is a type of instruction
    ;; that operates on multiple sets of values at the same time (multiple data)
    ;; but does the same operation for each of them (single instruction).

    ;; For example if you have four values (A B C D) and want to
    ;; calculate E=A+B and F=C+D without SIMD you should do at least two ops.
    ;; On the other hand with SIMD you can do it with one operation.
    ;; SIMD ops are important not only because of code space saving but mainly
    ;; because modern hardware can (sometimes) execute them much faster
    ;; than the equivalent set of simple ones.
    ;; Some hardware (GPU) is fully designed around SIMD concept, but even general
    ;; purpose CPU can execute well designed SIMD code much much faster than
    ;; the usual one.

    ;; For now WASM support only so-called v128 SIMD instructions that operate
    ;; on 128bit (16byte) "vectors" which are just a set of:
    ;;   - 16 x 8bit values or
    ;;   - 8 x 16bit values or
    ;;   - 4 x 32bit values or
    ;;   - 2 x 64bit values
    ;;
    ;; bytes:  0 1 2 3 4 5 6 7 8 9 A B C D E F 
    ;;        |_______________________________| v128 value
    ;;        |_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_| 16 x 8 values
    ;;        |___|___|___|___|___|___|___|___| 8 x 16 values
    ;;        |_______|_______|_______|_______| 4 x 32 values
    ;;        |_______________|_______________| 2 x 64 values
    ;;
    ;; Each of these values are "packed" inside a vector called a "lane".

    ;; SIMD operations in WASM use this naming scheme:
    ;; <Interpretation>.<Operation>
    ;; Where <Interpretation> is one of these variants:
    ;;   - i8x16
    ;;   - i16x8
    ;;   - i32x4
    ;;   - i64x2
    ;;   - f32x4
    ;;   - f64x2

    ;; Ofc to use instructions that operate on 128bit vectors you should
    ;; create such vectors by "packing" multiple simple types together.
    ;;
    ;; The simplest variant here is v128.const operation that takes interpretation
    ;; and set of values: `v128.const i32x4 1 2 3 4`, `v128.const i64x2 5 6`, etc
    ;;
    ;; Next one are "splat" operations that pop one value of a specified type from
    ;; the stack and push back a v128 filled with copies of this value:
    ;;   (i32x4.splat (i32.const 42)) ;; returns v128=[42|42|42|42]
    ;;   (f64x2.splat (f64.const 42.4)) ;; returns v128=[42.4|42.4]
    ;;
    ;; Also there is replace_lane operations that allow you (as their names say)
    ;; to replace one of the lines in an already existing vector by another value:
    ;; - Assume there is v128[0,0,0,0] on stack
    ;; - call i32.const 42 ;; Pushing new value on stack
    ;; - call i32x4.replace_lane 1 ;; Replacing
    ;; - Now there is v128[0,42,0,0] on stack
    ;;
    ;; You may expect that there should be a single operation that constructs a new
    ;; vector from a set of values, but there is not. So each time you should
    ;; create a new vector with const or splat operations and then put your
    ;; values inside with replace_lane.
    ;; That may sound like computation wasting, but in real life most WASM
    ;; runtimes replace this pattern with a single operation if the current hardware
    ;; has one.

    ;; And now after this intro here is our "simple" example.
    ;; We cannot pass vectors between JS and WASM so for all our examples here
    ;; we should construct vectors in place.
    (func (export "PackUnpack") (param i64 i64) (result i64)
        local.get 0 ;; Put first arg on stack
        i64x2.splat ;; Create vectors with two copies of the first arg
        ;; There is v128[param0|param0] on stack now
        local.get 1 ;; Put the second arg on stack
        i64x2.replace_lane 1 ;; Replace
        ;; There is v128[param0|param1] on stack now
        i64x2.extract_lane 0 ;; Pops vector from stack, pushes back param0
        ;; Yes, that function of 5 operations just returns its firs arg.
        ;; Yes, writing SIMD by hand is a bit painful and a lot more verbose.
    )

    ;; Ok, it's time for real programming
    ;; Let's sum the numbers up
    (func (export "i32x4add")
        (param i32 i32 i32 i32)
        (param i32 i32 i32 i32)
        (result i32 i32 i32 i32)

        ;; We need it to dup our vector when unpacking
        (local $vec v128)

        ;; Pack the first quartet
        local.get 0
        i32x4.splat
        local.get 1
        i32x4.replace_lane 1
        local.get 2
        i32x4.replace_lane 2
        local.get 3
        i32x4.replace_lane 3

        ;; Pack the second quartet
        local.get 4
        i32x4.splat
        local.get 5
        i32x4.replace_lane 1
        local.get 6
        i32x4.replace_lane 2
        local.get 7
        i32x4.replace_lane 3

        i32x4.add ;; Finally

        ;; Now unpacking
        local.tee $vec
        i32x4.extract_lane 0
        local.get $vec
        i32x4.extract_lane 1
        local.get $vec
        i32x4.extract_lane 2
        local.get $vec
        i32x4.extract_lane 3
    )
    ;; There is also sub, mul, neg, abs operations that work as you might expect

    ;; A list of all v128 instructions which may be useful
    ;; https://github.com/WebAssembly/simd/blob/master/proposals/simd/BinarySIMD.md#simd-instruction-encodings
)
