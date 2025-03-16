const loader = require('../loader');

describe('Return const', () => {
  test('Return 42', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.get42()).toBe(42);
  });
});
