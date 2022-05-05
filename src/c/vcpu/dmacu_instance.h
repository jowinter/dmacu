/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file dmacu_instance.h
 * @brief Virtual CPU emulator core (PL080 backend; instance specific data)
 */
#ifndef DMACU_INSTANCE_H_
#define DMACU_INSTANCE_H_ 1

// Common types and entrypoint for the main instance.
#include "dmacu.h"

// DMA instance prefix
//
// The instance prefix can be defined (e.g. when building a library) to enable coexistence of
// multiple DMACU instances in the same executable image.
//
#if !defined(DMA_INSTANCE_PREFIX)
# define DMA_INSTANCE_PREFIX Dmacu
#endif

//-------------------------------------------------------------------------------------------------
// Basic DMA descriptors (PL080)
//

/// \brief Concatenates a name with arguments @p a and @p b expanded.
#define Dma_Concat_Name(a,b) \
    Dma_Concat_Name_Inner(a,b)

/// \brief Macro expansion helper for @ref Dma_Concat_Name (implementation detail)
/// \internal
#define Dma_Concat_Name_Inner(a,b) \
    a ## _ ## b

/// \brief Constructs the name of a global descriptor or object
#define Dma_Global_Name(_self) \
    Dma_Concat_Name(DMA_INSTANCE_PREFIX, _self)

/// \brief Defines an externally visible DMA descriptor
#define Dma_Define_Descriptor(_self,...) \
    DMACU_ALIGNED(16u) \
    DMACU_PRIVATE Dma_Descriptor_t Dma_Global_Name(_self) = { __VA_ARGS__ };

/// \brief Constructs the name of a local descriptor or object.
#define Dma_Local_Name(_self,_suffix) \
    Dma_Concat_Name(_self,_suffix)

/// \brief (Re-)declares an externally visible DMA descriptor
#define Dma_Declare_Descriptor(_self) \
    DMACU_PRIVATE_DECL Dma_Descriptor_t Dma_Global_Name(_self);

/// \brief (Re-)declares a local DMA descriptor
#define Dma_Declare_Local_Descriptor(_self,_suffix) \
    DMACU_PRIVATE_DECL Dma_Descriptor_t Dma_Local_Name(Dma_Global_Name(_self),_suffix);

/// \brief References a declared global descriptor
#define Dma_Global_Reference(_self) \
    (&Dma_Global_Name(_self))

/// \brief References a declared local descriptor
#define Dma_Local_Reference(_self,_suffix) \
    (&Dma_Local_Name(Dma_Global_Name(_self), _suffix))

/// \brief Common DMA copy core operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
/// width indicates the source/destination transfer width in PL080's log-2 encoding:
///  - width=0 generates a byte copy
///  - width=1 generates a half-word (16-bit) copy
///  - width=2 generates a word (32-bit) copy
///
#define Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,_width) \
    _qual Dma_Define_Descriptor(_self, \
        .src  = (Dma_UIntPtr_t) (_src), \
        .dst  = (Dma_UIntPtr_t) (_dst), \
        .lli  = (Dma_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x0C000000) + (((_width) & 0x3u) << 21u) + (((_width) & 0x3u) << 18u) + (uint32_t) (_size) \
    )

/// \brief Basic byte (8-bit) wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
#define Dma_ByteCopy_Core(_qual,_self,_dst,_src,_size,_lli) \
    Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,0u)

// Patchable version of Dma_ByteCopy
#define Dma_ByteCopy(_self,_dst,_src,_size,_lli) \
    Dma_ByteCopy_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of Dma_ByteCopy
#define Dma_FixedByteCopy(_self,_dst,_src,_size,_lli) \
    Dma_ByteCopy_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

/// \brief Basic half-word (16-bit) wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
/// Size give the number of 16-bit half-words to copy
///
#define Dma_HalfWordCopy_Core(_qual,_self,_dst,_src,_size,_lli) \
    Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,1u)

// Patchable version of Dma_HalfWordCopy
#define Dma_HalfWordCopy(_self,_dst,_src,_size,_lli) \
    Dma_HalfWordCopy_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of DmaHalfWordCopy
#define Dma_FixedHalfWordCopy(_self,_dst,_src,_size,_lli) \
    Dma_HalfWordCopy_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

/// \brief Basic word (32-bit) wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
/// Size give the number of 32-bit words to copy
///
#define Dma_WordCopy_Core(_qual,_self,_dst,_src,_size,_lli) \
    Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,2u)

// Patchable version of Dma_WordCopy
#define Dma_WordCopy(_self,_dst,_src,_size,_lli) \
    Dma_WordCopy_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of DmaHalfWordCopy
#define Dma_FixedWordCopy(_self,_dst,_src,_size,_lli) \
    Dma_WordCopy_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

/// \brief Basic byte-wise DMA fill operation.
///
/// Fills a block of "size" bytes at "dst" with the byte found at "src". Then links to the
/// next descriptor at "lli".
///
#define Dma_ByteFill_Core(_qual,_self,_dst,_src,_size,_lli) \
    _qual Dma_Define_Descriptor(_self, \
        .src  = (Dma_UIntPtr_t) (_src), \
        .dst  = (Dma_UIntPtr_t) (_dst), \
        .lli  = (Dma_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x08000000) + (uint32_t) (_size) \
    )

// Fixed (non-patchable) version of Dma_ByteFill
#define Dma_ByteFill(_self,_dst,_src,_size,_lli) \
    Dma_ByteFill_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of Dma_ByteFill
#define Dma_FixedByteFill(_self,_dst,_src,_size,_lli) \
    Dma_ByteFill_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)


/// \brief Gets the virtual CPU's global execution state.
///
extern Dmacu_Cpu_t* Dma_Global_Name(GetCpu)(void);

/// \brief Gets the DMA descriptor for booting and running the virtual CPU.
///
extern const Dma_Descriptor_t* Dma_Global_Name(CpuBootDescriptor)(void);

#endif // DMACU_INSTANCE_H_
