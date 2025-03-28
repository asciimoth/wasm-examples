# wasm-examples
Some small demos written by hand to explore [WASM](https://en.wikipedia.org/wiki/WebAssembly)

## Repo structure
- [wasm](./wasm/) - small examples in pure wasm. Additional code (js) needed to load and run them.
- [wasm-wasi](./wasm-wasi/) - wasm programs that can be executed via runtime with [WASI](https://wasi.dev/interfaces) system interface support (e.g. [wasmer](https://github.com/wasmerio/wasmer)).

## Requirements
- [wabt](https://github.com/WebAssembly/wabt) to compile `*.wat` source codes to binary `*.wasm` progs
- [wasmer](https://github.com/wasmerio/wasmer) to run compiled `*.wasm` files with [WASI](https://wasi.dev/interfaces) interface
- (optional) [nodejs](https://nodejs.org) to run tests
  
There is also [nix flake](./flake.nix) with everything needed

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
[Index of instructions](https://webassembly.github.io/spec/core/appendix/index-instructions.html)  

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
  
[coderundebug's WAT series](https://coderundebug.com/learn/wat/introduction/#web-assembly)
- [WAT reference](https://coderundebug.com/learn/wat-reference/modules/#variables)
- [i32 operations](https://coderundebug.com/learn/wat-reference/i32/#i32-math)

[dkwr blog wasm posts](https://blog.dkwr.de/)
- [Wasm: A technical view](https://blog.dkwr.de/development/wasm-technical-view/)
- [Dive into Wasm: Functions](https://blog.dkwr.de/development/wasm-functions/)
- [Writing Wasm: modules](https://blog.dkwr.de/development/wasm-modules/)
- [Dive into Wasm: Control flow instructions](https://blog.dkwr.de/development/wasm-control-flow/)
- [Accessing and storing to memory in Wasm](https://blog.dkwr.de/development/wasm-memory/)
- [Wasm variable instructions](https://blog.dkwr.de/development/wasm-variable-instructions/)
- [Step by step towards wasm tables](https://blog.dkwr.de/development/wasm-tables/)
- [Wasm: SIMD operations](https://blog.dkwr.de/development/wasm-simd-operations/)
- [Wasm: The Garbage Collection proposal](https://blog.dkwr.de/development/wasm-gc-why/)

[Writing GameOfLife in WASM](https://blog.scottlogic.com/2018/04/26/webassembly-by-hand.html)
  
[wabt.js](https://www.npmjs.com/package/wabt) - library to compile wat to wasm right in your js code without invoking external tools
  
Examples:
- [quicsort](https://github.com/dominictarr/quicksort.wasm)
- [fibonacci](https://github.com/dominictarr/fib.wasm)
- [raw wasm demos](https://github.com/binji/raw-wasm)

[Nondeterminism in WebAssembly](https://github.com/WebAssembly/design/blob/main/Nondeterminism.md)
