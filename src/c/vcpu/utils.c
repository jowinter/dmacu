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
#include <stdlib.h>
#include <string.h>

// Enable dumping of the ROM on Dmacu_DumpCpuState
#if !defined(DMACU_DUMP_ROM)
# define DMACU_DUMP_ROM (1)
#endif

//-----------------------------------------------------------------------------------------
///  \brief Host scratch area (for read/write tests to host memory)
///

// Obfuscates a byte on the host (for our test-ram message)
//
// We obfuscate be rotating right by 1 bit and XOR-ing with 0x5A
#define OBF_ROR1(x) ((((unsigned) (x) >> 1u) | ((unsigned) (x) << 7u)) & 0xFFu)
#define OBF_BYTE(x) (OBF_ROR1(x) ^ 0xC3u)

//-----------------------------------------------------------------------------------------
// Reference test message (obfuscated)
//
static volatile const uint8_t gkTestMessage[] =
{
    // Some string to (de-obfuscate)
	OBF_BYTE('H'),  OBF_BYTE('e'),  OBF_BYTE('l'),   OBF_BYTE('l'),  OBF_BYTE('o'),
	OBF_BYTE(' '),  OBF_BYTE('b'),  OBF_BYTE('r'),   OBF_BYTE('a'),  OBF_BYTE('v'),
	OBF_BYTE('e'),  OBF_BYTE(' '),  OBF_BYTE('n'),   OBF_BYTE('e'),  OBF_BYTE('w'),
	OBF_BYTE(' '),  OBF_BYTE('P'),  OBF_BYTE('L'),   OBF_BYTE('0'),  OBF_BYTE('8'),
	OBF_BYTE('0'),  OBF_BYTE(' '),  OBF_BYTE('D'),   OBF_BYTE('M'),  OBF_BYTE('A'),
	OBF_BYTE(' '),  OBF_BYTE('w'),  OBF_BYTE('o'),   OBF_BYTE('r'),  OBF_BYTE('l'),
	OBF_BYTE('d'),  OBF_BYTE('!'),  OBF_BYTE('\n'),  OBF_BYTE('\0')
};

//-----------------------------------------------------------------------------------------
DMACU_ALIGNED(0x1000)
static volatile uint8_t gTestRam[64u];

//-----------------------------------------------------------------------------------------
/// \brief Static test program
///
DMACU_ALIGNED(0x1000)
static const uint32_t gTestProgram[] =
{
	//-------------------------------------------------------------------------------------
	// Part 1: Loop around a bit
	//
	UINT32_C(0x01000008), // +0x000 MOV r0,    0x08
	UINT32_C(0x01010000), // +0x004 MOV r1,    0x00

	UINT32_C(0x0D000010), // +0x008 BEQ (+0x10) r0, #0x00
	UINT32_C(0x040000FF), // +0x00C ADD r0, r0, #0xFF
	UINT32_C(0x04010101), // +0x010 ADD r1, r1, #0x01
	UINT32_C(0x08000008), // +0x014 JMP #0x008

	UINT32_C(0x0C010408), // +0x018 BNE (+0x08) r1, #0x04
	UINT32_C(0x08000034), // +0x01C JMP #0x034
	UINT32_C(0x04000003), // +0x020 ADD r0, r0, #0x01
	UINT32_C(0x040101FF), // +0x024 ADD r1, r1, #0xFF
	UINT32_C(0x0E020000), // +0x028 NOT r2, r0
	UINT32_C(0x11030201), // +0x02C EOR r3, r2, r1
	UINT32_C(0x08000018), // +0x030 JMP #0x018

	//-------------------------------------------------------------------------------------
	// Part 2: Check for the 0xDE 0xAD 0xC0 0xDE pattern in r224-r227
	//
	UINT32_C(0x0CE0DE10), // +0x034 BNE (+0x10) r224, #0xDE
	UINT32_C(0x0CE1AD0C), // +0x038 BNE (+0x0C) r224, #0xDE
	UINT32_C(0x0CE2C008), // +0x03C BNE (+0x08) r224, #0xDE
	UINT32_C(0x0DE3DE08), // +0x040 BEQ (+0x08) r224, #0xDE
	UINT32_C(0x1F00E001), // +0x044 UND #0xE001 (Error Trap on mismatch)

	// ------------------------------------------------------------------------------------
	// Part 3: 'Decrypt' the test message in host RAM
	//

	// - Copy the lower 16-bit of the RAM base pointer r255:r254:r253:r252 to r17:r16
	//   We assume that our data-RAM lies within a single 64k segment and that we can
	//   use r255:r254:r17:r16 as source/destination pointer.
	//
	UINT32_C(0x0310FDFC), // +0x048 MOV2 r17:r16, r253:r252

	// - Load the XOR "key" (0xC3) in r2, load our loop increment (1) in r1
	UINT32_C(0x01010001), // +0x04C MOV r1, #0x01
	UINT32_C(0x010200C3), // +0x050 MOV r2, #0xC3

	// - Load the current byte into r3
	UINT32_C(0x1903FE10), // +0x054 LDB r3, [r255:r254:r17:r16]

	// - Deobfuscate (step 1) be XOR'ing with 0x5A, followed by a rotate left by 1
	UINT32_C(0x11030302), // +0x058 EOR r3, r2, r2
	UINT32_C(0x13030300), // +0x05C ROL r3, r3, #1

	// - Store the deobfuscated byte
	UINT32_C(0x1A03FE10), // +0x060 STB r3, [r255:r254:r17:r16]

	// - Stop if we have a NUL byte
	UINT32_C(0x0D030014), // +0x064 BEQ (+0x14) r3, #0x0

	// Increment our 16-bit offset in r17:r16 and resume
	UINT32_C(0x07041001), // +0x068 ACY r4,  r16, r1
	UINT32_C(0x06101001), // +0x06C ADD r16, r16, r1
	UINT32_C(0x06111104), // +0x070 ADD r17, r17, r4
	UINT32_C(0x08000050), // +0x074 JMP #0x050


	//------------------------------------------------------------------------------------
	// End of line :)
	//

	// And we are done
	UINT32_C(0x1F656E64) // +0x078 UND #0x656E64
};

