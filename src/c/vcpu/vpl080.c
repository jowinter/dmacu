/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file vpl080.c
 * @brief Proof of the simulation hyptothesis in a small (virtual) PL080 universe ;)
 */
#include <stdint.h>
#include <string.h>

#define  DMA_INSTANCE_PREFIX SlaveCpu
#include "dmacu_instance.c" // Slave CPU (driven be the virtual PL080 running on the primary CPU)

/// \brief Microcode of the virtual PL080
DMACU_ALIGNED(0x1000)
static const uint8_t gVirtualPL080Code[] =
{
	// Source the generated microcode program for the demo
#	include "mc/pl080.code.inc"
};

//-----------------------------------------------------------------------------------------
void Dmacu_SetupVirtualPL080(Dmacu_Cpu_t *cpu)
{
	// Clear the CPU structure
	memset(cpu, 0, sizeof(Dmacu_Cpu_t));

	// Setup the initial program counter (on the primary CPU)
	cpu->ProgramBase = (uint32_t) &gVirtualPL080Code[0u];
	cpu->PC = cpu->ProgramBase;

	// Pass the inital DMA descriptor of the slave CPU to our primary CPU running the virtual PL080
	const Dma_UIntPtr_t slave_cpu_boot_descriptor = Dma_PtrToAddr(SlaveCpu_CpuBootDescriptor());
	cpu->RegFile[243u] = (uint8_t) (slave_cpu_boot_descriptor & 0xFFu);
	cpu->RegFile[244u] = (uint8_t) ((slave_cpu_boot_descriptor >> 8u)  & 0xFFu);
	cpu->RegFile[245u] = (uint8_t) ((slave_cpu_boot_descriptor >> 16u) & 0xFFu);
	cpu->RegFile[246u] = (uint8_t) ((slave_cpu_boot_descriptor >> 24u) & 0xFFu);

	// Finally initialize the slave CPU
	Dmacu_Cpu_t *const slave = SlaveCpu_GetCpu();
	Dmacu_SetupTestProgram(slave);
}
