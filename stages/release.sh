#!/bin/bash -ex
# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

VERSION=0.2.0

WORKDIR=${PWD}
OUTDIR=${WORKDIR}/.release
PARALLEL_JOBS=$(expr $(nproc) - 1)

# Specify versions to use
NEWLIB_VERSION=3.3.0
LLVM_VERSION=12.0.1-${VERSION}

# Build variables
BUGURL=https://github.com/pulp-platform/llvm-project/issues
TRIPLE=riscv32-pulp-llvm
# LLVM_VERSION_SUFFIX is set to "-${BUILDNO}"
BUILDNO=${VERSION}

# All OSes to build
OSes="ubuntu1804 ubuntu2004 centos7" # ubuntu1804 ubuntu2004 centos7

# prepare
mkdir -p ${OUTDIR}
echo "---------------------------" >> ${OUTDIR}/buildlog.txt
echo "VERSION       $VERSION" >> ${OUTDIR}/buildlog.txt
echo "OSes          $OSes" >> ${OUTDIR}/buildlog.txt
echo "LLVM_VERSION  $LLVM_VERSION" >> ${OUTDIR}/buildlog.txt

# For each OS, build the toolchain
oldpwd=${PWD}
for os in $OSes; do
  # Temp dir
  tmpdir=$(mktemp -d -p .); cd ${tmpdir}

  # shallow-clone newlib and llvm
  git clone --depth 1 -b newlib-${NEWLIB_VERSION} https://sourceware.org/git/newlib-cygwin.git newlib
  git clone --depth 1 -b ${LLVM_VERSION} https://github.com/pulp-platform/llvm-project.git llvm-project

  # Build builder container
  docker build -t linux-${os}:latest -f ${WORKDIR}/docker/linux-${os}.Dockerfile .

  # Copy compile script to working directory
  cp -r ${WORKDIR}/stages/build-riscv32-llvm.sh .

  # Compile toolchain
  PKGVERS=${TRIPLE}-${os}-${VERSION}
  docker run -v $PWD:/home/builder -w/home/builder \
              -e BUGURL=${BUGURL} \
              -e PKGVERS=${PKGVERS} \
              -e BUILDNO=${BUILDNO} \
              -e PARALLEL_JOBS=${PARALLEL_JOBS} \
              linux-${os}:latest \
              ./build-riscv32-llvm.sh

  # Check version
  echo ">>> Version for OS $os" >> ${OUTDIR}/buildlog.txt
  PKGVERS=${TRIPLE}-${os}-${VERSION}
  docker run -v $PWD:/home/builder -w/home/builder \
              linux-${os}:latest \
              /bin/bash -c "install/bin/clang --version; install/bin/llvm-config --version" >> ${OUTDIR}/buildlog.txt

  # Package
  tar -czf ${OUTDIR}/${PKGVERS}.tar.gz --transform s/^install/${PKGVERS}/ install

  # exit and cleanup
  docker run -v $PWD:/home/builder -w/home/builder linux-${os}:latest /bin/bash -c "rm -rf build install"
  cd ${oldpwd}
  rm -rf ${tmpdir}
done
