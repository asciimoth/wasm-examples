(module
    ;; Memory in wasm is just flat untyped array of bytes.
    ;; You cand define initial size of memeroy in pages
    ;; Each page = 64Kb = 65536 bytes
    (memory $mem 1 (; One page size memory ;))
    ;; Anyway you can request more memory in runtime.
    ;; You can also pre-define memory growth limit for your module: (memory 1 10)
    ;; Maximum memory size - 4Gib
    ;; Memory can be exported (and imported) like functions or globals
    (export "mem" (memory $mem))

    ;; When module loads or when new memory alocates at runtime
    ;; all new memory is filled with zeros. But you can defile initial content
    ;; of memory segments with data sections.

    ;; Place byte codes of letters "Hello" (0x48656C6C6F) in memory
    ;; with 0 offset.
    (data (i32.const 0) "Hello")
    ;; Place byte codes of letters "World" (0x576F6D626174) in memory
    ;; with 5 offset (right after "Hello").
    (data (i32.const 5) "Wombat")
    ;; Data segments also can owerlap.
    ;; Ones that define earlier will rewrite ones that define later.
    (data (i32.const 7) "rld!")
    (;
        After module will be loaded it's memory content will be this:
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

    ;; We can also define so-called "passive" data which is basicly equvalent
    ;; for global immutable variables (aka constants) but with arbitrary length
    ;; binary data instead of numbers (i32/i64/f32/f64).
    ;; Passive data segments do not writes to memory at load time.
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

    ;; You can load and store not full value, but only it part
    ;; 8 and 16 bit for i32
    ;; 8, 16, and 32 bit for i64
    ;; f32 and f64 may be sore/loaded only full.
    (func (export "store8i32") (param $offset i32) (param $value i32)
        ;; Place i32 $value in memory at $offset
        (i32.store8 (local.get $offset) (local.get $value))
    )
    ;; To load only part of int we should specify it signess
    (func (export "load8ui32") (param $offset i32) (result i32)
        ;; Load i32 value from memory at $offset
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

    ;; You can "drop" passive data segment.
    ;; After dropped in becomes inaccessible.
    ;; This operation is optimisation hint that allows runtime to free memory
    ;; allocated for this data segment.
    (func (export "drop") (param $id i32)
        ;; ID of segment should be constant specified at compile time.
        (data.drop $passive)
    )

    (func (export "getMemSize") (result i32)
        ;; Get size of memory in pages
        memory.size
    )

    (func (export "growMem") (param $count i32) (result i32)
        ;; Add $count new pages to memory
        (memory.grow (local.get $count))
        ;; Returns previous size (before grows) if success or -1 if fail
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
        ;; Only least significant byte from $value will be used
    )
)