//-----------------------------------------------------------------------------------------
void Dmacu_SetupTestProgram(Dmacu_Cpu_t *cpu)
{
	// Clear the CPU structure
	memset(cpu, 0, sizeof(Dmacu_Cpu_t));

	// Setup the initial program counter
	cpu->PC = (uint32_t) &gTestProgram[0];
	cpu->ProgramBase = cpu->PC;

	// Fill the register file with a test pattern
	//
	// The lower 224 registers (r0-r223) are cleared by the virtual CPU. The last
	// 32 register (r224-r255) are retained. We provide parameters through some of
	// those.
	//
	for (uint32_t i = 0u; i < 256u; ++i)
	{
		cpu->RegFile[i] = (i & 1u) ? 0xA5u : 0x5Au;
	}

	// Setup A, B and Z with dummy value (will be cleared by CPU)
	cpu->Operands.A = UINT16_C(0xBAD0);
	cpu->Operands.B = UINT16_C(0xBAD1);
	cpu->Operands.Z = UINT16_C(0xBAD2);

	// Pass a marker cookie in r224-r227
	cpu->RegFile[224u] = 0xDEu;
	cpu->RegFile[225u] = 0xADu;
	cpu->RegFile[226u] = 0xC0u;
	cpu->RegFile[227u] = 0xDEu;

	// Pass the address of the code memory in registers r251:r248
	//
	// currently unused, but this opens up space for self-modifying code shenanigans ;)
	const Dma_UIntPtr_t rom_base = Dma_PtrToAddr(&gTestProgram[0u]);
	cpu->RegFile[248u] = (uint8_t) (rom_base & 0xFFu);
	cpu->RegFile[249u] = (uint8_t) ((rom_base >> 8u)  & 0xFFu);
	cpu->RegFile[250u] = (uint8_t) ((rom_base >> 16u) & 0xFFu);
	cpu->RegFile[251u] = (uint8_t) ((rom_base >> 24u) & 0xFFu);

	// Pass the address of the test RAM in registers r255:r252
	const Dma_UIntPtr_t ram_base = Dma_PtrToAddr(&gTestRam[0u]);
	cpu->RegFile[252u] = (uint8_t) (ram_base & 0xFFu);
	cpu->RegFile[253u] = (uint8_t) ((ram_base >> 8u)  & 0xFFu);
	cpu->RegFile[254u] = (uint8_t) ((ram_base >> 16u) & 0xFFu);
	cpu->RegFile[255u] = (uint8_t) ((ram_base >> 24u) & 0xFFu);

    // Setup the test RAM
    for (uint32_t i = 0u; i < sizeof(gTestRam); ++i)
    {
        gTestRam[i] = (i < sizeof(gkTestMessage)) ? gkTestMessage[i] : 0u;
    }
}

