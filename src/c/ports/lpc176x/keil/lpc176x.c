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
#define GPDMA_CH_CONFIG_ITC                (1U    << 15)
#define GPDMA_CH_CONFIG_A                  (1U    << 17)
#define GPDMA_CH_CONFIG_H                  (1U    << 18)

#define GPIO_LED_MASK   (1u << 22)

// Override the IRQ handler
extern void DMA_IRQHandler(void);

// PL080 status flag (for Hal_DmaTransfer)
static volatile uint32_t gHal_DmaTransferDone;

// Bit-masks for the red, green, and blue LEDs (RGB LED1) on the LPXxpress1769 eval board
#define GPIO0_RED_LED_Msk   (1u << 22u)

#define GPIO3_GREEN_LED_Msk (1u << 25u)
#define GPIO3_BLUE_LED_Msk  (1u << 26u)

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
		if (0u != (CoreDebug->DHCSR & CoreDebug_DHCSR_C_DEBUGEN_Msk))
		{
			// A debugger is presenz
			__BKPT(0);
		}

		__WFE();
	}
}

void _ttywrch(int ch)
{
	// Print via ITM (if enabled)
	(void) ITM_SendChar(ch & 0xFFu);
}

//-------------------------------------------------------------------------------------------------
const Hal_Config_t gHalConfig =
{
	.platform_id   = HAL_PLATFORM_LPCXPRESSO_1769
};

//-------------------------------------------------------------------------------------------------
void Hal_Init(void)
{
	// Enable DMA clock
	LPC_SC->PCONP |= (1U << 29);

	// For simplicity: Setup GPIOs for blinking the on-board led of the LPC1769 LPCXpresso board
	LPC_PINCON->PINSEL1 &= ~(3u << 12u);

    // Disable the red LED
    LPC_GPIO0->FIOSET   =  GPIO0_RED_LED_Msk;
	LPC_GPIO0->FIODIR   |= GPIO0_RED_LED_Msk;

    // Disable the green and blue LEDs
    LPC_GPIO3->FIOSET   =  (GPIO3_GREEN_LED_Msk | GPIO3_BLUE_LED_Msk);
    LPC_GPIO3->FIODIR   |= (GPIO3_GREEN_LED_Msk | GPIO3_BLUE_LED_Msk);

    // Start the SysTick timer (10 kHz)
    SystemCoreClockUpdate();
    SysTick_Config(SystemCoreClock / 10000u);

}

//-------------------------------------------------------------------------------------------------
// Simple software PWM (blue LED) + heart beat using the SysTick timer
//
// - We implement a simple heartbeat LED blinking at ~2 Hz
// - In the "dark"   state the blue LED is driven by a software PWM at ~1% duty cycle
// - In the "bright" state the blue LED is driven by a software PWM at ~10% duty cycle
//
// - The heartbeat counter disables itself after 3 full cycles

// Reload value for the software PWM
#define SOFT_PWM_RELOAD 100u

#define SOFT_PWM_LED_DARK   ((1u * SOFT_PWM_RELOAD)  / 100u) // ~1% Duty Cycle
#define SOFT_PWM_LED_BRIGHT ((10u * SOFT_PWM_RELOAD) / 100u) // ~10% Duty Cycle

static uint32_t gSoftPwmCounter   = SOFT_PWM_RELOAD - 1u;
static uint32_t gSoftPwmDutyCycle = SOFT_PWM_LED_DARK;

// Reload value for the heart-beat counter
#define HEARTBEAT_RELOAD 5000u
#define HEARTBEAT_FULL_CYCLES 6u

static uint32_t gHeartBeatCounter    = HEARTBEAT_RELOAD - 1u;
static uint32_t gRemainingHeartBeats = HEARTBEAT_FULL_CYCLES - 1u;

void SysTick_Handler(void)
{
    // Update the soft PWM counter
    if (gSoftPwmCounter > 0u)
    {
        gSoftPwmCounter -= 1u;
    }
    else
    {
        gSoftPwmCounter = SOFT_PWM_RELOAD - 1u;
    }

    // Update the LED output status (based on softare PWM duty-cycle)
    if (gSoftPwmCounter < gSoftPwmDutyCycle)
    {
        // LED on
        LPC_GPIO3->FIOCLR = GPIO3_BLUE_LED_Msk;
    }
    else
    {
        // LED off
        LPC_GPIO3->FIOSET = GPIO3_BLUE_LED_Msk;
    }

    // Heart-beat counter
    if (gRemainingHeartBeats > 0u)
    {
        // More heartbeats to come
        if (gHeartBeatCounter > 0u)
        {
            gHeartBeatCounter -= 1u;
        }
        else
        {
            // Toggle the heart-beat PWM counter
            gSoftPwmDutyCycle = (SOFT_PWM_LED_DARK == gSoftPwmDutyCycle) ? SOFT_PWM_LED_BRIGHT : SOFT_PWM_LED_DARK;4
            gHeartBeatCounter = HEARTBEAT_RELOAD - 1u;
            gRemainingHeartBeats -= 1u;
        }
    }
    else
    {
        // Flatline

        gSoftPwmDutyCycle = 0u;

        SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;

        LPC_GPIO3->FIOSET = GPIO3_BLUE_LED_Msk;
    }
}

//-------------------------------------------------------------------------------------------------
void DMA_IRQHandler(void)
{
	const uint32_t int_stat = LPC_GPDMA->DMACIntStat;

	// Clear terminal count interrupts
	if (0u != (int_stat & (1u << DMACU_DMA_CHANNEL)))
	{
		// Channel 0 is done (terminal count or error)
		gHal_DmaTransferDone = 1u;
		__SEV();
	}

	// Clear error and terminal count IRQs
	LPC_GPDMA->DMACIntErrClr  = int_stat;
	LPC_GPDMA->DMACIntTCClear = int_stat;
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

	// Disable the channel (and clear the halt + IRQ flags)
	LPC_GPDMACH0->DMACCConfig = 0u;

	// Load the initial descriptor
	LPC_GPDMACH0->DMACCSrcAddr  = desc->src;
	LPC_GPDMACH0->DMACCDestAddr = desc->dst;
	LPC_GPDMACH0->DMACCLLI      = desc->lli;
	LPC_GPDMACH0->DMACCControl  = desc->ctrl;

	// Set the GPIO pin
	LPC_GPIO0->FIOSET = (1u << 22);

	// Enable the DMA controller interrupt (transfer not yet done)
	LPC_GPDMA->DMACIntTCClear = (1u << DMACU_DMA_CHANNEL);
	LPC_GPDMA->DMACIntErrClr  = (1u << DMACU_DMA_CHANNEL);

	gHal_DmaTransferDone = 0u;

	// Ensure that the DMA IRQ is enabled
	NVIC_EnableIRQ(DMA_IRQn);

	// Enable the channel
	LPC_GPDMACH0->DMACCConfig   |= (GPDMA_CH_CONFIG_E | GPDMA_CH_CONFIG_ITC);

	// Wait until the channel becomes idle
	while (!gHal_DmaTransferDone)
	{
		__WFE();
	}

	// Disable the RED LED, enable the green LED
	LPC_GPIO0->FIODIR &= ~GPIO0_RED_LED_Msk;
}
