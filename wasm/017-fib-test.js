const loader = require('../loader');

const reference = new Uint32Array([
    0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711
]);

describe('Fib', () => {
    test('Fib', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        const off = 1*4;

        instance.exports.fib(off, reference.length);
        expect(new Uint32Array(instance.exports.mem.buffer)
            .slice(off/4, off/4+reference.length))
            .toStrictEqual(reference);
    });
});