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
 * See build.sh for the movfuscator experiments.
 *
 *
 * Typical QEMU invocation:
 *   qemu-system-arm.exe -machine versatilepb -semihosting -nographic -kernel moveme-host.elf
 *
 */

#include <stdint.h>
#include <stdio.h>

// Start of DMA "microcode" for the virtual CPU
extern uint32_t Dma_UCode_Main[];

// Base address of the PL080 DMAC
#define PL080_DMA_BASE_ADDR UINT32_C(0x10130000)

// Register of the PL080 DMAC (offset gives offset relative to controller base address)
#define PL080_DMA_REG(offset) (* (volatile uint32_t *) (PL080_DMA_BASE_ADDR + (offset)))

// Start the virtual CPU
static void StartVirtualCPU(void)
{
	// Enable the DMA controller
	PL080_DMA_REG(0x030) |= UINT32_C(0x00000001);

	// Setup DMA channel #0 (using the first descriptor)
	PL080_DMA_REG(0x100) = Dma_UCode_Main[0];
	PL080_DMA_REG(0x104) = Dma_UCode_Main[1];
	PL080_DMA_REG(0x108) = Dma_UCode_Main[2];
	PL080_DMA_REG(0x10C) = Dma_UCode_Main[3];

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
}

int main(void)
{
	// Run the virtual the CPU
	StartVirtualCPU();
	WaitForVirtualCPU();

	return 0;
}
