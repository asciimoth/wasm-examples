const loader = require('../loader');

describe('Sharingy', () => {
    test('Sharing', async () => {
        const global = new WebAssembly.Global(
            { value: 'i32', mutable: true }, 0
        );
        const memory = new WebAssembly.Memory({ initial: 1, maximum: 1, shared: true });
        const options = {
            import: {
                glob: global,
                mem: memory,
            }
        }
        const instanceRead = await loader.loadwasm(
            __filename, __dirname, options, "-read"
        );
        const instanceWrite = await loader.loadwasm(
            __filename, __dirname, options, "-write"
        );

        // Check initial values
        expect(instanceRead.instance.exports.load(0)).toBe(0);
        expect(instanceRead.instance.exports.get()).toBe(0);

        // Write new ones via another instance
        instanceWrite.instance.exports.store(0, 42)
        instanceWrite.instance.exports.set(69)

        // Check
        expect(instanceRead.instance.exports.load(0)).toBe(42);
        expect(instanceRead.instance.exports.get()).toBe(69);
    });
});