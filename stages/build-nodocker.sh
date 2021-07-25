#!/bin/bash
# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Build a toolchain release directly on the host system using an already checked-out
# LLVM in the .build working directory

if [ "$#" -ne 1 ]; then
  echo "Illegal number of arguments"
  echo "${0} <llvm-dir>"
  exit -1
fi


########################################
## build settings
########################################
CCACHE_BUILD=False
BUGURL=https://github.com/pulp-platform/snitch-llvm/issues
PKGVERS=riscv32-snitch-llvm-centos7
BUILDNO=0
# PARALLEL_JOBS=$(expr `nproc` - 2)
PARALLEL_JOBS=24

CMAKE_VERS=3.18.4

CC=/usr/pack/gcc-9.2.0-af/linux-x64/bin/gcc
CXX=/usr/pack/gcc-9.2.0-af/linux-x64/bin/g++

########################################
## working directories
########################################
OLDPWD=`pwd`
WORK=${OLDPWD}/.build
SCRIPTSPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEWLIB_SRC=${WORK}/newlib
LLVM_SRC=`readlink -f ${1}`

########################################
## Print env
########################################
echo "SCRIPTSPATH          ${SCRIPTSPATH}"
echo "NEWLIB_SRC           ${NEWLIB_SRC}"
echo "LLVM_SRC             ${LLVM_SRC}"

# sleep 2
# set -ex

########################################
## Prepare build tools
########################################
export PATH=${WORK}/tools/bin:$PATH
mkdir -p ${WORK}/tools/bin

# cmake
if [ ! -d "${WORK}/tools/cmake" ]; then
  mkdir -p ${WORK}/tools/cmake && cd ${WORK}/tools/cmake && \
  wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERS}/cmake-${CMAKE_VERS}.tar.gz && \
  tar xf cmake-${CMAKE_VERS}.tar.gz && cd cmake-${CMAKE_VERS}
  ./bootstrap --prefix=${WORK}/tools --parallel=${PARALLEL_JOBS} -- -DCMAKE_USE_OPENSSL=OFF
  make -j${PARALLEL_JOBS} && make install
fi

# ninja
if [ ! -d "${WORK}/tools/ninja" ]; then
  mkdir -p ${WORK}/tools/ninja && cd ${WORK}/tools/ninja && \
  git clone https://github.com/ninja-build/ninja.git -b v1.10.2 . && \
  cmake -Bbuild-cmake -H. && cmake --build build-cmake && \
  cp build-cmake/ninja ${WORK}/tools/bin
fi

########################################
## Checkout
########################################
# newlib
if [ -d "$NEWLIB_SRC" ]; then
  echo "newlib dir already exists, skipping checkout"
else
  echo "checkout newlib"
  git clone --depth 1 -b newlib-3.3.0 https://sourceware.org/git/newlib-cygwin.git ${NEWLIB_SRC}
fi

# llvm: create symlink
ln -sf ${LLVM_SRC} ${WORK}/llvm-project

########################################
## Build info
########################################
cd ${WORK}
${SCRIPTSPATH}/../builder-info.sh

########################################
## Invoke the build-stage
########################################
export CCACHE_BUILD BUGURL PKGVERS BUILDNO PARALLEL_JOBS CC CXX

cd ${WORK}
exec ${SCRIPTSPATH}/build-riscv32-llvm.sh

exec ${SCRIPTSPATH}/tmp.sh



