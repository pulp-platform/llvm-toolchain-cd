#!/bin/bash -x
# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

WORKSPACE=$PWD

# Allow environment to control parallelism
if [ "x${PARALLEL_JOBS}" == "x" ]; then
  PARALLEL_JOBS=$(nproc)
fi

# Build "check-all" to run all the tests
cd ${WORKSPACE}/build/llvm
ninja -j${PARALLEL_JOBS} check-all > ${WORKSPACE}/llvm-tests.log 2>&1
exit 0
