// Copyright 2020 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <math.h>
#include <stdint.h>

#include "runtime.h"

double a[] = {
    9.87957, 0.76361, 1.92350, 3.31029, 4.64391, 0.33633, 8.22777, 1.09329,
    5.48665, 8.07353, 9.19152, 6.54444, 3.39617, 9.75520, 7.45724, 9.90991,
    4.92665, 5.36584, 5.75906, 0.38286, 1.42689, 0.10349, 1.38974, 0.51854,
    1.78653, 1.43312, 0.59034, 8.82015, 5.21160, 2.46770, 5.61629, 0.38372,
    0.01497, 1.05681, 7.06303, 5.52349, 6.66679, 6.10840, 0.72574, 2.55895,
    7.61432, 4.22704, 0.58031, 8.99678, 7.01309, 7.16766, 1.08788, 1.86662,
    0.69033, 1.11527, 6.45116, 0.80681, 4.89204, 4.65959, 5.80887, 9.61203,
    8.50464, 8.76233, 7.69522, 5.25883, 5.33701, 3.86605, 5.92785, 5.24590,
    7.50100, 7.45780, 5.58294, 7.67555, 0.08918, 7.67551, 2.95690, 4.27648,
    4.37957, 6.41490, 5.45136, 5.04900, 8.37637, 3.32522, 0.19275, 0.90027,
    5.26596, 2.03007, 6.04238, 0.37655, 6.27973, 7.06765, 7.31196, 2.81277,
    7.16916, 0.35020, 8.40078, 8.04364, 2.37121, 3.87851, 1.46990, 8.53576,
    9.71557, 7.98632, 3.93410, 7.17218, 2.47357, 1.02690, 7.41347, 9.00657,
    4.74055, 0.56681, 2.62019, 4.93100, 8.79415, 2.61169, 5.99752, 6.08666,
    9.11149, 9.60711, 4.52834, 9.67083, 9.98518, 4.66366, 2.48188, 6.97444,
    8.51605, 1.47609, 8.33533, 6.83211, 2.22509, 7.43315, 9.27465, 8.68127};
double b[] = {
    3.17193, 0.56445, 4.70815, 2.30186, 6.22174, 8.95495, 6.23825, 8.64667,
    5.90501, 8.08540, 6.90432, 8.45603, 0.28403, 0.01927, 7.10892, 1.04576,
    4.25395, 1.54150, 1.57806, 3.89246, 9.41121, 0.16884, 7.64968, 7.72653,
    7.07554, 9.18972, 1.20371, 8.93737, 9.23332, 1.09930, 8.71192, 4.23277,
    5.28872, 7.20588, 0.42378, 3.03004, 8.62159, 8.40955, 6.44737, 2.32708,
    1.36173, 5.94384, 2.05287, 2.45843, 8.61261, 2.96539, 5.80244, 4.70926,
    4.36387, 2.65796, 5.78765, 0.02764, 4.38930, 1.80289, 0.50809, 1.79935,
    4.22885, 8.45988, 7.77560, 8.50298, 0.60291, 0.96880, 7.32851, 3.09969,
    6.56695, 9.47405, 8.21668, 5.37348, 9.10398, 5.30067, 4.25040, 1.82270,
    6.37013, 7.85226, 9.87624, 6.80096, 9.61616, 0.15611, 3.23257, 2.87163,
    7.20996, 6.34202, 5.68770, 0.22086, 6.26068, 3.54714, 8.55146, 9.63954,
    0.31281, 8.84818, 2.84800, 7.71096, 5.70680, 6.64748, 6.15650, 9.29994,
    1.07531, 0.12329, 1.75989, 4.27991, 4.74600, 2.09810, 1.60349, 7.37589,
    8.07277, 7.95074, 5.44481, 6.80122, 6.41803, 4.41954, 7.13046, 7.10546,
    3.72063, 3.25250, 8.22048, 1.59769, 5.90020, 8.74649, 8.89372, 2.10221,
    6.25197, 8.74987, 2.21549, 8.05250, 9.75747, 0.89519, 5.92540, 6.42636};
double gold = 3270.822815090598;

