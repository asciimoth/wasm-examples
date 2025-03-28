const loader = require('../loader');

describe('Comparisons', () => {
  test('Equal zero', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    expect(instance.exports.eqzi32(0)).toBe(1);
    expect(instance.exports.eqzi32(1)).toBe(0);
    expect(instance.exports.eqzi32(2)).toBe(0);
    expect(instance.exports.eqzi32(-137)).toBe(0);
  });

  test('Equal', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    // Equal
    expect(instance.exports.eqi32(0, 0)).toBe(1);
    expect(instance.exports.eqi32(137, 137)).toBe(1);
    expect(instance.exports.eqi32(137, -137)).toBe(0);
    expect(instance.exports.eqi32(42, 0)).toBe(0);

    // NOT Equal
    expect(instance.exports.nei32(0, 0)).toBe(0);
    expect(instance.exports.nei32(137, 137)).toBe(0);
    expect(instance.exports.nei32(137, -137)).toBe(1);
    expect(instance.exports.nei32(42, 0)).toBe(1);
  });

  test('Greater', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    // Greater
    expect(instance.exports.gtsi32(0, 0)).toBe(0);
    expect(instance.exports.gtsi32(1, 0)).toBe(1);
    expect(instance.exports.gtsi32(1, 1)).toBe(0);
    expect(instance.exports.gtsi32(-2, -126)).toBe(1);

    // Greater or equal
    expect(instance.exports.gesi32(0, 0)).toBe(1);
    expect(instance.exports.gesi32(1, 0)).toBe(1);
    expect(instance.exports.gesi32(1, 1)).toBe(1);
    expect(instance.exports.gesi32(-2, -126)).toBe(1);
  });

  test('Lesser', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    // Lesser
    expect(instance.exports.ltsi32(0, 0)).toBe(0);
    expect(instance.exports.ltsi32(0, 1)).toBe(1);
    expect(instance.exports.ltsi32(1, 1)).toBe(0);
    expect(instance.exports.ltsi32(-126, -1)).toBe(1);

    // Lesser or equal
    expect(instance.exports.lesi32(0, 0)).toBe(1);
    expect(instance.exports.lesi32(0, 1)).toBe(1);
    expect(instance.exports.lesi32(1, 1)).toBe(1);
    expect(instance.exports.lesi32(-126, -2)).toBe(1);
  });
});
