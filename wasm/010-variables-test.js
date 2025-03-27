const loader = require('../loader');

describe('Variables', () => {
    test('Global', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.g1get()).toBe(101);

        instance.exports.g1set(42);
        expect(instance.exports.g1get()).toBe(42);
        instance.exports.g1set(69);
        expect(instance.exports.g1get()).toBe(69);

        expect(instance.exports.glob2.value).toBe(404);
        instance.exports.g2set(200);
        expect(instance.exports.glob2.value).toBe(200);
        instance.exports.g2set(300);
        expect(instance.exports.glob2.value).toBe(300);
        instance.exports.glob2.value = 500;
        expect(instance.exports.glob2.value).toBe(500);

        instance.exports.g1set(314);
        instance.exports.g2set(137);
        expect(instance.exports.select(0)).toBe(137);
        expect(instance.exports.select(1)).toBe(314);
    });
    test('Local', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.mul(3, 5, 7)).toBe(105);
    });
});
