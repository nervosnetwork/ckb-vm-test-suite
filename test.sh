#!/bin/bash
set -ex

if [ "x$RISCV" = "x" ]
then
  echo "Please set the RISCV environment variable to your installed path."
  exit 1
fi
PATH=$PATH:$RISCV/bin

# Inspired from https://stackoverflow.com/a/246128
TOP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $TOP

# If requested, make sure we are using latest revision of CKB VM
if [ "$1" = "--update-ckb-vm" ]
then
    rm -rf ckb-vm
    shift
fi

if [ ! -d "$TOP/ckb-vm" ]
then
    git clone https://github.com/nervosnetwork/ckb-vm "$TOP/ckb-vm"
fi

if [ "$1" = "--coverage" ]
then
    INTERPRETER32="kcov --verify $TOP/coverage $TOP/binary/target/debug/interpreter32"
    INTERPRETER64="kcov --verify $TOP/coverage $TOP/binary/target/debug/interpreter64"
    ASM64="kcov --verify $TOP/coverage $TOP/binary/target/debug/asm64"
    AOT64="kcov --verify $TOP/coverage $TOP/binary/target/debug/aot64"

    rm -rf $TOP/coverage

    # Build CKB VM binaries for testing
    cd "$TOP/binary"
    cargo build
else
    INTERPRETER32="$TOP/binary/target/release/interpreter32"
    INTERPRETER64="$TOP/binary/target/release/interpreter64"
    ASM64="$TOP/binary/target/release/asm64"
    AOT64="$TOP/binary/target/release/aot64"

    # Build CKB VM binaries for testing
    cd "$TOP/binary"
    cargo build --release
fi



# Build riscv-tests
cd "$TOP/riscv-tests"
autoconf
./configure
make isa

# Test CKB VM with riscv-tests
# NOTE: let's stick with the simple way here since we know there won't be
# whitespaces, otherwise shell might not be a good option here.
for i in $(find . -regex ".*/rv32u[imc]-u-[a-z0-9_]*" | grep -v "fence_i"); do
    $INTERPRETER32 $i
done
for i in $(find . -regex ".*/rv64u[imc]-u-[a-z0-9_]*" | grep -v "fence_i"); do
    $INTERPRETER64 $i
done
for i in $(find . -regex ".*/rv64u[imc]-u-[a-z0-9_]*" | grep -v "fence_i" | grep -v "rv64ui-u-jalr"); do
    $ASM64 $i
done
for i in $(find . -regex ".*/rv64u[imc]-u-[a-z0-9_]*" | grep -v "fence_i" | grep -v "rv64ui-u-jalr"); do
    $AOT64 $i
done

# Test CKB VM with riscv-compliance
cd "$TOP/riscv-compliance"

# TODO: more targets
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=I TARGET_SIM="$INTERPRETER64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=M TARGET_SIM="$INTERPRETER64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=C TARGET_SIM="$INTERPRETER64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=I TARGET_SIM="$ASM64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=M TARGET_SIM="$ASM64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=C TARGET_SIM="$ASM64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=I TARGET_SIM="$AOT64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=M TARGET_SIM="$AOT64" simulate
rm -rf work && make RISCV_TARGET=ckb-vm XLEN=64 RISCV_DEVICE=C TARGET_SIM="$AOT64" simulate

# Even though ckb-vm-bench-scripts are mainly used for benchmarks, they also
# contains sophisticated scripts which make good tests
cd "$TOP/ckb-vm-bench-scripts"
make
$INTERPRETER64 build/secp256k1_bench 033f8cf9c4d51a33206a6c1c6b27d2cc5129daa19dbd1fc148d395284f6b26411f 304402203679d909f43f073c7c1dcf8468a485090589079ee834e6eed92fea9b09b06a2402201e46f1075afa18f306715e7db87493e7b7e779569aa13c64ab3d09980b3560a3 foo bar
$ASM64 build/secp256k1_bench 033f8cf9c4d51a33206a6c1c6b27d2cc5129daa19dbd1fc148d395284f6b26411f 304402203679d909f43f073c7c1dcf8468a485090589079ee834e6eed92fea9b09b06a2402201e46f1075afa18f306715e7db87493e7b7e779569aa13c64ab3d09980b3560a3 foo bar
$AOT64 build/secp256k1_bench 033f8cf9c4d51a33206a6c1c6b27d2cc5129daa19dbd1fc148d395284f6b26411f 304402203679d909f43f073c7c1dcf8468a485090589079ee834e6eed92fea9b09b06a2402201e46f1075afa18f306715e7db87493e7b7e779569aa13c64ab3d09980b3560a3 foo bar

$INTERPRETER64 build/schnorr_bench 4103c5b538d6f695a961e916e7308211c8c917e1e02ca28a21b0989596a9ffb6 e45408b5981ec7fd6e72faa161776fe5db17dd92226d1ad784816fb843e151127d9ccb615f364f317a35e2ddddc91bbf30ad103ddfd3ad7e839f508dbfe6298a foo bar
$ASM64 build/schnorr_bench 4103c5b538d6f695a961e916e7308211c8c917e1e02ca28a21b0989596a9ffb6 e45408b5981ec7fd6e72faa161776fe5db17dd92226d1ad784816fb843e151127d9ccb615f364f317a35e2ddddc91bbf30ad103ddfd3ad7e839f508dbfe6298a foo bar
$AOT64 build/schnorr_bench 4103c5b538d6f695a961e916e7308211c8c917e1e02ca28a21b0989596a9ffb6 e45408b5981ec7fd6e72faa161776fe5db17dd92226d1ad784816fb843e151127d9ccb615f364f317a35e2ddddc91bbf30ad103ddfd3ad7e839f508dbfe6298a foo bar

echo "All tests are passed!"
