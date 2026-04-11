/**
 * Port of the DMACU virtual CPU to the LPC84x series of microcontrollers.
 *
 * Copyright (c) 2024 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file dmacu.c
 * @brief Virtual CPU emulator core (LPC84x DMA backend)
 */
#include <dmacu.h>

#include "RTE_Components.h"
#include CMSIS_device_header

#ifndef DMACU_DMA_CHANNEL
# define DMACU_DMA_CHANNEL (0u)
#endif

// //  GPDMA Configuration register definitions
// #define GPDMA_CONFIG_E                     (1U    <<  0)
// #define GPDMA_CONFIG_M0                    (1U    <<  1)
// #define GPDMA_CONFIG_M1                    (1U    <<  2)
// 
// // GPDMA Channel Configuration registers definitions
// #define GPDMA_CH_CONFIG_E                  (1U    <<  0)
// #define GPDMA_CH_CONFIG_ITC                (1U    << 15)
// #define GPDMA_CH_CONFIG_A                  (1U    << 17)
// #define GPDMA_CH_CONFIG_H                  (1U    << 18)
// 
// #define GPIO_LED_MASK   (1u << 22)
// 
// // Override the IRQ handler
// extern void DMA_IRQHandler(void);
// 
// // PL080 status flag (for Hal_DmaTransfer)
// static volatile uint32_t gHal_DmaTransferDone;
// 
// // Bit-masks for the red, green, and blue LEDs (RGB LED1) on the LPXxpress1769 eval board
// #define GPIO0_RED_LED_Msk   (1u << 22u)
// 
// #define GPIO3_GREEN_LED_Msk (1u << 25u)
// #define GPIO3_BLUE_LED_Msk  (1u << 26u)

//-------------------------------------------------------------------------------------------------
// Disable semihosting
//

extern void _sys_exit(int status);
extern void _ttywrch(int ch);

__asm__ (".global __use_no_semihosting");

__NO_RETURN void _sys_exit(int status)
{
	// Sleep forever
	while (true)
	{
		//if (0u != (CoreDebug->DHCSR & CoreDebug_DHCSR_C_DEBUGEN_Msk))
		//{
		//	// A debugger is presenz
		//	__BKPT(0);
		//}

		__WFE();
	}
}

void _ttywrch(int ch)
{
	// Print via ITM (if enabled)
	//(void) ITM_SendChar(ch & 0xFFu);
	(void) ch;
}

//-------------------------------------------------------------------------------------------------
const Hal_Config_t gHalConfig =
{
	.platform_id   = HAL_PLATFORM_LPC845_BRK
};

//-------------------------------------------------------------------------------------------------
void Hal_Init(void)
{
    // Start the SysTick timer (10 kHz)
    SystemCoreClockUpdate();
    SysTick_Config(SystemCoreClock / 10000u);

	/// @todo Not (yet) ported

}

//-------------------------------------------------------------------------------------------------
void SysTick_Handler(void)
{
	/// @todo Not (yet) ported
}

//-------------------------------------------------------------------------------------------------
void Hal_DmaTransfer(const Dma_Descriptor_t *desc)
{
	/// @todo Not (yet) ported
}
