// Copyright 2020 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

static double x[8] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
static double y[8] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
static double gold = 204.0;

int main() {
  double sum = 0.0;  // 204
  // volatile unsigned ctr = 0;

  // __builtin_ssr_setup_1d(0,rep 0,/*bound*/ 8-1, /*stride*/ 8, /*data*/ x);
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

  if (sum != gold) return (int)sum;
  return 0;
}
