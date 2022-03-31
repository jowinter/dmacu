/*
 * Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
 *
 * Copyright (c) 2019-2020 Johannes Winter
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
 * Typical build command:
 *   arm-none-eabi-gcc -o dmacu_qemu_versatilepb.elf -Wall -O2 -g -specs=rdimon.specs -mcpu=arm926ej-s -marm dmacu_qemu_versatilepb.c dmacu_pl080.s
 *
 * Typical QEMU invocation:
 *   qemu-system-arm.exe -machine versatilepb -semihosting -nographic -kernel dmacu_qemu_verstilepb.elf
 *
 */

#include <stdint.h>
#include <stdio.h>

// Start of DMA "microcode" for the virtual CPU
extern uint32_t Dma_UCode_CPU[];

// Register file of the simulated CPU
extern volatile uint8_t  Cpu_Regfile[256u];

// Program base pointer
extern volatile uint32_t Cpu_ProgramBase;

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


// Base address of the PL080 DMAC
#define PL080_DMA_BASE_ADDR UINT32_C(0x10130000)

// Register of the PL080 DMAC (offset gives offset relative to controller base address)
#define PL080_DMA_REG(offset) (* (volatile uint32_t *) (PL080_DMA_BASE_ADDR + (offset)))

void DumpCpuState(const char *prefix)
{
	printf("%s        PC: %08X  NextPC: %08X Base: %08X\n"
		"%s       OPC: %08X\n"
		"%s        rA: %04X  rB: %04X  rZ: %04X",
	       prefix, (unsigned) Cpu_PC, (unsigned) Cpu_NextPC, (unsigned) Cpu_ProgramBase,
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

__attribute__((__used__))
char hello[] = "hello";

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

extern const uint32_t foo[4];

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

	// Enable the DMA controller
	PL080_DMA_REG(0x030) |= UINT32_C(0x00000001);

	// Setup DMA channel #0 (using the first descriptor)
	PL080_DMA_REG(0x100) = Dma_UCode_CPU[0];
	PL080_DMA_REG(0x104) = Dma_UCode_CPU[1];
	PL080_DMA_REG(0x108) = Dma_UCode_CPU[2];
	PL080_DMA_REG(0x10C) = Dma_UCode_CPU[3];

	// Set the channel configuration for channel 0 (and enable)
	PL080_DMA_REG(0x110) = UINT32_C(0x0000000001);

	printf("vcpu[run]   started on dma channel #0\n");
}

// Wait until the virtual CPU is done (DMA idle)
static void WaitForVirtualCPU(void)
{
	while (UINT32_C(0) != (PL080_DMA_REG(0x01C) & UINT32_C(0x00000008)))
	{
		// Wait for the DMA controller
	}

	printf("vcpu[run]   dma transfers done (virtual cpu is stopped)\n");

	// Clear configuration for DMA channel #0 and stop.
	PL080_DMA_REG(0x110) = UINT32_C(0x0000000000);

	printf("hello (%p): %s\n", hello, hello);
	//printf("%08x %08x %08x %08x\n", foo[0], foo[1], foo[2], foo[3]);

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
