#!/bin/bash -x
# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Run the Snitch regression tests

WORKSPACE=$PWD

# default location for llvm binaries and tests
if [ "x${LLVM_BIN}" == "x" ]; then
  LLVM_BIN=${WORKSPACE}/build/llvm/bin/
fi
if [ "x${LLVM_SRC}" == "x" ]; then
  LLVM_SRC=${WORKSPACE}/llvm-project
fi

# List all tests here that shall be run by this script
TESTS=(
    "${LLVM_SRC}/clang/test/CodeGen/RISCV/riscv-sdma-intrinsics.c"
    "${LLVM_SRC}/clang/test/CodeGen/RISCV/riscv-ssr-intrinsics.c"
    "${LLVM_SRC}/llvm/test/CodeGen/RISCV/freploop.ll"
    "${LLVM_SRC}/llvm/test/MC/RISCV/rv32xfrep-valid.s"
    "${LLVM_SRC}/llvm/test/MC/RISCV/rv32xdma-valid.s"
    "${LLVM_SRC}/llvm/test/MC/RISCV/rv32xssr-valid.s"
    "${LLVM_SRC}/llvm/test/CodeGen/RISCV/sdma-intrinsics.ll"
    "${LLVM_SRC}/llvm/test/CodeGen/RISCV/sdma-pseudo-instructions.mir"
    "${LLVM_SRC}/llvm/test/CodeGen/RISCV/ssr-pseudo-instructions.mir"
    "${LLVM_SRC}/llvm/test/CodeGen/RISCV/ssr-register-reserving.ll"
    "${LLVM_SRC}/llvm/test/CodeGen/RISCV/ssr-register-merging.mir"
  )

# Allow environment to control parallelism
if [ "x${PARALLEL_JOBS}" == "x" ]; then
  PARALLEL_JOBS=$(nproc)
fi

${LLVM_BIN}/llvm-lit -v -o ${WORKSPACE}/snitch-tests.log -j${PARALLEL_JOBS} "${TESTS[@]}"
