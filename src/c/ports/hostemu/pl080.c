//
// Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
//
// This file implements a minimalistic model of the PL080 DMA controller.
//
// Copyright (c) 2019-2022 Johannes Winter
//
// This file is licensed under the MIT License. See LICENSE in the root directory
// of the prohect for the license text.
//
// FIXME: This currently requires a 32-bit CPU (build with "-m32") :(
//
// Typical build: gcc -m32 -Wall -pedantic -std=c99 dmacu_standalone_emu.c -x assembler-with-cpp dmacu_pl080.s
//
// Note: This MAY (read: worked once, likely to break in funny ways, expect the bugs to invade) on 64-bit systems with:
//  gcc -no-pie -Wall -pedantic -std=c99 dmacu_standalone_emu.c -x assembler-with-cpp dmacu_pl080.s
//   The no-pie option allows  R_X86_64_32 to work, which helps us :)
//
#include "pl080.h"

/// \brief Enable logging of DMA transactions (for debugging)
#define LOG_DMA (1)

//----------------------------------------------------------------------
bool PL080_Channel_Process(PL080_Channel_t *ch)
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
			printf ("dma[copy] %p -> %p size:%u data:[", (void *) src, (void *) dst, size);
#endif
			// Process any data to copy

			uint32_t src_off = 0u;
			uint32_t dst_off = 0u;

			for (uint32_t i = 0u; i < size; ++i)
			{
#if LOG_DMA
				printf(" %02X", (unsigned) (src[src_off] & 0xFFu));
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
			printf(" ]\n");
#endif
			// No more data to transfer (try to fetch next channel descriptor)
			if (ch->lli != 0u)
			{
				const uint32_t *const next = (const uint32_t *) ch->lli;
#if LOG_DMA
				printf ("dma[link] %p -> src:%08X dst:%08X lli:%08X control:%08X\n",
					(void*) ch->lli, (unsigned) next[0u], (unsigned) next[1u],
					(unsigned) next[2u], (unsigned) next[3u]);
#endif
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
