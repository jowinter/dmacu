/**
 * Port of the DMACU virtual CPU to the LPC176x series of microcontrollers.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file dmacu.c
 * @brief Virtual CPU emulator core (PL080 backend)
 */
#include <dmacu.h>

#include "RTE_Components.h"
#include "RTE_Device.h"
#include CMSIS_device_header

#include "GPDMA_LPC17xx.h"

#ifndef DMACU_DMA_CHANNEL
# define DMACU_DMA_CHANNEL (0u)
#endif

// Completion markrer
static volatile uint32_t gDmaTransferDone;

//-------------------------------------------------------------------------------------------------
void Hal_Init(void)
{
	// Initialize the GPDMA (PL080) driver
	if (0 != GPDMA_Initialize())
	{
		__builtin_trap();
	}
}

//-------------------------------------------------------------------------------------------------
static void Hal_DmaTransferCallback(unsigned int event)
{
	// Currently not used
	(void) event;

	// Signal transfer completion
	gDmaTransferDone = 0xFFFFFFFFu;

	__SEV();
}

//-------------------------------------------------------------------------------------------------
void Hal_DmaTransfer(const Dma_Descriptor_t *desc)
{
	// Assume transfer is not done
	gDmaTransferDone = 0;

	// Setup the channel
	const uint32_t ctrl = (desc->ctrl & 0xFFFFF000u);
	const uint32_t size = (desc->ctrl & 0x00000FFFu);

	if (0 != GPDMA_ChannelConfigure(DMACU_DMA_CHANNEL, desc->src, desc->dst, size, ctrl, 0u, &Hal_DmaTransferCallback))
	{
		__builtin_trap();
	}

	// Start the DMA transfer
	if (0 != GPDMA_ChannelEnable(DMACU_DMA_CHANNEL))
	{
		__builtin_trap();
	}

	// Wait for the DMA transfer to complete
	while (gDmaTransferDone != 0xFFFFFFFFu)
	{
		__WFE();
	}

	// And stop the channel
	if (0 != GPDMA_ChannelDisable(DMACU_DMA_CHANNEL))
	{
		__builtin_trap();
	}
}
