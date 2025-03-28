const loader = require('../loader');

describe('Functions', () => {
    test('CallImport', async () => {
        let value = 42;

        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                seti32: (newValue) => {
                    value = newValue
                },
            },
        });

        expect(value).toBe(42);
        instance.exports.callseti32(69);
        expect(value).toBe(69);
    });

    test('Call', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                seti32: () => {},
            },
        });

        expect(instance.exports.mul(5, 2)).toStrictEqual(10);
    });

    test('MultiValue', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                seti32: () => {},
            },
        });

        // If you call WASM function that returns multiple values from JS, you
        // get a list as a result.
        expect(instance.exports.div(5, 2)).toStrictEqual([2, 1]);
    });

    test('Start', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                seti32: () => {},
            },
        });

        expect(instance.exports.global.value).toBe(42);
    });

    test('AddNSub', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                seti32: () => {},
            },
        });

        expect(instance.exports.add(5, 2)).toStrictEqual(7);
        expect(instance.exports.sub(5, 2)).toStrictEqual(3);
    });

    test('const', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                seti32: () => {},
            },
        });

        expect(instance.exports.const()).toStrictEqual(42);
    });
});