int nested_1(void) {
  uint32_t instRet;

  /**
   * Nested FREP loop
   */
  
  double sum = 0.0;

  __builtin_ssr_setup_bound_stride_1d(0, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(0, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(0,0);
  __builtin_ssr_setup_bound_stride_1d(1, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(1, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(1,0);
  __builtin_ssr_read(0, 2-1, a);
  __builtin_ssr_read(1, 2-1, b);

  __builtin_ssr_enable();
  instRet = read_csr(minstret);

  for (int i = 0; i < 8; ++i) {
    #pragma frep infer
    for (unsigned i = 0; i < 128; ++i) {
      // a freppable loop
      sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);
    }
  }

  __builtin_ssr_disable();
  instRet = read_csr(minstret) - instRet;

  // should have not retired more than 
  // 8*(1+1+128+1+1+1) (li, frep, 128*fmadd, fmv, addi, bne)
  if (instRet > 8*(1+1+128+1+1+1) + 10) return 1;
  if (fabs(sum - 8.0*gold) > 0.001) return 2;
  return 0;
}

int nested_2(void) {
  uint32_t instRet;

  /**
   * Nested FREP loop with unrolled outer loop
   */
  
  double sum = 0.0;

  __builtin_ssr_setup_bound_stride_1d(0, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(0, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(0,0);
  __builtin_ssr_setup_bound_stride_1d(1, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(1, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(1,0);
  __builtin_ssr_read(0, 2-1, a);
  __builtin_ssr_read(1, 2-1, b);

  __builtin_ssr_enable();
  instRet = read_csr(minstret);

  #pragma unroll
  for (int j = 0; j < 8; ++j) {
    #pragma frep infer
    for (unsigned i = 0; i < 128; ++i) {
      // a freppable loop
      sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);
    }
  }

  __builtin_ssr_disable();
  instRet = read_csr(minstret) - instRet;

  // should have not retired more than 
  // 8*(1+1+128+1) (li, frep, 128*fmadd, fmv, addi, bne)
  if (instRet > 8*(1+1+128+1) + 10) return 3;
  if (fabs(sum - 8.0*gold) > 0.001) return 4;
  return 0;
}

int nested_3(void) {
  uint32_t instRet;

  /**
   * Double-nested FREP loop
   */
  
  double sum = 0.0;

  __builtin_ssr_setup_bound_stride_1d(0, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(0, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(0,0);
  __builtin_ssr_setup_bound_stride_1d(1, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(1, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(1,0);
  __builtin_ssr_read(0, 2-1, a);
  __builtin_ssr_read(1, 2-1, b);

  __builtin_ssr_enable();
  instRet = read_csr(minstret);

  for (int j = 0; j < 2; ++j) {
    for (int k = 0; k < 4; ++k) {
      #pragma frep infer
      for (unsigned i = 0; i < 128; ++i) {
        // a freppable loop
        sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);
      }
    }
  }

  __builtin_ssr_disable();
  instRet = read_csr(minstret) - instRet;

  // should have not retired more than 
  // 8*(li, frep, 128*fmadd, fmv, j) 4*(addi, beq, mv) + 2*(adi, bnez)
  if (instRet > 8*(1+1+128+1+1) + 4*3 + 2*2 + 20) return 5;
  if (fabs(sum - 8.0*gold) > 0.001) return 6;
  return 0;
}

int nested_4(void) {
  uint32_t instRet;

  /**
   * Double-nested FREP loop with unrolling
   */
  
  double sum = 0.0;

  __builtin_ssr_setup_bound_stride_1d(0, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(0, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(0,0);
  __builtin_ssr_setup_bound_stride_1d(1, 128-1, 8);
  __builtin_ssr_setup_bound_stride_2d(1, 8-1, -8*(128-1));
  __builtin_ssr_setup_repetition(1,0);
  __builtin_ssr_read(0, 2-1, a);
  __builtin_ssr_read(1, 2-1, b);

  __builtin_ssr_enable();
  instRet = read_csr(minstret);

  for (int j = 0; j < 2; ++j) {
    #pragma unroll
    for (int k = 0; k < 4; ++k) {
      #pragma frep infer
      for (unsigned i = 0; i < 128; ++i) {
        // a freppable loop
        sum += __builtin_ssr_pop(0) * __builtin_ssr_pop(1);
      }
    }
  }

  __builtin_ssr_disable();
  instRet = read_csr(minstret) - instRet;

  // should have not retired more than 
  // 8*(li, frep, 128*fmadd, fmv, j) 2*(addi, beq, mv)
  if (instRet > 8*(1+1+128+1) + 2*3 + 10) return 7;
  if (fabs(sum - 8.0*gold) > 0.001) return 8;
  return 0;
}

int main(void) {
  int ret;

  ret = nested_1();
  if(ret) return ret;

  ret = nested_2();
  if(ret) return ret;

  ret = nested_3();
  if(ret) return ret;

  ret = nested_4();
  if(ret) return ret;
  
  /// All is well
  return 0;
}
