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

#ifndef DMACU_DMA_CHANNEL
# define DMACU_DMA_CHANNEL (0u)
#endif

//  GPDMA Configuration register definitions
#define GPDMA_CONFIG_E                     (1U    <<  0)
#define GPDMA_CONFIG_M0                    (1U    <<  1)
#define GPDMA_CONFIG_M1                    (1U    <<  2)

// GPDMA Channel Configuration registers definitions
#define GPDMA_CH_CONFIG_E                  (1U    <<  0)
#define GPDMA_CH_CONFIG_A                  (1U    << 17)
#define GPDMA_CH_CONFIG_H                  (1U    << 18)

#define GPIO_LED_MASK   (1u << 22)

//-------------------------------------------------------------------------------------------------
const Hal_Config_t gHalConfig =
{
    .gpio_pin_reg  = &LPC_GPIO0->FIOPIN,
    .gpio_led_mask = GPIO_LED_MASK,
    .platform_id   = HAL_PLATFORM_LPCXPRESSO_1769
};

//-------------------------------------------------------------------------------------------------
void Hal_Init(void)
{
	// Enable DMA clock
	LPC_SC->PCONP |= (1U << 29);

    // For simplicity: Setup GPIOs for blinking the on-board led of the LPC1769 LPCXpresso board
    LPC_PINCON->PINSEL1 &= ~(3u << 12u);
    LPC_GPIO0->FIODIR |= (1u << 22);
}

//-------------------------------------------------------------------------------------------------
void Hal_DmaTransfer(const Dma_Descriptor_t *desc)
{
	// Ensure that the DMA controller is enabled
	LPC_GPDMA->DMACConfig |= GPDMA_CONFIG_E;

	// Halt channel #0 (initial status is unknown)
	LPC_GPDMACH0->DMACCConfig |= GPDMA_CH_CONFIG_H;

	while (0u != (LPC_GPDMACH0->DMACCConfig & GPDMA_CH_CONFIG_A))
	{
		__NOP();
	}

	// Disable the channel (and clear the halt flag)
	LPC_GPDMACH0->DMACCConfig = 0u;

	// Load the initial descriptor
	LPC_GPDMACH0->DMACCSrcAddr  = desc->src;
	LPC_GPDMACH0->DMACCDestAddr = desc->dst;
	LPC_GPDMACH0->DMACCLLI      = desc->lli;
	LPC_GPDMACH0->DMACCControl  = desc->ctrl;

    // Set the GPIO pin
    LPC_GPIO0->FIOSET = (1u << 22);

	// Enable the channel
	LPC_GPDMACH0->DMACCConfig   |= GPDMA_CH_CONFIG_E;

	// Wait until the channel becomes idle
	while (0u != (LPC_GPDMACH0->DMACCConfig & GPDMA_CH_CONFIG_E))
	{
		__NOP();
	}

    // And clear our GPIO pin again
    LPC_GPIO0->FIOCLR = (1u << 22);
}
