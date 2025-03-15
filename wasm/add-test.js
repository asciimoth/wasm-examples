const loader = require('../loader');

console.log(loader);

describe('Add fn', () => {
  test('Summ numbers', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.add(2, 3)).toBe(5);
    expect(instance.exports.add(-1, 5)).toBe(4);
  });
});
