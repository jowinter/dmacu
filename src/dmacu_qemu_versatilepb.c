/*
 * Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
 *
 * Copyright (c) 2019 Johannes Winter
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
 *   arm-none-eabi-gcc -o dmacu_qemu_verstilepb.elf -Wall -O2 -g -specs=rdimon.specs -mcpu=arm926ej-s -marm dmacu_qemu_verstilepb.c dmacu_pl080.s
 *
 * Typical QEMU invocation:
 *   qemu-system-arm.exe -machine versatilepb -semihosting -nographic -kernel dmacu_qemu_verstilepb.elf
 * 
 */
 
#include <stdint.h>
#include <stdio.h>

// Start of DMA "microcode"
extern uint32_t Dma_UCode_Start[];

// End of DMA "microcode" (first word following the DMA microcode)
extern uint32_t Dma_UCode_End[];

// Register file of the simulated CPU
extern volatile uint8_t  Cpu_Regfile[256u];

// Program counter of the simulated CPU
extern volatile uint32_t Cpu_PC;

// Next program counter of the simulated CPU
extern volatile uint32_t Cpu_NextPC;

// Base address of the PL080 DMAC
#define PL080_DMA_BASE_ADDR UINT32_C(0x10130000)

// Register of the PL080 DMAC (offset gives offset relative to controller base address)
#define PL080_DMA_REG(offset) (* (volatile uint32_t *) (PL080_DMA_BASE_ADDR + (offset)))

void DumpCpuState(const char *prefix)
{
	printf("--- begin %s ---\n", prefix);
	printf("        PC: %08X\n    NextPC: %08X", (unsigned) Cpu_PC, (unsigned) Cpu_NextPC);

	for (unsigned i = 0u; i < 256u; ++i)
	{
		if ((i % 16u) == 0u)
		{
			printf("\n  REGS[%02X]:", (unsigned) i);
		}
		
		printf(" %02X", (unsigned) Cpu_Regfile[i]);
	}
	
	printf("\n");

	for (unsigned i = 0; i < (Dma_UCode_End - Dma_UCode_Start) / 4u; ++i)
	{
		printf("UCODE[%03X]: %08X %08X %08X %08X\n",
			16u * i,
			(unsigned) Dma_UCode_Start[4u * i + 0u],
			(unsigned) Dma_UCode_Start[4u * i + 1u],
			(unsigned) Dma_UCode_Start[4u * i + 2u],
			(unsigned) Dma_UCode_Start[4u * i + 3u]);
	}
	printf("--- end %s ---\n", prefix);
}

int main(void)
{
	// Dump the initial CPU state	
	DumpCpuState("initial cpu state");

	// Enable the DMA controller
	PL080_DMA_REG(0x030) |= UINT32_C(0x00000001);
	
	// Setup DMA channel #0 (using the first descriptor)
	PL080_DMA_REG(0x100) = Dma_UCode_Start[0];
	PL080_DMA_REG(0x104) = Dma_UCode_Start[1];
	PL080_DMA_REG(0x108) = Dma_UCode_Start[2];
	PL080_DMA_REG(0x10C) = Dma_UCode_Start[3];

	// Set the channel configuration for channel 0 (and enable)
	PL080_DMA_REG(0x110) = UINT32_C(0x0000000001);

	printf("dma: channel #0 started\n");
	
	while (UINT32_C(0) != (PL080_DMA_REG(0x01C) & UINT32_C(0x00000008)))
	{
		// Wait for the DMA controller
	}
	
	printf("dma: transfers done\n");

	DumpCpuState("final cpu state");

	return 0;
}