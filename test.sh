#!/bin/bash
set -ex

if [ "x$RISCV" = "x" ]
then
  echo "Please set the RISCV environment variable to your installed path."
  exit 1
fi

TOP=`pwd`
INTERPRETER32="$TOP/binary/target/release/interpreter32"
INTERPRETER64="$TOP/binary/target/release/interpreter64"
ASM64="$TOP/binary/target/release/asm64"

# If requested, make sure we are using latest revision of CKB VM
if [ "$1" = "--update-ckb-vm" ]
then
    rm -rf ckb-vm
fi

if [ ! -d "$TOP/ckb-vm" ]
then
    git clone https://github.com/nervosnetwork/ckb-vm "$TOP/ckb-vm"
fi

# Build CKB VM binaries for testing
cd "$TOP/binary"
cargo build --release

# Build riscv-tests
cd "$TOP/riscv-tests"
autoconf
./configure
make isa

# Test CKB VM with riscv-tests
# NOTE: let's stick with the simple way here since we know there won't be
# whitespaces, otherwise shell might not be a good option here.
for i in $(find . -regex ".*/rv32u[imc]-u-[a-z0-9_]+" | grep -v "fence_i"); do
    "$INTERPRETER32" $i
done
for i in $(find . -regex ".*/rv64u[imc]-u-[a-z0-9_]+" | grep -v "fence_i"); do
    "$INTERPRETER64" $i
done
for i in $(find . -regex ".*/rv64u[imc]-u-[a-z0-9_]+" | grep -v "fence_i"); do
    "$ASM64" $i
done

# Test CKB VM with riscv-compliance
cd "$TOP/riscv-compliance"
make clean
make RISCV_TARGET=ckb-vm RISCV_ISA=rv32i TARGET_SIM="$INTERPRETER32" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv32im TARGET_SIM="$INTERPRETER32" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv32imc TARGET_SIM="$INTERPRETER32" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv32uc TARGET_SIM="$INTERPRETER32" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv32ui TARGET_SIM="$INTERPRETER32" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv64i TARGET_SIM="$INTERPRETER64" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv64im TARGET_SIM="$INTERPRETER64" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv64i TARGET_SIM="$ASM64" simulate
make RISCV_TARGET=ckb-vm RISCV_ISA=rv64im TARGET_SIM="$ASM64" simulate

echo "All tests are passed!"
