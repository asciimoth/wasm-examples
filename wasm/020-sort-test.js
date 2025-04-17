const loader = require('../loader');

function shuffleUint32Array(inputArray) {
    // Copy of input
    const shuffled = inputArray.slice();
    // Knuth shuffle algorithm
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        // Swap elements
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

const sorted = new Uint32Array([
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
]);

const inverted = new Uint32Array([
    20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
]);

const shuffled = shuffleUint32Array(sorted);



describe('Sort', () => {
    test('Sort', async () => {
        const testCase = async (init, algo, comp) => {
            const memory = new WebAssembly.Memory({initial: 1, maximum: 2});
            const memoryView = new Uint32Array(memory.buffer);
            memoryView.set(init);
            const { instance } = await loader.loadwasm(__filename, __dirname, {
                import:{
                    memory: memory,
                }
            });
            instance.exports.sort(algo, comp, 0, init.length);
            return new Uint32Array(memory.buffer).slice(0, init.length)
        }
        expect(await testCase(shuffled, 0, 2)).toStrictEqual(sorted);
        expect(await testCase(shuffled, 1, 2)).toStrictEqual(sorted);
        expect(await testCase(shuffled, 0, 3)).toStrictEqual(inverted);
        expect(await testCase(shuffled, 1, 3)).toStrictEqual(inverted);
    });
});
