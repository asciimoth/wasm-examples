const loader = require('../loader');

describe('Floats', () => {
    test('Consts', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        /*
            In general, checking equality for floating numbers is bad practice
            cause floating math has precision loss.
            But if you comparing constants with constants, its ok.

            Also its (arguably) ok fo tests cause here cost of error is just a
            test fault and no more.

            Anyway, you shoud never compare floats this way in real word apps.
        */
        expect(instance.exports.constDec()).toBe(42.42);
        expect(instance.exports.constHex()).toBe(-42.42);
        expect(instance.exports.constDecExpoent()).toBe(42000.5e-3);

        expect(instance.exports.constInf()).toBe(Infinity);
        expect(instance.exports.constNeInf()).toBe(-Infinity);

        expect(instance.exports.constNaN()).toBe(NaN);
        // -Nan == NaN in Jest btw
        expect(instance.exports.constNaN()).toBe(-NaN);
    });

    test('add', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        // Infamous example
        // https://0.30000000000000004.com/
        expect(instance.exports.add(0.1, 0.2)).toBe(0.30000000000000004);
    });

    test('NaN', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        // Every math operation with NaN return NaN also
        expect(instance.exports.add(42, NaN)).toBe(NaN);
        expect(instance.exports.sub(42, NaN)).toBe(NaN);
        expect(instance.exports.mul(42, NaN)).toBe(NaN);
        expect(instance.exports.div(42, NaN)).toBe(NaN);
        expect(instance.exports.abs(NaN)).toBe(NaN);
        expect(instance.exports.neg(NaN)).toBe(NaN);
        expect(instance.exports.ceil(NaN)).toBe(NaN);
        expect(instance.exports.floor(NaN)).toBe(NaN);
        expect(instance.exports.nearest(NaN)).toBe(NaN);
        expect(instance.exports.trunc(NaN)).toBe(NaN);
        expect(instance.exports.sqrt(NaN)).toBe(NaN);
        expect(instance.exports.min(42, NaN)).toBe(NaN);
        expect(instance.exports.min(-42, NaN)).toBe(NaN);
        expect(instance.exports.max(42, NaN)).toBe(NaN);
        expect(instance.exports.max(-42, NaN)).toBe(NaN);

        // Copyng sign on number from NaN unexpectedly trait NaN as normal 
        //   number, positive or negative
        expect(instance.exports.copysign(42, NaN)).toBe(42);
        expect(instance.exports.copysign(42, -NaN)).toBe(-42);
        expect(instance.exports.copysign(-42, NaN)).toBe(42);
        expect(instance.exports.copysign(-42, -NaN)).toBe(-42);
    });
});
