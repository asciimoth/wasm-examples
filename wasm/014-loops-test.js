const loader = require('../loader');

const HelloWorld = new Uint8Array([
    // H     e     l     l     o     W     o     r     l     d     !
    0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
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
    //   A     A     A     A     A     A     A     A     A     A     A
    0, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0,
])

describe('Loops', () => {
    test('Countup', async () => {
        let result = [];
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                addResult: (r) => { result.push(r) },
            },
        });

        instance.exports.countup(10, 5);
        expect(result).toStrictEqual([10, 11, 12, 13, 14]);

        result = [];

        instance.exports.countup(-3, 6);
        expect(result).toStrictEqual([-3, -2, -1, 0, 1, 2]);
    });

    test('Countdown', async () => {
        let result = [];
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                addResult: (r) => { result.push(r) },
            },
        });

        instance.exports.coundown(15, 5);
        expect(result).toStrictEqual([15, 14, 13, 12, 11]);

        result = [];

        instance.exports.coundown(3, 6);
        expect(result).toStrictEqual([3, 2, 1, 0, -1, -2]);
    });

    test('memCopy', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                addResult: () => {},
            },
        });

        // Init state
        expect(new Uint8Array(instance.exports.mem.buffer).slice(200, 211))
            .toStrictEqual(HelloWorld);

        // Copy "Hello" from (0 5] to (5 10]
        instance.exports.memCopy(200, 205, 5);

        // Check
        expect(new Uint8Array(instance.exports.mem.buffer).slice(200, 211))
            .toStrictEqual(HelloHello);

        // Src and Dst segments can overlap
        instance.exports.memCopy(200, 204, 5);
        instance.exports.memCopy(204, 208, 5);

        expect(new Uint8Array(instance.exports.mem.buffer).slice(200, 212))
            .toStrictEqual(HellHellHell);
    });

    test('Fill', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                addResult: () => {},
            },
        });

        instance.exports.memFill(101, 11, 0x41);

        expect(new Uint8Array(instance.exports.mem.buffer).slice(100, 113))
            .toStrictEqual(AAA);
    });
});
