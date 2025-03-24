const loader = require('../loader');

describe('Drop', () => {
    test('Drop', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.drop(42, 69)).toBe(69);
    });

});