//-----------------------------------------------------------------------------------------
void Dmacu_RunTestProgram(void)
{
	Dmacu_Cpu_t *const cpu = Dmacu_GetCpu();

	// Setup the test program
	Dmacu_SetupTestProgram(cpu);

	// Dump the initial CPU state (after test program setup)
#if !DMACU_QUIET
	Dmacu_DumpCpuState("vcpu[init]", cpu);
#endif

	// And run the DMA transfer for the test program
	Hal_DmaTransfer(Dmacu_CpuBootDescriptor());

#if !DMACU_QUIET
	// Dump the virtual CPU state on exit.
	printf("vcpu[run] dma transfers done (virtual cpu is stopped)\n");
	Dmacu_DumpCpuState("vcpu[exit]", cpu);
#endif

	// I am feeling lucky :)
	for (unsigned i = 0u; i < sizeof(gTestRam); ++i)
	{
		volatile const uint8_t c = gTestRam[i];
		if (c == '\0')
		{
			break;
		}

#if !DMACU_QUIET
		// Print the test character
		putchar(c);
#endif

		// Check that the test message has been deobfuscated correctly
		if (i < sizeof(gkTestMessage))
		{
			if (OBF_BYTE(c) != gkTestMessage[i])
			{
				abort();
			}
		}
	}


}

//-----------------------------------------------------------------------------------------
void Dmacu_DumpCpuState(const char *prefix, const Dmacu_Cpu_t *cpu)
{
#if !DMACU_QUIET
	printf("%s        PC: %08X  NextPC: %08X Base: %08X\n"
		"%s       OPC: %08X\n"
		"%s        rA: %04X  rB: %04X  rZ: %04X\n",
	    prefix, (unsigned) cpu->PC, (unsigned) cpu->NextPC, (unsigned) cpu->ProgramBase,
		prefix, (unsigned) cpu->CurrentOPC.Value,
		prefix, (unsigned) cpu->Operands.A,
		(unsigned) cpu->Operands.B, (unsigned) cpu->Operands.Z);

	printf("%s  =========================================================\n", prefix);

	// Register file
	const unsigned num_regs = 256u;

	for (unsigned i = 0u; i < num_regs; i += 16u)
	{
		const unsigned line_len = (num_regs - i) > 16u ? 16u : (num_regs - i);

		printf("%s  REGS[%02X]:", prefix, (unsigned) i);

		for (unsigned j = 0u; j < line_len; ++j)
		{
			printf(" %02X", (unsigned) cpu->RegFile[i + j]);
		}

		printf("\n");
	}

	printf("%s  =========================================================\n", prefix);

	// Test RAM
	for (unsigned i = 0u; i < sizeof(gTestRam); i += 16u)
	{
		const unsigned line_len = (sizeof(gTestRam) - i) > 16u ?
			16u :  (sizeof(gTestRam) - i);

		printf("%s  RAM[%03X]:", prefix, (unsigned) i);

		// Hexdump
		for (unsigned j = 0u; j < line_len; ++j)
		{
			printf(" %02X", (unsigned) gTestRam[i + j]);
		}

		for (unsigned j = line_len; j < 16u; ++j)
		{
			printf("   ");
		}

		// ASCII dump
		printf("  ");

		for (unsigned j = 0u; j < line_len; ++j)
		{
			uint8_t c = gTestRam[i + j];
			printf("%c", (c >= 0x20u && c <= 0x7Eu) ? c : '.');
		}

		printf("\n");
	}

# if DMACU_DUMP_ROM
	printf("%s  =========================================================\n", prefix);

	// Test ROM
	const uint32_t *const rom_data = &gTestProgram[0u];
	const size_t rom_size = sizeof(gTestProgram) / sizeof(uint32_t);

	for (unsigned i = 0u; i < rom_size; i += 4u)
	{
		const unsigned line_len = (rom_size - i) > 4u ? 4u :  (rom_size - i);

		printf("%s  ROM[%03X]:", prefix, (unsigned) i);

		// Hexdump
		for (unsigned j = 0u; j < line_len; ++j)
		{
			const uint32_t w = rom_data[i + j];
			printf(" %02X_%06X", (unsigned) ((w >> 24u) & 0xFFu),
				(unsigned) (w & 0x00FFFFFFu));
		}

		printf("\n");
	}
# endif
#else
	// Quiet mode
	(void) prefix;
	(void) cpu;
#endif
}
