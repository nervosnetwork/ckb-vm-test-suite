# ckb-vm-test-suite
Test suite for CKB VM, kept in a separate project to avoid polluting the vm repo with submodules

# How to run this

First, make sure you have [RISCV GNU toolchain](https://github.com/riscv/riscv-gnu-toolchain) installed. The environment variable `RISCV` should point to the path where you install RISCV GNU toolchain. To test this, make sure the following command works:

```bash
$ ls $RISCV/bin/riscv64-unknown-elf-gcc
```

Now you can run the test suite with the following steps:

```bash
$ git clone https://github.com/nervosnetwork/ckb-vm-test-suite
$ git submodule update --init --recursive
$ export PATH=$RISCV/bin:$PATH
$ ./test.sh
```

If you see `All tests are passed!` printed at the end, it means all tests are passed on current CKB VM, otherwise check the outputs for where it goes wrong.
