# Dockerfile for a simple Ubuntu with the Snitch LLVM toolchain

FROM ubuntu:20.04

# Pass this variable to indicate the toolchain tar
ARG TCTAR

LABEL maintainer huettern@ethz.ch

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y git build-essential git python python3 python3-distutils

# Copy-in toolchain tar
RUN ls -al; pwd
COPY ./${TCTAR} /tmp/toolchain.tar.gz

# The user running
RUN useradd -m -u 1002 builder
USER builder

# Extract toolchain, cleanup and modify path
RUN cd /home/builder && mkdir -p .local/riscv32-snitch-llvm && \
  tar xzf /tmp/toolchain.tar.gz -C .local/riscv32-snitch-llvm --strip-components 1 && \
  .local/riscv32-snitch-llvm/bin/clang --version

ENV PATH "/home/builder/.local/riscv32-snitch-llvm/bin:${PATH}"

WORKDIR /home/builder
