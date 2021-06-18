# snitch-toolchain-cd

Continuous delivery of the Snitch LLVM toolchain.

## Download

| Name | OS | Download | Status |
|------|----|------|--------|
| riscv32-snitch-llvm-centos7.tar.gz | CentOS 7 | [link](https://sourceforge.net/projects/snitch-llvm/files/nightly/riscv32-snitch-llvm-centos7.tar.gz/download) | [![riscv32-llvm-centos7](https://github.com/pulp-platform/snitch-toolchain-cd/actions/workflows/riscv32-llvm-centos7.yml/badge.svg)](https://github.com/pulp-platform/snitch-toolchain-cd/actions/workflows/riscv32-llvm-centos7.yml) |
| riscv32-snitch-llvm-ubuntu2004.tar.gz | Ubuntu 20.04 | [link](https://sourceforge.net/projects/snitch-llvm/files/nightly/riscv32-snitch-llvm-ubuntu2004.tar.gz/download) | [![riscv32-llvm-ubuntu2004](https://github.com/pulp-platform/snitch-toolchain-cd/actions/workflows/riscv32-llvm-ubuntu2004.yml/badge.svg)](https://github.com/pulp-platform/snitch-toolchain-cd/actions/workflows/riscv32-llvm-ubuntu2004.yml) |

## Tagging a new release

Naming scheme: `12.0.0-snitch-0.1.0-rc1`

- Create a new tag in [snitch-llvm][snitch-llvm]
- Build for all releases using `stages/release.sh`
- Upload artifacts to the release
- Create release notes
```bash
last_tag=12.0.0-snitch-0.1.0-rc1
new_tag=12.0.0-snitch-0.1.0-rc2
echo "## Changes since last release"
echo "Last release: \`$last_tag\`"
git --no-pager log $last_tag..$new_tag --format="- %C(auto) %h %s"
```

- Trigger a new run of `build-docker` in [snitch][snitch] so that the docker container contains newest release or manually in the `snitch` repo
```bash
docker build -t snitch -f util/container/Dockerfile .
docker tag snitch ghcr.io/pulp-platform/snitch:0.1.0-rc1
```

[snitch-llvm]: https://github.com/pulp-platform/snitch-llvm
[snitch]: https://github.com/pulp-platform/snitch
