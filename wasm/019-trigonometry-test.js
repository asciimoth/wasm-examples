const loader = require('../loader');

describe('CA', () => {
    test('pow', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        expect(instance.exports.pow(2, 2)).toBe(4);
        expect(instance.exports.pow(2, 0)).toBe(1);
        expect(instance.exports.pow(2, 1)).toBe(2);
        expect(instance.exports.pow(42, 0)).toBe(1);
        expect(instance.exports.pow(42, 1)).toBe(42);
        expect(instance.exports.pow(0.5, 2)).toBe(0.25);
        expect(instance.exports.pow(2, 52)).toBe(4503599627370496);
        expect(instance.exports.pow(3.1415926, 10)).toBe(93648.03150144957);
    });
    test('fact', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        const factorials = [
            1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800,
            479001600, 6227020800, 87178291200, 1307674368000, 20922789888000,
            355687428096000, 6402373705728000,
        ];
        for (let i = 0; i < factorials.length; i++) {
            expect(instance.exports.fact(i)).toBe(factorials[i]);
        }
    });
    test('radianNorm', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        expect(instance.exports.radianNorm(0)).toBe(0);
        expect(instance.exports.radianNorm(1)).toBe(1);
        expect(instance.exports.radianNorm(2)).toBe(2);
        expect(instance.exports.radianNorm(3)).toBe(3);
        expect(instance.exports.radianNorm(4.5)).toBe(4.5);
        expect(instance.exports.radianNorm(Math.PI)).toBe(Math.PI);
        expect(instance.exports.radianNorm(Math.PI*2)).toBe(Math.PI*2);
        expect(instance.exports.radianNorm(Math.PI*2+1)).toBe(1);
        expect(instance.exports.radianNorm(Math.PI*2+2)).toBe(2);
        expect(instance.exports.radianNorm(Math.PI*4+2)).toBe(2);
        expect(instance.exports.radianNorm(-Math.PI)).toBe(Math.PI);
        expect(instance.exports.radianNorm(-1)).toBe(Math.PI*2-1);
        expect(instance.exports.radianNorm(-2)).toBe(Math.PI*2-2);
        expect(instance.exports.radianNorm(-3)).toBe(Math.PI*2-3);
        expect(instance.exports.radianNorm(-4.5)).toBe(Math.PI*2-4.5);
    });
    test('sin', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        for (let i = 0.0; i < Math.PI*4; i+=0.001) {
            expect(instance.exports.sin(i)).toBeCloseTo(Math.sin(i));
        }
        for (let i = -100; i < 100; i++) {
            expect(instance.exports.sin(i)).toBeCloseTo(Math.sin(i));
        }
    });
    test('cos', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        for (let i = 0.0; i < Math.PI*4; i+=0.001) {
            expect(instance.exports.cos(i)).toBeCloseTo(Math.cos(i));
        }
        for (let i = -100; i < 100; i++) {
            expect(instance.exports.cos(i)).toBeCloseTo(Math.cos(i));
        }
    });
});
