const loader = require('../loader');

describe('Select', () => {
    test('Select', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.select(42, 69, 0)).toBe(69);
        expect(instance.exports.select(42, 69, 1)).toBe(42);
        expect(instance.exports.select(42, 69, 137)).toBe(42);
    });
});
