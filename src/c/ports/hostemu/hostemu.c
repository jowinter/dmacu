/*
 * Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
 *
 * This file implements a minimalistic standalone emulator that is runnable
 * on non-ARM systems.
 *
 * Copyright (c) 2019-2022 Johannes Winter
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the prohect for the license text.
 *
 * This program can only be built as 32-bit binary (due to the way how the PL080 DMA and our emulation
 * thereof works). To run it on a native 64-bit environment one can alway's resort to QEMU's i386 user-mode
 * emulator (qemu-i386)
 */
#include <dmacu.h>
#include "pl080.h"

#include <dmacu.h>

#include <stdint.h>
#include <stdio.h>

//-------------------------------------------------------------------------------------------------
// Dummy HAL configuration
//

#define GPIO_LED_MASK (1u)
static volatile uint32_t gHalGpioLed = 0u;

const Hal_Config_t gHalConfig =
{
    .gpio_pin_reg  = &gHalGpioLed,
    .gpio_led_mask = GPIO_LED_MASK,
    .platform_id   = HAL_PLATFORM_HOST
};

//-----------------------------------------------------------------------------------------
void Hal_Init(void)
{
	// No special initialization needed.
}

//-----------------------------------------------------------------------------------------
void Hal_DmaTransfer(const Dma_Descriptor_t *entry)
{
	Dmacu_Cpu_t *cpu = Dmacu_GetCpu();

	// Virtual DMA channel
	PL080_Channel_t ch0 =
	{
		// Setup DMA channel #0 (using the first descriptor)
		.src_addr = entry->src,
		.dst_addr = entry->dst,
		.lli      = entry->lli,
		.control  = entry->ctrl,

		// Set the channel configuration for channel 0 (and enable)
		.config   = UINT32_C(0x0000000001)
	};

	uint32_t old_state = cpu->DbgState;

	while (PL080_Channel_Process(&ch0))
	{
		if (cpu->DbgState != old_state)
		{
			if (cpu->DbgState == 0x65786563u)
			{
				// Entry to debug state
				puts("-------------------------------");
				Dmacu_DumpCpuState("vcpu[exec]", cpu);
			}

			old_state = cpu->DbgState;
		}
	}
}
