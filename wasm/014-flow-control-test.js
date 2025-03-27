const loader = require('../loader');

describe('FlowControll', () => {
    test('resultIf', async () => {
        let result = [];
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                setResult: (r) => { result.push(r) },
            },
        });
        instance.exports.resultIf(0)
        expect(result).toStrictEqual([69, 271]);
        result = []
        instance.exports.resultIf(-1)
        expect(result).toStrictEqual([42, 314]);
    });

    test('returnIf', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                setResult: () => {},
            },
        });
        expect(instance.exports.returnIf(0)).toStrictEqual(69);
        expect(instance.exports.returnIf(1)).toStrictEqual(42);
    });

    test('unreachable', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                setResult: () => {},
            },
        });
        expect(() => { instance.exports.unreachable(0) }).toThrow("unreachable");
        expect(instance.exports.unreachable(1)).toStrictEqual(42);
    });
});
