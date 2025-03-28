(module
    ;; Memory in WASM is just a flat untyped array of bytes
    ;; You can define the initial size of memory in pages
    ;; Each page = 64Kb = 65536 bytes
    (memory $mem 1 (; One page sized memory ;))
    ;; Anyways you can request more memory in runtime
    ;; You can also pre-define memory growth limit for your module: (memory 1 10)
    ;; Maximum memory size - 4Gib
    ;; Memory can be exported (and imported) like functions or globals
    (export "mem" (memory $mem))

    ;; When a module loads or when new memory allocates at runtime
    ;; all new memory is filled with zeros. But you can define initial content
    ;; of the memory segments with data sections

    ;; Place the byte codes of letters "Hello" (0x48656C6C6F) in the memory
    ;; with 0 offset
    (data (i32.const 0) "Hello")
    ;; Place the byte codes of letters "World" (0x576F6D626174) in the memory
    ;; with 5 offset (right after "Hello")
    (data (i32.const 5) "Wombat")
    ;; Data segments also can overlap
    ;; Ones that were defined earlier will be rewritten by the ones that
    ;; will be defined later
    (data (i32.const 7) "rld!")
    (;
        After the module has been loaded its memory content will be this:
        Offset | Hex byte value | ASCII char
             0 | 48             | H
             1 | 65             | e
             2 | 6C             | l
             3 | 6C             | l
             4 | 6F             | o
             5 | 57             | W
             6 | 6F             | o
             7 | 72             | r
             8 | 6C             | l
             9 | 64             | d
            10 | 21             | !
            11 | 0              | NUL
            12 | 0              | NUL
          ... A lot of zeros below ...
    ;)

    ;; We can also define so-called "passive" data which is basically equivalent
    ;; to global immutable variables (aka constants) but with
    ;; arbitrary length binary data instead of numbers (i32/i64/f32/f64)
    ;; Passive data segments are not written into memory at the load time
    ;; Instead they may be 
    (data $passive " WASM")

    (func (export "storei32") (param $offset i32) (param $value i32)
        ;; Place i32 $value in memory at $offset
        (i32.store (local.get $offset) (local.get $value))
    )
    (func (export "loadi32") (param $offset i32) (result i32)
        ;; Load i32 value from memory at $offset
        (i32.load (local.get $offset))
    )

    ;; You can load and store not the full value, but only a part of it
    ;; 8 and 16 bit for i32
    ;; 8, 16, and 32 bit for i64
    ;; f32 and f64 may be stored/loaded only fully
    (func (export "store8i32") (param $offset i32) (param $value i32)
        ;; Place i32 $value in memory at $offset
        (i32.store8 (local.get $offset) (local.get $value))
    )
    ;; To load only a part of int we should specify its sign
    (func (export "load8ui32") (param $offset i32) (result i32)
        ;; Load i32 value from the memory at $offset
        (i32.load8_u (local.get $offset))
    )

    (func (export "init")
        (param $offsetMem i32)
        (param $offsetData i32)
        (param $length i32)
        (memory.init $passive
            (local.get $offsetMem)
            (local.get $offsetData)
            (local.get $length)
        )
    )

    ;; You can "drop" the passive data segment.
    ;; After dropped it becomes inaccessible.
    ;; This operation is an optimization hint that allows runtime to free 
    ;; the memory allocated for this data segment
    (func (export "drop") (param $id i32)
        ;; ID of the segment should be constant specified at compile time
        (data.drop $passive)
    )

    (func (export "getMemSize") (result i32)
        ;; Get the size of memory in pages
        memory.size
    )

    (func (export "growMem") (param $count i32) (result i32)
        ;; Add $count new pages to memory
        (memory.grow (local.get $count))
        ;; Returns previous size (before grows) on success or -1 on fail
    )

    (func (export "copy")
        (param $offsetSrc i32) (param $offsetDst i32) (param $size i32)
        ;; Copy mem slice of $size from $offsetSrc to $offsetDst
        (memory.copy
            (local.get $offsetDst) (local.get $offsetSrc) (local.get $size)
        )
    )

    (func (export "fill")
        (param $offset i32) (param $size i32) (param $value i32)
        ;; Fill memory segment from $offset to $offset+$size with $value
        (memory.fill
            (local.get $offset) (local.get $value) (local.get $size)
        )
        ;; Only the least significant byte from $value will be used
    )
)