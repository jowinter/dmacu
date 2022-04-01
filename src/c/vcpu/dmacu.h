/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file dmacu.h
 * @brief Virtual CPU emulator core (PL080 backend)
 */
#ifndef DMACU_H_
#define DMACU_H_ 1

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>


#ifndef DMACU_ALIGNED
# define DMACU_ALIGNED(x) __attribute__((__aligned__((x))))
#endif

#ifndef DMACU_PRIVATE
# define DMACU_PRIVATE static
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

/// \brief Converts a C pointer to a 32-bit DMA address.
///
/// \param p is the pointer-typed C expresion to be converted.
/// \return The raw address as (unsigned) 32-bit integer of type @ref Dma_UIntPtr_t.
///
#define Dma_PtrToAddr(p) ((Dma_UIntPtr_t) (p))

/// \brief Gets the offset of field @p _field in type @p _type.
///
/// \param _type is a compound type (struct).
///
/// \param _field is the
#define Dma_OffsetOf(_type,_field) ((uint32_t) offsetof(_type, _field))

/// \brief Canonical invalid (NULL) pointer
///
#define DMA_INVALID_ADDR Dma_PtrToAddr(NULL)


//-------------------------------------------------------------------------------------------------
// Basic DMA descriptors (PL080)
//

/// \brief Defines an externally visible DMA descriptor
#define Dma_Define_Descriptor(_self,...) \
    DMACU_ALIGNED(16u) \
    DMACU_PRIVATE Dma_Descriptor_t _self = { __VA_ARGS__ };

/// \brief Constructs the name of a local descriptor or object.
#define Dma_Local_Name(_self,_suffix) \
    _self##_##_suffix

/// \brief (Re-)declares an externally visible DMA descriptor
#define Dma_Declare_Descriptor(_self) \
    DMACU_PRIVATE Dma_Descriptor_t _self;

/// \brief (Re-)declares a local DMA descriptor
#define Dma_Declare_Local_Descriptor(_self,_suffix) \
    DMACU_PRIVATE Dma_Descriptor_t Dma_Local_Name(_self,_suffix);

/// \brief References a declared descriptor
#define Dma_Local_Reference(_self,_suffix) \
    (&Dma_Local_Name(_self, _suffix))

/// \brief Basic byte-wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
#define Dma_ByteCopy(_self,_dst,_src,_size,_lli) \
    Dma_Define_Descriptor(_self, \
        .src  = (Dma_UIntPtr_t) (_src), \
        .dst  = (Dma_UIntPtr_t) (_dst), \
        .lli  = (Dma_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x0C000000) + (uint32_t) (_size) \
    )

/// \brief Basic byte-wise DMA fill operation.
///
/// Fills a block of "size" bytes at "dst" with the byte found at "src". Then links to the
/// next descriptor at "lli".
///
#define Dma_ByteFill(_self, _dst,_src,_size,_lli) \
    Dma_Define_Descriptor(_self, \
        .src  = (Dma_UIntPtr_t) (_src), \
        .dst  = (Dma_UIntPtr_t) (_dst), \
        .lli  = (Dma_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x08000000) + (uint32_t) (_size) \
    )
		
//-------------------------------------------------------------------------------------------------
// Helper functions to interact with the virtual CPU
//

/// \brief Runs a program on the DMACU virtual CPU.
///
/// \param[in] initial_pc is the initial program counter for the DMACU program to execute.
extern void Dmacu_Run(const uint32_t *initial_pc);

//-------------------------------------------------------------------------------------------------
// Hardware abstraction layer
//

/// \brief Initializes the hardware abstraction layer.
///
/// \note This function must be provided by the platform specific port to initalize platform specific
///   hardware features for the DMACU environment.
///
extern void Hal_Init(void);

/// \brief Executes a DMA transfer (via the PL080 DMA controller).
///
/// \param[in] desc is the first DMA descriptor in the transfer chain.
extern void Hal_DmaTransfer(const Dma_Descriptor_t *desc);

#endif // DMACU_H_
