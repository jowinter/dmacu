/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file utils.c
 * @brief Utilities for working with the DMACU virtual CPU
 */
#include "dmacu.h"

#include <stdio.h>

//-----------------------------------------------------------------------------------------
///  \brief Static test program
///
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

//-----------------------------------------------------------------------------------------
void Dmacu_SetupTestProgram(Dmacu_Cpu_t *cpu)
{
	// Setup the initial program counter
	cpu->PC = (uint32_t) &gTestProgram[0];

	// Fill the register file with a test pattern
	for (uint32_t i = 0u; i < 256u; ++i)
	{
		cpu->RegFile[i] = (uint8_t) i;
	}

	// Setup A, B and Z with dummy value (will be cleared by CPU)
	cpu->Operands.A = UINT16_C(0xBAD0);
	cpu->Operands.B = UINT16_C(0xBAD1);
	cpu->Operands.Z = UINT16_C(0xBAD2);
}

//-----------------------------------------------------------------------------------------
void Dmacu_DumpCpuState(const char *prefix, const Dmacu_Cpu_t *cpu)
{
	printf("%s        PC: %08X  NextPC: %08X Base: %08X\n"
		"%s       OPC: %08X\n"
		"%s        rA: %04X  rB: %04X  rZ: %04X",
	    prefix, (unsigned) cpu->PC, (unsigned) cpu->NextPC, (unsigned) cpu->ProgramBase,
		prefix, (unsigned) cpu->CurrentOPC.Value,
		prefix, (unsigned) cpu->Operands.A, (unsigned) cpu->Operands.B, (unsigned) cpu->Operands.Z);

	for (unsigned i = 0u; i < 256u; ++i)
	{
		if ((i % 16u) == 0u)
		{
			printf("\n%s  REGS[%02X]:", prefix, (unsigned) i);
		}

		printf(" %02X", (unsigned) cpu->RegFile[i]);
	}

	printf("\n");
}
