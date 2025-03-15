# wasm-examples
Some small demos written by hand in wat ([WASM](https://en.wikipedia.org/wiki/WebAssembly) text format) to explore 

## Repo structure
- [wasm](./wasm/) - small examples in pure wasm. Additional code (js) needed to laod and run them.
- [wasm-wasi](./wasm-wasi/) - wasm programs that can be executed via runtime with [WASI](https://wasi.dev/interfaces) system interface support (e.g. [wasmer](https://github.com/wasmerio/wasmer)).

## Requirements
- [wabt](https://github.com/WebAssembly/wabt) to compile `*.wat` source codes to binary `*.wasm` progs
- [wasmer](https://github.com/wasmerio/wasmer) to run compiled `*.wasm` files with [WASI](https://wasi.dev/interfaces) interface
- (optional) [nodejs](https://nodejs.org) to run tests
  
There is also [nix flake](./flake.nix) with all needed

## Run
## Tests
```sh
npm test
```

## wasm-wasi
To run [wasm-wasi](./wasm-wasi/) examples, use [run](./wasm-wasi/run) script to build and run `*.wat` files.
```sh
wasm-wasi/run wasm-wasi/hello-world
```
## Useful links
[WAT Spec](https://webassembly.github.io/spec/core/text/index.html)  
[WASM Semantics](https://webassembly.github.io/spec/core/exec/index.html)

MDN:
- [WASM Concepts](https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Concepts)
- [Understanding WAT](https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Understanding_the_text_format)

[Web WASM files explorer](https://wasdk.github.io/wasmcodeexplorer/)
[WAT to WASM online](https://webassembly.github.io/wabt/demo/wat2wasm/)
  
[WASM Feature Extensions and their support table](https://webassembly.org/features/)
  
[WASI](https://github.com/WebAssembly/WASI/) docs
- [preview1](https://github.com/WebAssembly/WASI/blob/main/legacy/preview1/docs.md) docs
  
[awesome-wasm-tools collection](https://github.com/vshymanskyy/awesome-wasm-tools)
  
A complete novice writes Wasm by hand series:
- [Parsing Numbers](https://burgers.io/complete-novice-wasm-parsing-numbers)
- [Adding an Allocator](https://burgers.io/complete-novice-wasm-allocator)
  
[Writing GameOfLife in WASM](https://blog.scottlogic.com/2018/04/26/webassembly-by-hand.html)
  
[wabt.js](https://www.npmjs.com/package/wabt) - library to compile wat to wasm right in your js code without invoking external tools
  
Examples:
- [quicsort](https://github.com/dominictarr/quicksort.wasm)
- [fibonacci](https://github.com/dominictarr/fib.wasm)
- [raw wasm demos](https://github.com/binji/raw-wasm)

