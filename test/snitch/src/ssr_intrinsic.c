// Copyright 2020 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
#include "encoding.h"

static double x[8] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
static double y[8] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
static double z[8];
static double gold = 204.0;

int pop() {
  double sum = 0.0, a, b;

  /**
   *  Pop only
   */

  __builtin_ssr_setup_1d_r(0, /*rep*/ 0, /*bound*/ 8 - 1, /*stride*/ 8,
                           /*data*/ x);
  __builtin_ssr_setup_1d_r(1, /*rep*/ 0, /*bound*/ 8 - 1, /*stride*/ 8,
                           /*data*/ y);

  __builtin_ssr_enable();

  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;
  sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);  //++ctr;

  __builtin_ssr_disable();

  if (sum != gold) return -1;
  return 0;
}

int push() {
  int sum;
  double a = 0.0;
  /**
   *  Pop and Push
   */
  __builtin_ssr_setup_1d_w(0, /*rep*/ 0, /*bound*/ 8 - 1, /*stride*/ 8,
                           /*data*/ z);

  __builtin_ssr_enable();
  for (int i = 0; i < 8; ++i)
  {
    a += 1.0;
    __builtin_ssr_push(0, a);
  }

  // SSR barrier
  asm volatile(
    "1: \n"
    "scfgri t0, 0\n"        // reat status word
    "srli   t0, t0, 31\n"   // extract done bit 31
    "beqz   t0, 1b\n"       // repeat if done bit not set
    ::: "t0");

  __builtin_ssr_disable();

  sum = 0;
  for(unsigned i = 0; i < 8; ++i) sum += x[i] != z[i] ? 1 : 0;
  return sum;
}

int poppush() {
  double buf;  // 204
  int sum;

  /**
   *  Pop and Push
   */
  __builtin_ssr_setup_1d_r(0, /*rep*/ 0, /*bound*/ 8 - 1, /*stride*/ -8,
                           /*data*/ &x[7]);
  __builtin_ssr_setup_1d_w(1, /*rep*/ 0, /*bound*/ 8 - 1, /*stride*/ 8,
                           /*data*/ z);

  __builtin_ssr_enable();
  for(unsigned i = 0; i < 8; ++i) {
    __builtin_ssr_push(1, __builtin_ssr_pop(0));
  }

  // SSR barrier
  asm volatile(
    "1: \n"
    "scfgri t0, 0\n"        // reat status word
    "srli   t0, t0, 31\n"   // extract done bit 31
    "beqz   t0, 1b\n"       // repeat if done bit not set
    ::: "t0");

  __builtin_ssr_disable();

  sum = 0;
  for(unsigned i = 0; i < 8; ++i) sum += x[7-i] != z[i] ? 1 : 0;
  return sum;
}

int main() {
  if(read_csr(mhartid) != 0) while(1);

  if(pop()) return 1;
  if(push()) return 2;
  if(poppush()) return 3;
  return 0;
}
