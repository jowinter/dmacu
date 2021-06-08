/*
 * Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
 *
 * This file implements a minimalistic standalone emulator that is runnable
 * on non-ARM systems.
 *
 * Copyright (c) 2019-2020 Johannes Winter
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the prohect for the license text.
 *
 * FIXME: This currently requires a 32-bit CPU :)
 * See build.sh for the movfuscator experiments.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

#define LOG_DMA 1

// Start of DMA "microcode" for the virtual CPU
extern uint32_t Dma_UCode_Main[];

/**
 * @brief Simplified PL080 channel emulation
 */
typedef struct
{
	uint32_t src_addr;
	uint32_t dst_addr;
	uint32_t lli;
	uint32_t control;
	uint32_t config;
} PL080_Channel_t;

#define PL080_CH_CTRL_SIZE_MASK UINT32_C(0x00000FFF)
#define PL080_CH_CTRL_SIZE_POS  UINT32_C(0)

#define PL080_CH_CONFIG_E       UINT32_C(0x00000001)

static PL080_Channel_t gDmaCh0;

//----------------------------------------------------------------------
bool PL080_Channel_Process(PL080_Channel_t *const ch)
{
	bool progress = false;

	// Is the channel enabled?
	if (0u != (ch->config & PL080_CH_CONFIG_E))
	{
		// TODO: Check for channel control, we currently ignore most of it and
		// statically assume byte transfers.
		uint32_t ctrl = ch->control;
		uint32_t size = (ctrl >> PL080_CH_CTRL_SIZE_POS) & PL080_CH_CTRL_SIZE_MASK;

		if (size > 0u)
		{
			// Update control (we will consume the size)
			ch->control = ctrl & ~PL080_CH_CTRL_SIZE_MASK;

			const uint8_t *const src = (const uint8_t *) ch->src_addr;
			uint8_t *const dst = (uint8_t *) ch->dst_addr;

#if LOG_DMA
			printf ("dma[%p -> %p] (%u):", src, dst, size);
#endif
			// Process any data to copy

			uint32_t src_off = 0u;
			uint32_t dst_off = 0u;

			for (uint32_t i = 0u; i < size; ++i)
			{
#if LOG_DMA
				printf(" %02X", (unsigned) (src[i] & 0xFFu));
#endif
				dst[dst_off] = src[src_off];

				if (0u != (ctrl & 0x04000000))
				{
					// Source increment
					src_off += 1u;
				}

				if (0u != (ctrl & 0x08000000))
				{
					// Destination increment
					dst_off += 1u;
				}
			}
#if LOG_DMA
			printf("\n");
#endif
			// No more data to transfer (try to fetch next channel descriptor)
			if (ch->lli != 0u)
			{
				const uint32_t *const next = (const uint32_t *) ch->lli;
				ch->src_addr = next[0u];
				ch->dst_addr = next[1u];
				ch->lli      = next[2u];
				ch->control  = next[3u];
			}

			// We made some progress
			progress = true;
		}
	}

	return progress;
}

//----------------------------------------------------------------------
// Start the virtual CPU
static void StartVirtualCPU(void)
{
	// Setup DMA channel #0 (using the first descriptor)
	gDmaCh0.src_addr = Dma_UCode_Main[0];
	gDmaCh0.dst_addr = Dma_UCode_Main[1];
	gDmaCh0.lli      = Dma_UCode_Main[2];
	gDmaCh0.control  = Dma_UCode_Main[3];

	// Set the channel configuration for channel 0 (and enable)
	gDmaCh0.config   = UINT32_C(0x0000000001);

	printf("vcpu[run]   started on dma channel #0\n");
}

// Wait until the virtual CPU is done (DMA idle)
static void WaitForVirtualCPU(void)
{
	while (PL080_Channel_Process(&gDmaCh0))
	{
	}

	printf("vcpu[run]   dma transfers done (virtual cpu is stopped)\n");
}

int main(void)
{
	// Run the virtual the CPU
	StartVirtualCPU();
	WaitForVirtualCPU();

	return 0;
}
