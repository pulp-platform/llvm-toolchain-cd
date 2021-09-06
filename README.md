# llvm-toolchain-cd

Continuous delivery of the PULP LLVM toolchain.

## Download

| Name                                | OS           | Download  | Status                            |
|:------------------------------------|:-------------|:----------|:----------------------------------|
| riscv32-pulp-llvm-centos7.tar.gz    | CentOS 7     | [link][1] | [![riscv32-llvm-centos7][3]][5]   |
| riscv32-pulp-llvm-ubuntu2004.tar.gz | Ubuntu 20.04 | [link][2] | [![riscv32-llvm-ubuntu2004][4]][6] |

[1]: https://sourceforge.net/projects/pulp-llvm-project/files/nightly/riscv32-pulp-llvm-centos7.tar.gz/download
[2]: https://sourceforge.net/projects/pulp-llvm-project/files/nightly/riscv32-pulp-llvm-ubuntu2004.tar.gz/download
[3]: https://github.com/pulp-platform/llvm-toolchain-cd/actions/workflows/riscv32-llvm-centos7.yml/badge.svg
[4]: https://github.com/pulp-platform/llvm-toolchain-cd/actions/workflows/riscv32-llvm-ubuntu2004.yml/badge.svg
[5]: https://github.com/pulp-platform/llvm-toolchain-cd/actions/workflows/riscv32-llvm-centos7.yml
[6]: https://github.com/pulp-platform/llvm-toolchain-cd/actions/workflows/riscv32-llvm-ubuntu2004.yml

## Tagging a new release

Naming scheme: `12.0.1-0.1.0`

- Create a new tag in [llvm-project][llvm-project]
- Build for all releases using `stages/release.sh`
- Upload artifacts to the release
- Create release notes
```bash
last_tag=12.0.1-0.1.0
new_tag=12.0.1-0.2.0
echo "## Changes since last release"
echo "Last release: \`$last_tag\`"
git --no-pager log $last_tag..$new_tag --format="- %C(auto) %h %s"
```

- Trigger a new run of `build-docker` in [snitch][snitch] so that the docker container contains newest release or manually in the `snitch` repo
```bash
docker build -t snitch -f util/container/Dockerfile .
docker tag snitch ghcr.io/pulp-platform/snitch:0.1.0-rc1
```

## Development
For working on LLVM we suggest configuring LLVM with these settings (choose `CMAKE_BUILD_TYPE="Debug"` for enabling `gdb` debugging.)

```bash
INSTALLPREFIX=$(pwd)/install
mkdir -p build-llvm install; cd build-llvm
cmake \
    -DCMAKE_BUILD_TYPE="Release" -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_INSTALL_PREFIX=${INSTALLPREFIX} \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_TARGETS_TO_BUILD="RISCV" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
    -DLLVM_ENABLE_LLD=True -DLLVM_APPEND_VC_REV=OFF \
    -G Ninja ../llvm
ninja
ninja install
```

Compile and build `newlib`

```bash
git clone --depth 1 -b newlib-3.3.0 https://sourceware.org/git/newlib-cygwin.git newlib
mkdir build-newlib; cd build-newlib
../newlib/configure                                    \
    --target=riscv32-unknown-elf                       \
    --prefix=${INSTALLPREFIX}                                   \
    AR_FOR_TARGET=${INSTALLPREFIX}/bin/llvm-ar                  \
    AS_FOR_TARGET=${INSTALLPREFIX}/bin/llvm-as                  \
    LD_FOR_TARGET=${INSTALLPREFIX}/bin/llvm-ld                  \
    RANLIB_FOR_TARGET=${INSTALLPREFIX}/bin/llvm-ranlib          \
    CC_FOR_TARGET="${INSTALLPREFIX}/bin/clang -march=rv32imafd"
make -j$(nproc)
make install
```

Compile and build `compiler-rt`

```bash
mkdir build-crt; cd build-crt
cmake -G"Unix Makefiles"                                                     \
    -DCMAKE_SYSTEM_NAME=Linux                                                \
    -DCMAKE_INSTALL_PREFIX=$(${INSTALLPREFIX}/bin/clang -print-resource-dir) \
    -DCMAKE_C_COMPILER=${INSTALLPREFIX}/bin/clang                            \
    -DCMAKE_CXX_COMPILER=${INSTALLPREFIX}/bin/clang                          \
    -DCMAKE_AR=${INSTALLPREFIX}/bin/llvm-ar                                  \
    -DCMAKE_NM=${INSTALLPREFIX}/bin/llvm-nm                                  \
    -DCMAKE_RANLIB=${INSTALLPREFIX}/bin/llvm-ranlib                          \
    -DCMAKE_C_COMPILER_TARGET="riscv32-unknown-elf"                          \
    -DCMAKE_CXX_COMPILER_TARGET="riscv32-unknown-elf"                        \
    -DCMAKE_ASM_COMPILER_TARGET="riscv32-unknown-elf"                        \
    -DCMAKE_C_FLAGS="-march=rv32imafd -mabi=ilp32d"                          \
    -DCMAKE_CXX_FLAGS="-march=rv32imafd -mabi=ilp32d"                        \
    -DCMAKE_ASM_FLAGS="-march=rv32imafd -mabi=ilp32d"                        \
    -DCMAKE_EXE_LINKER_FLAGS="-nostartfiles -nostdlib -fuse-ld=lld"          \
    -DCOMPILER_RT_BAREMETAL_BUILD=ON                                         \
    -DCOMPILER_RT_BUILD_BUILTINS=ON                                          \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF                                          \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF                                        \
    -DCOMPILER_RT_BUILD_PROFILE=OFF                                          \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF                                       \
    -DCOMPILER_RT_BUILD_XRAY=OFF                                             \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON                                     \
    -DCOMPILER_RT_OS_DIR=""                                                  \
    -DLLVM_CONFIG_PATH=${INSTALLPREFIX}/bin/llvm-config                      \
    ../../compiler-rt
make
make install
```

[llvm-project]: https://github.com/pulp-platform/llvm-project
[snitch]: https://github.com/pulp-platform/snitch
