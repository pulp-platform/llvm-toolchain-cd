// Copyright 2020 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "runtime.h"

static double x[8] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
static double y[8] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
static double gold = 204.0;

int main() {
  double sum = 0.0;  // 204

  asm volatile(
      // "scfgw %[val], %[addr]"
      "addi   t0, x0, 12\n"
      "scfgwi t0, 1<<5\n"  // write t0 to location in immediate
      "scfgri t0, 1<<5\n"  // read from immediate location to t0

      "addi   t0, x0, 25\n"
      "scfgwi t0, 2<<5\n"  // write t0 to location in immediate
      "scfgri t0, 2<<5\n"  // read from immediate location to t0

      "li     t1, 0x204800\n"
      // "addi   t1, x0, 0x805\n"
      "lw     t0, 8(t1)\n" ::[val] "r"(3),
      [addr] "r"(8));

  asm volatile(
      // configure ssr to read from x and y
      "li     t0, 8-1\n"           // bound
      "scfgwi t0, 0x0 | 2<<5\n"    // val, adr
      "scfgwi t0, 0x1 | 2<<5\n"    // val, adr
      "li     t0,    8\n"          // stride
      "scfgwi t0, 0x0 | 6<<5\n"    // val, adr
      "scfgwi t0, 0x1 | 6<<5\n"    // val, adr
      "li     t0,    0\n"          // repeat
      "scfgwi t0, 0x0 | 1<<5\n"    // val, adr
      "scfgwi t0, 0x1 | 1<<5\n"    // val, adr
      "li     t0,  0x0 | 24<<5\n"  // rptr0
      "scfgw  %[x], t0\n"          // val, adr
      "li     t0,  0x1 | 24<<5\n"  // rptr0
      "scfgw  %[y], t0\n"          // val, adr

      "fld    ft0, 0(%[x])\n"
      "fld    ft0, 8(%[x])\n"
      "fld    ft0, 16(%[x])\n"

      "csrsi  0x7C0, 1\n"  // ssr enable
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "fmadd.d %[sum], ft0, ft1, %[sum]\n"
      "csrci  0x7C0, 1\n"  // ssr disable

      : [sum] "+f"(sum)
      : [x] "r"(x), [y] "r"(y)
      : "ft0", "ft1", "t0");

  return (gold - sum) * (gold - sum) > 0.001;
}
