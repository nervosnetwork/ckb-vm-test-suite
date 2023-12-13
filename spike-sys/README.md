A Rust FFI binding for executing instructions in spike (https://github.com/riscv-software-src/riscv-isa-sim). It's not a full binding to spike.

```sh
$ cargo build
```

If the build fails, please install the following dependencies

```sh
$ sudo apt install device-tree-compiler

$ wget https://apt.llvm.org/llvm.sh
$ chmod +x llvm.sh
$ sudo ./llvm.sh 16 all
$ rm llvm.sh
```

How to publish it to crates.io

```sh
$ cargo publish --no-verify
```
