//
// Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
//
// This file implements a minimalistic model of the PL080 DMA controller.
//
// Copyright (c) 2019-2022 Johannes Winter
//
// This file is licensed under the MIT License. See LICENSE in the root directory
// of the prohect for the license text.
//
// FIXME: This currently requires a 32-bit CPU (build with "-m32") :(
//
// Typical build: gcc -m32 -Wall -pedantic -std=c99 dmacu_standalone_emu.c -x assembler-with-cpp dmacu_pl080.s
//
// Note: This MAY (read: worked once, likely to break in funny ways, expect the bugs to invade) on 64-bit systems with:
//  gcc -no-pie -Wall -pedantic -std=c99 dmacu_standalone_emu.c -x assembler-with-cpp dmacu_pl080.s
//   The no-pie option allows  R_X86_64_32 to work, which helps us :)
//

#ifndef PL080_H_
#define PL080_H_ 1

#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

/// \brief Simplified PL080 channel emulation
typedef struct
{
	uint32_t src_addr;
	uint32_t dst_addr;
	uint32_t lli;
	uint32_t control;
	uint32_t config;
} PL080_Channel_t;

#define PL080_CH_CTRL_SIZE_MASK UINT32_C(0x00000FFF)
#define PL080_CH_CTRL_SIZE_POS  UINT32_C(0)
#define PL080_CH_CONFIG_E       UINT32_C(0x00000001)

#define PL080_CH_CTRL_DWIDTH_MASK UINT32_C(0x00E00000)
#define PL080_CH_CTRL_DWIDTH_POS  UINT32_C(21)

#define PL080_CH_CTRL_SWIDTH_MASK UINT32_C(0x001C0000)
#define PL080_CH_CTRL_SWIDTH_POS  UINT32_C(18)

/// \brief Processes a transfer descriptor on a PL080 DMA channel
///
/// \param[in,out] ch points to the emulated PL080 DMA channel to be updated.
///
/// \return True if the channel made progress, false if the channel is idle.
extern bool PL080_Channel_Process(PL080_Channel_t *ch);

#endif // PL080_H_
