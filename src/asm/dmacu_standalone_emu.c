/*
 * Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
 *
 * This file implements a minimalistic standalone emulator that is runnable
 * on non-ARM systems.
 *
 * Copyright (c) 2019-2020 Johannes Winter
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the prohect for the license text.
 *
 * FIXME: This currently requires a 32-bit CPU :(
 *
 * Typical build: gcc -m32 -Wall -pedantic -std=c99 dmacu_standalone_emu.c -x assembler-with-cpp dmacu_pl080.s
 *
 * Note: This MAY (read: worked once, likely to break in funny ways, expect the bugs to invade) on 64-bit systems with:
 *  gcc -no-pie -Wall -pedantic -std=c99 dmacu_standalone_emu.c -x assembler-with-cpp dmacu_pl080.s
 *   The no-pie option allows  R_X86_64_32 to work, which helps us :)
 *
 */
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

// Start of DMA "microcode" for the virtual CPU
extern uint32_t Dma_UCode_CPU[];

// Register file of the simulated CPU
extern volatile uint8_t  Cpu_Regfile[256u];

// Program base pointer
extern volatile uint32_t Cpu_ProgramBase;

// Debug state
extern volatile uint32_t Cpu_DbgState;

// Program counter of the simulated CPU
extern volatile uint32_t Cpu_PC;

// Next program counter of the simulated CPU
extern volatile uint32_t Cpu_NextPC;

// Current instruction
extern volatile uint32_t Cpu_CurrentOPC;

// Current A operand
extern volatile uint16_t Cpu_CurrentA;

// Current B operand
extern volatile uint16_t Cpu_CurrentB;

// Current Z result
extern volatile uint16_t Cpu_CurrentZ;



/**
 * @brief Simplified PL080 channel emulation
 */
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

//----------------------------------------------------------------------
bool PL080_Channel_Process(PL080_Channel_t *const ch)
{
	bool progress = false;

	// Is the channel enabled?
	if (0u != (ch->config & PL080_CH_CONFIG_E))
	{
		// TODO: Check for channel control, we currently ignore most of it and
		// statically assume byte transfers.
		uint32_t ctrl = ch->control;
		uint32_t size = (ctrl >> PL080_CH_CTRL_SIZE_POS) & PL080_CH_CTRL_SIZE_MASK;

		if (size > 0u)
		{
			// Update control (we will consume the size)
			ch->control = ctrl & ~PL080_CH_CTRL_SIZE_MASK;

			const uint8_t *const src = (const uint8_t *) ch->src_addr;
			uint8_t *const dst = (uint8_t *) ch->dst_addr;

#if LOG_DMA
			printf ("dma[%p -> %p] (%u):", src, dst, size);
#endif
			// Process any data to copy

			uint32_t src_off = 0u;
			uint32_t dst_off = 0u;

			for (uint32_t i = 0u; i < size; ++i)
			{
#if LOG_DMA
				printf(" %02X", (unsigned) (src[i] & 0xFFu));
#endif
				dst[dst_off] = src[src_off];

				if (0u != (ctrl & 0x04000000))
				{
					// Source increment
					src_off += 1u;
				}

				if (0u != (ctrl & 0x08000000))
				{
					// Destination increment
					dst_off += 1u;
				}
			}
#if LOG_DMA
			printf("\n");
#endif
			// No more data to transfer (try to fetch next channel descriptor)
			if (ch->lli != 0u)
			{
				const uint32_t *const next = (const uint32_t *) ch->lli;
				ch->src_addr = next[0u];
				ch->dst_addr = next[1u];
				ch->lli      = next[2u];
				ch->control  = next[3u];
			}

			// We made some progress
			progress = true;
		}
	}

	return progress;
}

//----------------------------------------------------------------------
void DumpCpuState(const char *prefix)
{
	printf("%s        PC: %08X  NextPC: %08X\n"
	       "%s      BASE: %08X   STATE: %08X\n"
	       "%s       OPC: %08X\n"
	       "%s        rA: %04X  rB: %04X  rZ: %04X",
	       prefix, (unsigned) Cpu_PC, (unsigned) Cpu_NextPC,
	       prefix, (unsigned) Cpu_ProgramBase, (unsigned) Cpu_DbgState,
	       prefix, (unsigned) Cpu_CurrentOPC,
	       prefix, (unsigned) Cpu_CurrentA, (unsigned) Cpu_CurrentB, (unsigned) Cpu_CurrentZ);

	for (unsigned i = 0u; i < 256u; ++i)
	{
		if ((i % 16u) == 0u)
		{
			printf("\n%s  REGS[%02X]:", prefix, (unsigned) i);
		}

		printf(" %02X", (unsigned) Cpu_Regfile[i]);
	}

	printf("\n");
}

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

static PL080_Channel_t gDmaCh0;

//----------------------------------------------------------------------
// Setup the execution context for the test program
static void SetupTestProgram(void)
{
	// Setup the initial program counter
	Cpu_PC = (uint32_t) &gTestProgram[0];

	// Fill the register file with a test pattern
	for (uint32_t i = 0u; i < 256u; ++i)
	{
		Cpu_Regfile[i] = (uint8_t) i;
	}

	// Setup A, B and Z with dummy value (will be cleared by CPU)
	Cpu_CurrentA = UINT16_C(0xBAD0);
	Cpu_CurrentB = UINT16_C(0xBAD1);
	Cpu_CurrentZ = UINT16_C(0xBAD2);
}

// Start the virtual CPU
static void StartVirtualCPU(void)
{
	// Dump the initial CPU state (after test program setup)
	DumpCpuState("vcpu[init]");

	// Setup DMA channel #0 (using the first descriptor)
	gDmaCh0.src_addr = Dma_UCode_CPU[0];
	gDmaCh0.dst_addr = Dma_UCode_CPU[1];
	gDmaCh0.lli      = Dma_UCode_CPU[2];
	gDmaCh0.control  = Dma_UCode_CPU[3];

	// Set the channel configuration for channel 0 (and enable)
	gDmaCh0.config   = UINT32_C(0x0000000001);

	printf("vcpu[run]   started on dma channel #0\n");
}

// Wait until the virtual CPU is done (DMA idle)
static void WaitForVirtualCPU(void)
{
	uint32_t old_state = Cpu_DbgState;

	while (PL080_Channel_Process(&gDmaCh0))
	{
		if (Cpu_DbgState != old_state)
		{
			if (Cpu_DbgState == 0x65786563u)
			{
				// Entry to debug state
				puts("-------------------------------");
				DumpCpuState("vcpu[exec]");
			}

			old_state = Cpu_DbgState;
		}
	}

	printf("vcpu[run]   dma transfers done (virtual cpu is stopped)\n");

	DumpCpuState("vcpu[exit]");
}

int main(void)
{
	// Setup the test program
	SetupTestProgram();

	// Run the virtual the CPU
	StartVirtualCPU();
	WaitForVirtualCPU();

	return 0;
}