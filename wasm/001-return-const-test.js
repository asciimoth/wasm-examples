const loader = require('../loader');

describe('Return const', () => {
  test('Consts', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.constDecimal()).toBe(42);
    expect(instance.exports.constHex()).toBe(-42);
  });
});
