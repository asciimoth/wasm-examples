# wasm-wasi-examples
Some small demos written by hand in wat ([wasm](https://en.wikipedia.org/wiki/WebAssembly) text format) to explore [wasi](https://wasi.dev/interfaces) system interface

## Requirements
- [wabt](https://github.com/WebAssembly/wabt) to compile `*.wat` source codes to binary `*.wasm` progs
- [wasmer](https://github.com/wasmerio/wasmer) to run compiled `*.wasm` files with wasi interface available

## Run 
Use [run](./run) script to build and run `*.wat` files.
```sh
run hello-world
```
