const loader = require('../loader');

describe('Math', () => {
  test('Summ numbers', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.addi32(2, 3)).toBe(5);
    expect(instance.exports.addi32(-1, 5)).toBe(4);

    // Js treat numbers as signed, when passing them to wasm functions
    expect(instance.exports.addi32(2147483647, 1)).toBe(-2147483648); // Overflow
  });
  test('Sub numbers', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.subi32(5, 3)).toBe(2);
    expect(instance.exports.subi32(4, -1)).toBe(5);

    // Js treat numbers as signed, when passing them to wasm functions
    expect(instance.exports.subi32(-2147483648, 1)).toBe(2147483647); // Overflow
  });
  test('Mul numbers', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.muli32(1, 11)).toBe(11);
    expect(instance.exports.muli32(2, 9)).toBe(18);

    // Js treat numbers as signed, when passing them to wasm functions
    expect(instance.exports.muli32(1073741824, 2)).toBe(-2147483648); // Overflow
  });
  test('Div numbers', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.divsi32(10, 2)).toBe(5);
    expect(instance.exports.divsi32(10, 3)).toBe(3);
    expect(instance.exports.divsi32(11, 3)).toBe(3);
  });
});
