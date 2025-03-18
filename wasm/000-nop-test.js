const loader = require('../loader');

describe('Nop', () => {
  test('Do nothing', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.doNothing()).toBe(undefined);
  });
});
