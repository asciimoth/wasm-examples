const loader = require('../loader');

const HelloWorld = new Uint8Array([
    // H     e     l     l     o     W     o     r     l     d     !
    0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
])

const HelloWASM = new Uint8Array([
    // H     e     l     l     o    SP     W     A     S     M     !
    0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x41, 0x53, 0x4D, 0x21
])

const HelloHello = new Uint8Array([
    // H     e     l     l     o     H     e     l     l     o     !
    0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21
])

const HellHellHell = new Uint8Array([
    // H     e     l     l     H     e     l     l     H     e     l     l
    0x48, 0x65, 0x6C, 0x6C, 0x48, 0x65, 0x6C, 0x6C, 0x48, 0x65, 0x6C, 0x6C,
])

const AAA = new Uint8Array([
    // A     A     A     A     A     A     A     A     A     A     A
    0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41,
])

describe('Memory', () => {
    test('Data', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        // Init state
        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 11))
            .toStrictEqual(HelloWorld);

        // Replace "World" with " WASM"
        instance.exports.init(5, 0, 5);
        // Check
        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 11))
            .toStrictEqual(HelloWASM);

        instance.exports.drop();

        // We cannot access passive data segment after we drop it
        expect(() => { instance.exports.init(5, 0, 5)  })
            .toThrow("memory access out of bounds");
    });

    test('LoadStore', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.loadi32(100)).toBe(0);
        instance.exports.storei32(100, 42)
        expect(instance.exports.loadi32(100)).toBe(42);

        expect(instance.exports.loadi32(200)).toBe(0);
        // AD 10
        instance.exports.storei32(200, 0xAD)
        instance.exports.storei32(201, 0x10)
        expect(instance.exports.loadi32(200)).toBe(4269); // 0x10AD

        expect(instance.exports.loadi32(300)).toBe(0);
        instance.exports.storei32(300, 0xABCDEF);
        expect(instance.exports.loadi32(300)).toBe(0xABCDEF);
        expect(instance.exports.load8ui32(300)).toBe(0xEF);
        expect(instance.exports.load8ui32(301)).toBe(0xCD);
        expect(instance.exports.load8ui32(302)).toBe(0xAB);
        expect(instance.exports.load8ui32(303)).toBe(0x00);
    });

    test('MemSize', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        // The initial mem size after module has loaded is one page long
        expect(new Uint8Array(instance.exports.mem.buffer).length).toBe(1*65536);
        expect(instance.exports.getMemSize()).toBe(1);

        // Request two more pages
        expect(instance.exports.growMem(2)).toBe(1)

        // Request five more pages
        expect(instance.exports.growMem(5)).toBe(3)

        // Now the mem size is eight pages long
        expect(new Uint8Array(instance.exports.mem.buffer).length).toBe(8*65536);
        expect(instance.exports.getMemSize()).toBe(8);

        // Request too much pages
        expect(instance.exports.growMem(2147483647)).toBe(-1) // -1 - means fail

        // There is still eight pages cause growth attempt was failed
        expect(new Uint8Array(instance.exports.mem.buffer).length).toBe(8*65536);
        expect(instance.exports.getMemSize()).toBe(8);
    });

    test('Copy', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        // Init state
        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 11))
            .toStrictEqual(HelloWorld);

        // Copy "Hello" from (0 5] to (5 10]
        instance.exports.copy(0, 5, 5);

        // Check
        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 11))
            .toStrictEqual(HelloHello);

        // Src and Dst segments can overlap
        instance.exports.copy(0, 4, 5);
        instance.exports.copy(4, 8, 5);

        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 12))
            .toStrictEqual(HellHellHell);
    });

    test('Fill', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        // Init state
        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 11))
            .toStrictEqual(HelloWorld);

        // Fill with "A"
        instance.exports.fill(0, 11, 0x41);

        expect(new Uint8Array(instance.exports.mem.buffer).slice(0, 11))
            .toStrictEqual(AAA);
    });
});
