const loader = require('../loader');

describe('v128', () => {
    test('PackUnpack', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.PackUnpack(42n, 69n)).toBe(42n);
    });

    test('i32x4Math', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.i32x4add(
            1, 2, 3, 4, // First quartet
            5, 6, 7, 8  // Second quartet
        )).toStrictEqual([
            6,  // 1 + 5
            8,  // 2 + 6
            10, // 3 + 7
            12, // 4 + 8
        ]);
    });
});
