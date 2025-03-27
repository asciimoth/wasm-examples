const path = require('path');
const fs = require('fs');

module.exports = {
    loadwasm: async (fname, dname, options = {}) => {
        const rootDir = process.cwd();
        const relativeDir = path.relative(rootDir, dname);

        const wasmDir = path.join(rootDir, relativeDir);
        const wasmName = path.basename(fname, '-test.js') + '.wasm';
        const wasmPath = path.join(wasmDir, wasmName);

        return await WebAssembly.instantiate(fs.readFileSync(wasmPath), options);
    }
}
