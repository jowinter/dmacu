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
void Hal_Init(void)
{
	Dmacu_Cpu_t *cpu = Dmacu_GetCpu();

	// Setup the test program
	Dmacu_SetupTestProgram(cpu);
}

//-----------------------------------------------------------------------------------------
void Hal_DmaTransfer(const Dma_Descriptor_t *entry)
{
	Dmacu_Cpu_t *cpu = Dmacu_GetCpu();

	// Dump the initial CPU state (after test program setup)
	Dmacu_DumpCpuState("vcpu[init]", cpu);

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

	Dmacu_DumpCpuState("vcpu[exit]", cpu);
}