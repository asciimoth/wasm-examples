const loader = require('../loader');

describe('Tables', () => {
    test('Init', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        expect(instance.exports.table.get(0)(5, 3)).toBe(2);
        expect(instance.exports.table.get(1)(5, 3)).toBe(8);
    });
    test('Indirect', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        expect(instance.exports.indirect(0, 5, 3)).toBe(2);
        expect(instance.exports.indirect(1, 5, 3)).toBe(8);
    });
    test('SwapWithStore', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        let sub = instance.exports.table.get(0);
        let add = instance.exports.table.get(1);
        instance.exports.store(0, add);
        instance.exports.store(1, sub);
        expect(instance.exports.indirect(0, 5, 3)).toBe(8);
        expect(instance.exports.indirect(1, 5, 3)).toBe(2);
    });
    test('Size', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.size(0)).toBe(2);
        expect(instance.exports.grow(
            instance.exports.table.get(0), 3,
        )).toBe(2);
        expect(instance.exports.size(0)).toBe(5);
        expect(instance.exports.grow(null, 3)).toBe(5);
        expect(instance.exports.grow(
            instance.exports.table.get(0), 2147483647,
        )).toBe(-1);
    });
});
