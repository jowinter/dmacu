/*
 * Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the prohect for the license text.
 */

/**
 * @file
 * @brief Minimal host application for the DMACU emulator
 *
 * This host application can be used on QEMU's versatilepb board model (ARM926EJ-S CPU).
 *
 * Typical QEMU invocation:
 *   qemu-system-arm.exe -machine versatilepb -semihosting -nographic -kernel dmacu_qemu.elf
 *
 */
#include <dmacu.h>

#include <stdint.h>
#include <stdio.h>

// Base address of the PL080 DMAC
#define PL080_DMA_BASE_ADDR UINT32_C(0x10130000)

// Register of the PL080 DMAC (offset gives offset relative to controller base address)
#define PL080_DMA_REG(offset) (* (volatile uint32_t *) (PL080_DMA_BASE_ADDR + (offset)))

//-----------------------------------------------------------------------------------------
// Static test program
//
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
void DumpCpuState(const char *prefix, const Dmacu_Cpu_t *cpu)
{
	printf("%s        PC: %08X  NextPC: %08X Base: %08X\n"
		"%s       OPC: %08X\n"
		"%s        rA: %04X  rB: %04X  rZ: %04X",
	    prefix, (unsigned) cpu->PC, (unsigned) cpu->NextPC, (unsigned) cpu->ProgramBase,
		prefix, (unsigned) cpu->CurrentOPC,
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

//-----------------------------------------------------------------------------------------
// Setup the execution context for the test program
//
static void SetupTestProgram(Dmacu_Cpu_t *cpu)
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
void Hal_Init(void)
{
	Dmacu_Cpu_t *cpu = Dmacu_GetCpu();

	// Setup the test program
	SetupTestProgram(cpu);
}

//-----------------------------------------------------------------------------------------
void Hal_DmaTransfer(const Dma_Descriptor_t *entry)
{
	Dmacu_Cpu_t *cpu = Dmacu_GetCpu();

	// Dump the initial CPU state (after test program setup)
	DumpCpuState("vcpu[init]", cpu);

	// Enable the DMA controller
	PL080_DMA_REG(0x030) |= UINT32_C(0x00000001);

	// Setup DMA channel #0 (using the first descriptor)
	PL080_DMA_REG(0x100) = entry->src;
	PL080_DMA_REG(0x104) = entry->dst;
	PL080_DMA_REG(0x108) = entry->lli;
	PL080_DMA_REG(0x10C) = entry->ctrl;

	// Set the channel configuration for channel 0 (and enable)
	PL080_DMA_REG(0x110) = UINT32_C(0x0000000001);

	printf("vcpu[run] started on dma channel #0\n");

	while (UINT32_C(0) != (PL080_DMA_REG(0x01C) & UINT32_C(0x00000008)))
	{
		// Wait for the DMA controller
	}

	printf("vcpu[run] dma transfers done (virtual cpu is stopped)\n");

	// Clear configuration for DMA channel #0 and stop.
	PL080_DMA_REG(0x110) = UINT32_C(0x0000000000);

	DumpCpuState("vcpu[exit]", cpu);
}
