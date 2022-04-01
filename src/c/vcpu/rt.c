/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file rt.c
 * @brief Runtime-Environment (and startup code)
 */
#include "dmacu.h"

#include <stdlib.h>


//----------------------------------------------------------------------
// Static test program
static const uint32_t gTestProgram[] =
{
	UINT32_C(0x01000008), // +0x000 MOV r0,    0x08
	UINT32_C(0x01010000), // +0x004 MOV r1,    0x00

	UINT32_C(0x0D000010), // +0x008 BEQ (+0x10) r0, #0x00
	UINT32_C(0x040000FF), // +0x00C ADD r0, r0, #0xFF
	UINT32_C(0x04010101), // +0x010 ADD r1, r1, #0x01
	UINT32_C(0x08000008), // +0x014 JMP #0x008

	UINT32_C(0x0C010408), // +0x018 BNE (+0x08) r1, #0x04
	UINT32_C(0x1F00DEAD), // +0x020 UND #0x00DEAD
	UINT32_C(0x04000003), // +0x024 ADD r0, r0, #0x01
	UINT32_C(0x040101FF), // +0x028 ADD r1, r1, #0xFF
	UINT32_C(0x0E020000), // +0x02C NOT r2, r0
	UINT32_C(0x11030201), // +0x030 EOR r3, r2, r1
	UINT32_C(0x08000018), // +0x034 JMP #0x018
};

//-------------------------------------------------------------------------------------------------
int main(void)
{
	// HAL-level initialization
	Hal_Init();

	// And run our test-program
	Dmacu_Run(&gTestProgram[0u]);

	return EXIT_SUCCESS;
}
