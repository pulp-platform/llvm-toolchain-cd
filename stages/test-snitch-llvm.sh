#!/bin/bash -x
# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Run the Snitch regression tests

WORKSPACE=$PWD

# List all tests here that shall be run by this script
TESTS=(
    "../clang/test/CodeGen/RISCV/riscv-sdma-intrinsics.c"
    "../clang/test/CodeGen/RISCV/riscv-ssr-intrinsics.c"
    "../llvm/test/CodeGen/RISCV/freploop.ll"
    "../llvm/test/MC/RISCV/rv32xfrep-valid.s"
    "../llvm/test/MC/RISCV/rv32xdma-valid.s"
    "../llvm/test/MC/RISCV/rv32xssr-valid.s"
    "../llvm/test/CodeGen/RISCV/sdma-intrinsics.ll"
    "../llvm/test/CodeGen/RISCV/sdma-pseudo-instructions.mir"
    "../llvm/test/CodeGen/RISCV/ssr-pseudo-instructions.mir"
    "../llvm/test/CodeGen/RISCV/ssr-register-reserving.ll"
    "../llvm/test/CodeGen/RISCV/ssr-register-merging.mir"
  )

# Allow environment to control parallelism
if [ "x${PARALLEL_JOBS}" == "x" ]; then
  PARALLEL_JOBS=$(nproc)
fi

cd ${WORKSPACE}/build/llvm
bin/llvm-lit -v -o ${WORKSPACE}/snitch-tests.log -j${PARALLEL_JOBS} "${TESTS[@]}"
