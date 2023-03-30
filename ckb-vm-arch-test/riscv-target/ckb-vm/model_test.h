// RISC-V Compliance Test Header File
// Copyright (c) 2017, Codasip Ltd. All Rights Reserved.
// See LICENSE for license details.
//
// Description: Common header file for RV32I tests

#ifndef _COMPLIANCE_TEST_H
#define _COMPLIANCE_TEST_H

// #include "riscv_test.h"

//-----------------------------------------------------------------------
// RV IO Macros (Quiet)
//-----------------------------------------------------------------------

#define RVMODEL_IO_WRITE_STR(_SP, _STR)
#define RVMODEL_IO_ASSERT_GPR_EQ(_SP, _R, _I) \
  li _SP, _I;                                 \
  beq _R, _SP, 20002f;                        \
  li TESTNUM, 100;                            \
  RVTEST_FAIL;                                \
  20002:

//-----------------------------------------------------------------------
// RV Compliance Macros
//-----------------------------------------------------------------------

#define RVMODEL_BOOT \
  .macro init;       \
  .endm;             \
  .text;             \
  .global userstart; \
  userstart:         \
  init

#define RVMODEL_DATA_BEGIN

#define RVMODEL_DATA_END

#define RVMODEL_HALT \
  li a0, 0;          \
  li a7, 93;         \
  ecall;

#define RVMODEL_SET_MSW_INT
#define RVMODEL_CLEAR_MSW_INT
#define RVMODEL_CLEAR_MTIMER_INT
#define RVMODEL_CLEAR_MEXT_INT

#endif
