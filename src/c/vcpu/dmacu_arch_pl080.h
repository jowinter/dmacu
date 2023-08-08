/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file dmacu_arch_pl080.h
 * @brief Architecture details of the ARM PL080 controller
 */
#ifndef DMAC_ARCH_PL080_H_
#define DMAC_ARCH_PL080_H_ 1

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

// Hide low-level architecture details (DMACU_ARCH_xxx) by default
#if !defined(DMACU_ARCH_DETAILS)
# define DMACU_ARCH_DETAILS (0)
#endif

/// \brief 32-bit pointer type for the virtual CPU emulator.
///
typedef uint32_t Dma_UIntPtr_t;

/// \brief PL080 DMA descriptor
///
/// \note See the PL080 DMA controller datasheet for details on the fields of the
///    structure.
///
typedef struct Dma_Descriptor
{
    Dma_UIntPtr_t src; ///!< Source address of the transfer
    Dma_UIntPtr_t dst; ///!< Destination address of the transfer
    Dma_UIntPtr_t lli; ///!< Address of the next transfer in the chain
    uint32_t ctrl;     ///!< Control bits and transfer size
} Dma_Descriptor_t;

/// \brief Defines an externally visible DMA descriptor
#define Dma_Define_Descriptor(_self,...) \
  DMACU_ALIGNED(sizeof(Dma_Descriptor_t))				\
  DMACU_PRIVATE Dma_Descriptor_t Dma_Global_Name(_self) = { __VA_ARGS__ };


//-------------------------------------------------------------------------------------------------
// DMA Controller Hardware Dependencies (PL080)
//
#if (DMACU_ARCH_DETAILS)

/// \brief Common DMA copy core operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
/// width indicates the source/destination transfer width in PL080's log-2 encoding:
///  - width=0 generates a byte copy
///  - width=1 generates a half-word (16-bit) copy
///  - width=2 generates a word (32-bit) copy
///
#define Dma_Arch_Copy_Core(_qual,_self,_dst,_src,_size,_lli,_width) \
    _qual Dma_Define_Descriptor(_self, \
	.src  = (Dma_UIntPtr_t) (_src), \
	.dst  = (Dma_UIntPtr_t) (_dst), \
	.lli  = (Dma_UIntPtr_t) (_lli), \
	.ctrl = UINT32_C(0x0C000000) + (((_width) & 0x3u) << 21u) + (((_width) & 0x3u) << 18u) + (uint32_t) (_size) \
    )

/// \brief Basic byte-wise DMA fill operation.
///
/// Fills a block of "size" bytes at "dst" with the byte found at "src". Then links to the
/// next descriptor at "lli".
///
#define Dma_Arch_ByteFill_Core(_qual,_self,_dst,_src,_size,_lli) \
    _qual Dma_Define_Descriptor(_self, \
	.src  = (Dma_UIntPtr_t) (_src), \
	.dst  = (Dma_UIntPtr_t) (_dst), \
	.lli  = (Dma_UIntPtr_t) (_lli), \
	.ctrl = UINT32_C(0x08000000) + (uint32_t) (_size) \
    )


/// \brief Common DMA copy core operation (with terminal count interrupt)
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
/// width indicates the source/destination transfer width in PL080's log-2 encoding:
///  - width=0 generates a byte copy
///  - width=1 generates a half-word (16-bit) copy
///  - width=2 generates a word (32-bit) copy
///
/// This version of the copy operation triggers a terminal count interrupt (if enabled).
///
#define Dma_Arch_TerminalCopy_Core(_qual,_self,_dst,_src,_size,_lli,_width) \
    _qual Dma_Define_Descriptor(_self, \
	.src  = (Dma_UIntPtr_t) (_src), \
	.dst  = (Dma_UIntPtr_t) (_dst), \
	.lli  = (Dma_UIntPtr_t) (_lli), \
	.ctrl = UINT32_C(0x8C000000) + (((_width) & 0x3u) << 21u) + (((_width) & 0x3u) << 18u) + (uint32_t) (_size) \
    )

#endif // DMACU_ARCH_DETAILS

#endif // DMAC_ARCH_PL080_H_
