/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
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

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>


#ifndef DMACU_ALIGNED
# define DMACU_ALIGNED(x) __attribute__((__aligned__((x))))
#endif

#ifndef DMACU_PRIVATE
# define DMACU_PRIVATE //static
#endif

/// \brief 32-bit pointer type for the virtual VPU emulator
///
typedef uint32_t Dmacu_UIntPtr_t;

/** @brief DMA descriptor data-structure */
typedef struct Dmacu_Descriptor
{
    Dmacu_UIntPtr_t src;
    Dmacu_UIntPtr_t dst;
    Dmacu_UIntPtr_t lli;
    uint32_t ctrl;
} Dmacu_Descriptor_t;

/// \brief Converts a C pointer to a 32-bit DMA address.
///
/// \param p is the pointer-typed C expresion to be converted.
/// \return The raw address as (unsigned) 32-bit integer of type @ref Dmacu_UIntPtr_t.
///
#define Dma_PtrToAddr(p) ((Dmacu_UIntPtr_t) (p))

#define Dma_OffsetOf(_type,_field) ((uint32_t) offsetof(_type, _field))

#define DMACU_INVALID_ADDR Dma_PtrToAddr(NULL)

//-------------------------------------------------------------------------------------------------
// Basic DMA descriptors (PL080)
//

/// \brief Defines an externally visible DMA descriptor
#define Dma_Define_Descriptor(_self,...) \
    DMACU_ALIGNED(16u) \
    DMACU_PRIVATE Dmacu_Descriptor_t _self = { __VA_ARGS__ };

/// \brief Constructs the name of a local descriptor or object.
#define Dma_Local_Name(_self,_suffix) \
    _self##_##_suffix

/// \brief (Re-)declares an externally visible DMA descriptor
#define Dma_Declare_Descriptor(_self) \
    DMACU_PRIVATE Dmacu_Descriptor_t _self;

/// \brief (Re-)declares a local DMA descriptor
#define Dma_Declare_Local_Descriptor(_self,_suffix) \
    DMACU_PRIVATE Dmacu_Descriptor_t Dma_Local_Name(_self,_suffix);

/// \brief References a declared descriptor
#define Dma_Local_Reference(_self,_suffix) \
    (&Dma_Local_Name(_self, _suffix))

/// \brief Basic byte-wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
#define Dma_ByteCopy(_self,_dst,_src,_size,_lli) \
    Dma_Define_Descriptor(_self, \
        .src  = (Dmacu_UIntPtr_t) (_src), \
        .dst  = (Dmacu_UIntPtr_t) (_dst), \
        .lli  = (Dmacu_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x0C000000) + (uint32_t) (_size) \
    )

/// \brief Basic byte-wise DMA fill operation.
///
/// Fills a block of "size" bytes at "dst" with the byte found at "src". Then links to the
/// next descriptor at "lli".
///
#define Dma_ByteFill(_self, _dst,_src,_size,_lli) \
    Dma_Define_Descriptor(_self, \
        .src  = (Dmacu_UIntPtr_t) (_src), \
        .dst  = (Dmacu_UIntPtr_t) (_dst), \
        .lli  = (Dmacu_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x08000000) + (uint32_t) (_size) \
    )

//-------------------------------------------------------------------------------------------------
// DMA descriptor manipulation helpers
//

/// \brief Patches a field of a DMA descriptor
///
/// Patches field @p _field of the DMA descriptor at @p _desc with @p _size bytes
/// from @p _src. Then links to descriptor @p _lli
#define Dma_PatchField(_self,_dst,_field,_off,_src,_size,_lli) \
    Dma_ByteCopy(_self, \
        (Dma_PtrToAddr(_dst) + Dma_OffsetOf(Dmacu_Descriptor_t, _field) + ((uint32_t) (_off))), \
        (_src),  \
        (_size), \
        (_lli) \
    )

//-------------------------------------------------------------------------------------------------
// Descriptor source address patch operations
//

/// \brief Patch bits [7:0] of a DMA descriptor's source address.
///
/// Patches bits [7:0] of the source address of the DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcLo8(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), src, 0u, (_src), 1u, (_lli))

/// \brief Patch bits [15:8] of a DMA descriptor's source address.
///
/// Patches bits [15:8] of the source address of the DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcHi8(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), src, 1u, (_src), 1u, (_lli))

/// \brief Patch bits [15:0] of a DMA descriptor's source address.
///
/// Patches bits [15:0] of the source address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcLo16(_self,_dst,_src,_lli) \
    Dma_PatchField(_self,(_dst), src, 0u, (_src), 2u, (_lli))

/// \brief Patch bits [31:16] of a DMA descriptor's source address.
///
/// Patches bits [31:16] of the source address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcHi16(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), src, 2u, (_src), 2u, (_lli))

/// \brief Patches a DMA descriptor's source address.
///
/// Patches the whole destination address of the DMA descriptor at "dst" with the word
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrc(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), src, 0u, (_src), 4u, (_lli))

//-------------------------------------------------------------------------------------------------
// Descriptor destination address patch operations
//

/// \brief Patches bits[7:0] of a DMA descriptors destination address.
///
/// Patches bits [7:0] of the destination address of DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstLo8(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), dst, 0u, (_src), 1u, (_lli))

/// \brief Patches bits[15:8] of a DMA descriptors destination address.
///
/// Patches bits [15:8] of the destination address of DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstHi8(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), dst, 1u, (_src), 1u, (_lli))

/// \brief Patches bits[15:0] of a DMA descriptor's destination address.
///
/// Patches bits [15:0] of the destinatoin address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstLo16(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), dst, 0u, (_src), 2u, (_lli))

/// \brief Patches bits[31:16] of a DMA descriptor's destination address.
///
/// Patches bits [31:16] of the destinatoin address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstHi16(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), dst, 2u, (_src), 2u, (_lli))

/// \brief Patches the destination address of a DMA descriptor.
///
/// Patches the entire destination address of the DMA descriptor at "dst" with the word
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDst(_self,_dst,_src,_lli) \
    Dma_PatchField(_self, (_dst), dst, 0u, (_src), 4u, (_lli))

//-------------------------------------------------------------------------------------------------
// Descriptor destination address patch operations
//

/// \brief Patches the link address a DMA descriptor.
///
/// Patches the entire link address (lli) of the DMA descriptor at "dst" with the word
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchLink(_self,_dst,_src,_lli) \
	Dma_PatchField(_self, (_dst), lli, 0u, (_src), 4u, (_lli))


//-------------------------------------------------------------------------------------------------
// Lookup-Tables (common helpers and support macros)
//

// Helper macros to populate the entries of a LUT (with a power-of-two number of elements)
#define LUT_MAKE_1(_gen,_base)   [(_base)] = _gen((_base))
#define LUT_MAKE_2(_gen,_base)   LUT_MAKE_1   (_gen, (_base)), LUT_MAKE_1  (_gen, ((_base) +   1u))
#define LUT_MAKE_4(_gen,_base)   LUT_MAKE_2   (_gen, (_base)), LUT_MAKE_2  (_gen, ((_base) +   2u))
#define LUT_MAKE_8(_gen,_base)   LUT_MAKE_4   (_gen, (_base)), LUT_MAKE_4  (_gen, ((_base) +   4u))
#define LUT_MAKE_16(_gen,_base)  LUT_MAKE_8   (_gen, (_base)), LUT_MAKE_8  (_gen, ((_base) +   8u))
#define LUT_MAKE_32(_gen,_base)  LUT_MAKE_16  (_gen, (_base)), LUT_MAKE_16 (_gen, ((_base) +  16u))
#define LUT_MAKE_64(_gen,_base)  LUT_MAKE_32  (_gen, (_base)), LUT_MAKE_32 (_gen, ((_base) +  32u))
#define LUT_MAKE_128(_gen,_base) LUT_MAKE_64  (_gen, (_base)), LUT_MAKE_64 (_gen, ((_base) +  64u))
#define LUT_MAKE_256(_gen,_base) LUT_MAKE_128 (_gen, (_base)), LUT_MAKE_128(_gen, ((_base) + 128u))
#define LUT_MAKE_512(_gen,_base) LUT_MAKE_256 (_gen, (_base)), LUT_MAKE_256(_gen, ((_base) + 256u))

/// \brief Lookup into an 8-bit SBOX
///
/// Substitutes a byte read from "src" via the lookup table given by "sbox" and
/// stores the result byte at "dst". Then links to the next descriptor at "lli".
///
///
/// C model:
///   void Dma_Sbox8(uint8_t* dst, const uint8_t* src, const uint8_t sbox[256u])
///   {
///      *dst = sbox[*src];
///   }
///
/// Constraints:
///   The lookup table at "sbox" must be aligned to a 256-byte boundary for proper
///   operation.
///
#define Dma_Sbox8(_self,_dst,_src,_sbox,_lli) \
    Dma_Declare_Local_Descriptor(_self, Sbox8_Lookup) \
    /* Step 1: Load the source byte from src and substitute it into the sbox's source address */ \
    Dma_PatchSrcLo8(_self, \
        Dma_Local_Reference(_self, Sbox8_Lookup), \
        (_src), \
        Dma_Local_Reference(_self, Sbox8_Lookup)  \
    ) \
    /* Step 2: Read the byte from the (patched) sbox location and store to dst */ \
    Dma_ByteCopy(Dma_Local_Name(_self, Sbox8_Lookup), (_dst), (_sbox), 1u, (_lli))

/// \brief Patch the lookup table of address of an 8-bit SBOX
///
/// Reads a word from "tableptr" and patches the lookup table pointer
/// at the Dma_Sbox8 primitive found at "dst". Then links to the next descriptor at "lli".
///
/// C model (roughly):
///   void Dma_Sbox8_PatchTableImm_And_Lookup(uint8_t* dst, const uint8_t* src, const uint8_t **tableptr)
///   {
///      // Dma_Sbox8_PatchTableImm (logically) fetches the lookup table pointer of the following lookup
///      // (implementation wise this is achived by patching "sbox" of the following Dma_Sbox8)
///      const uint8_t *sbox = *tableptr;
///
///      // Dma_Sbox8 performs the actual lookup
///      *dst = sbox[*src];
///   }
///
#define Dma_Sbox8_PatchTableImm(_self,_lookup,_tableptr,_lli) \
    /* We patch the SBOX in step 2 of the lookup in the Dma_Sbox8 macro */ \
    Dma_Declare_Local_Descriptor(_lookup, Sbox8_Lookup) \
    Dma_PatchSrc(_self, Dma_Local_Reference(_lookup, Sbox8_Lookup), (_tableptr), (_lli))

#if 0
/**
 * Reads a byte from "src", looks up the matching word from the table at "table" and stores
 * the (word) result at "dst". Then links to the next descriptor at "lli".
 *
 * C model:
 *   void Dma_TableSwitch64(uint32_t* dst, const uint8_t* src, const uint32_t table[64u])
 *   {
 *     *dst = table[*src % 64u];
 *   }
 *
 * Constraints:
 *  The value table must be aligned on a 256 byte boundary. The byte value at "src" must be
 *  should be in range 0..63 (the construction of Lut_TableSwitch64 ensures that byte values >=64
 *  are reduced modulo 64 for purpose of lookup address generation).
 */
	.macro Dma_TableSwitch64 dst, src, table, lli
.LDma_TableSwitch_PrepareLookup\@:
	Dma_Sbox8 (.LDma_TableSwitch_DoLookup\@ + 0), \src, Lut_Mul4, .LDma_TableSwitch_DoLookup\@

	// Step 2: Read a 4-byte value from the table.
.LDma_TableSwitch_DoLookup\@:
	Dma_ByteCopy \dst, \table, 4, \lli
	.endm
#endif

//-------------------------------------------------------------------------------------------------
// Lookup tables for Unary Functions (uint8_t -> uint8_t)
//

/// \brief Bitwise Complement (1's complement)
///
/// C model:
/// \code
///   uint8_t BitNot(const uint8_t a)
///   {
///     return ~a & 0xFFu;
///   }
/// \endcode
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_BitNot[256u] =
{
#define Lut_BitNot_Generator(_a) ((uint8_t) (~(_a) & 0xFFu))

    LUT_MAKE_256(Lut_BitNot_Generator, 0u)
};

/// \brief Two's Complement / Negation
///
/// C model:
/// \code
///   uint8_t BitNeg(const uint8_t a)
///   {
///     return -a & 0xFFu;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_Neg[256u] =
{
#define Lut_Neg_Generator(_a) ((uint8_t) (-(_a) & 0xFFu))

    LUT_MAKE_256(Lut_Neg_Generator, 0u)
};

/// \brief Logic Rotate-Right by 1
///
/// C model:
/// \code
///   uint8_t RotateRight(const uint8_t a)
///   {
///     return ((a >> 1u) & 0x7Fu) | ((a & 0x1) << 7u);
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_RotateRight[256u] =
{
#define Lut_RotateRight_Generator(_a) \
    ((uint8_t) ((((_a) >> 1u) & 0x7Fu) | (((_a) & 0x1u) << 7u)))

    LUT_MAKE_256(Lut_RotateRight_Generator, 0u)
};

/// \brief Logic Rotate-Left by 1
///
/// C model:
/// \code
///   uint8_t RotateLeft(const uint8_t a)
///   {
///     return ((a & 0x7Fu) << 1u) | ((a >> 7u) & 0x1u);
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_RotateLeft[256u] =
{
#define Lut_RotateLeft_Generator(_a) \
    ((uint8_t) ((((_a) & 0x7Fu) << 1u) | (((_a) >> 7u) & 0x1u)))

    LUT_MAKE_256(Lut_RotateLeft_Generator, 0u)
};

/// \brief Extract Lower Nibble / Mask with 0x0F
///
/// C model:
/// \code
///   uint8_t Lo4(const uint8_t a)
///   {
///     return a & 0x0Fu;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_Lo4[256u] =
{
#define Lut_Lo4_Generator(_a) \
    ((uint8_t) ((_a) & 0x0Fu))

    LUT_MAKE_256(Lut_Lo4_Generator, 0u)
};

/// \brief Divide by 16 / Logic-Shift Right by 4 / Extract Upper Nibble
///
/// C model:
/// \code
///   uint8_t Hi4(const uint8_t a)
///   {
///     return (a >> 4u) & 0x0Fu;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_Hi4[256u] =
{
#define Lut_Hi4_Generator(_a) \
    ((uint8_t) (((_a) >> 4u) & 0x0Fu))

    LUT_MAKE_256(Lut_Hi4_Generator, 0u)
};

/// \brief Multiply by 4 / Logic Shift-Left by 2
///
/// C model:
/// \code
///   uint8_t Mul4(const uint8_t a)
///   {
///     return (a & 0x3Fu) << 2u;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_Mul4[256u] =
{
#define Lut_Mul4_Generator(_a) \
    ((uint8_t) (((_a) & 0x3Fu) << 2u))

    LUT_MAKE_256(Lut_Mul4_Generator, 0u)
};

/// \brief Multiply by 16 / Logic Shift-Left by 4
///
/// C model:
/// \code
///   uint8_t Mul16(const uint8_t a)
///   {
///     return (a & 0x0Fu) << 4u;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_Mul16[256u] =
{
#define Lut_Mul16_Generator(_a) \
    ((uint8_t) (((_a) & 0x0Fu) << 4u))

    LUT_MAKE_256(Lut_Mul16_Generator, 0u)
};

//-----------------------------------------------------------------------------------------
// Lookup tables for binary functions (Lower Nibble)
//
// Logic functions:
//  Full lookup tables for 8-bit x 8-bit lookups would occupy 64k for each table. To conserve
//  ROM/flash space we store 4-bit x 4-bit lookup tables and use construct the 8-bit result
//  from from two lookups on the upper/lower nibble of the operand bytes.
//
//-----------------------------------------------------------------------------------------

/// \brief Bitwise AND (Lower Nibble)
///
/// C model:
/// \code
///   uint8_t BitAnd(uint8_t x)
///   {
///     uint8_t a = x         & 0x0Fu;
///     uint8_t b = (x >> 4u) & 0x0Fu;
///     return (a & b)        & 0x0Fu;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_BitAnd[256u] =
{
#define Lut_BitAnd_Generator(_x) \
    ((uint8_t) ((((_x) & 0x0Fu) & (((_x) >> 4u) & 0x0Fu)) & 0x0Fu))

    LUT_MAKE_256(Lut_BitAnd_Generator, 0u)
};

/// \brief Bitwise OR (Lower Nibble)
///
/// C model:
/// \code
///   uint8_t BitAnd(uint8_t x)
///   {
///     uint8_t a = x         & 0x0Fu;
///     uint8_t b = (x >> 4u) & 0x0Fu;
///     return (a | b)        & 0x0Fu;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_BitOr[256u] =
{
#define Lut_BitOr_Generator(_x) \
    ((uint8_t) ((((_x) & 0x0Fu) | (((_x) >> 4u) & 0x0Fu)) & 0x0Fu))

    LUT_MAKE_256(Lut_BitOr_Generator, 0u)
};

/// \brief Bitwise Exclusive-OR (Lower Nibble)
///
/// C model:
/// \code
///   uint8_t BitAnd(uint8_t x)
///   {
///     uint8_t a = x         & 0x0Fu;
///     uint8_t b = (x >> 4u) & 0x0Fu;
///     return (a | b)        & 0x0Fu;
///   }
/// \endcode
///
DMACU_ALIGNED(256u)
DMACU_PRIVATE const uint8_t Lut_BitEor[256u] =
{
#define Lut_BitEor_Generator(_x) \
    ((uint8_t) ((((_x) & 0x0Fu) ^ (((_x) >> 4u) & 0x0Fu)) & 0x0Fu))

    LUT_MAKE_256(Lut_BitEor_Generator, 0u)
};

/// \brief Identity lookup table.
///
/// The identity lookup table is used to add two 8-bit integers. Approximate C model:
/// \code
///  static uint8_t Add8(uint8_t a, uint8_t b)
///  {
///    uint8_t temp[256u];
///
///    // Implemented as Dma_ByteCopy with patch on bits [7:0] of the source address
///    memcpy(&temp[0u], &Lut_Identity[a], 256u);
///
///    // Implemented as Dma_ByteCopy with patch on bits [7:0] of the source address
///    return temp[b];
///  }
/// \endcode
///
/// \note A "direct" approach to addition would be to use a 64k lookup table and to
///   patch bits [7:0] and [15:9] of the source address of a Dma_ByteCopy. The temporary
///   copy used here favors reduced memory usage and relaxed alignment requirements over
///   the speed advantage of the "direct" approach.
///
/// \note We force alignment of our LUT to an even 512 bytes boundary. This trivially
///   ensures that we do not violate the PL080's hardware limitations w.r.t. to crossing
///   1K boundaries in DMA transfers.
///
DMACU_ALIGNED(512u)
DMACU_PRIVATE const uint8_t Lut_Identity[512u] =
{
#define Lut_Identity_Generator(_x) \
    ((uint8_t) ((_x) & 0xFFu))

    LUT_MAKE_512(Lut_Identity_Generator, 0u)
};

/// \brief Carry generator table
///
/// The identity lookup table is used to add two 8-bit integers. Approximate C model:
/// \code
///  static uint8_t Add8(uint8_t a, uint8_t b)
///  {
///    uint8_t temp[256u];
///
///    // Implemented as Dma_ByteCopy with patch on bits [7:0] of the source address
///    memcpy(&temp[0u], &Lut_Carry[a], 256u);
///
///    // Implemented as Dma_ByteCopy with patch on bits [7:0] of the source address
///    return temp[b];
///  }
/// \endcode
///
/// \note We force alignment of our LUT to an even 512 bytes boundary. This trivially
///   ensures that we do not violate the PL080's hardware limitations w.r.t. to crossing
///   1K boundaries in DMA transfers.
///
/// \see Lut_Identity for remarks on the "temporary copy" approach used here.
///
///
DMACU_ALIGNED(512u)
DMACU_PRIVATE const uint8_t Lut_Carry[512u] =
{
#define Lut_Carry_Generator(_x) \
    ((uint8_t) (((_x) >> 8u) & 0x01u))

    LUT_MAKE_512(Lut_Carry_Generator, 0u)
};

//-----------------------------------------------------------------------------------------
//
// Forward declarations (instructions)
//
//-----------------------------------------------------------------------------------------

Dma_Declare_Descriptor(Cpu_OpNop_1       )
Dma_Declare_Descriptor(Cpu_OpMovImm_1    )
Dma_Declare_Descriptor(Cpu_OpMov2Imm_1   )
Dma_Declare_Descriptor(Cpu_OpMov2Reg_1   )
Dma_Declare_Descriptor(Cpu_OpAddImm8_1   )
Dma_Declare_Descriptor(Cpu_OpAcyImm8_1   )
Dma_Declare_Descriptor(Cpu_OpAddReg_1    )
Dma_Declare_Descriptor(Cpu_OpAcyReg_1    )
Dma_Declare_Descriptor(Cpu_OpJmpImm16_1  )
Dma_Declare_Descriptor(Cpu_OpJmpReg16_1  )
Dma_Declare_Descriptor(Cpu_OpBrNeReg_1   )
Dma_Declare_Descriptor(Cpu_OpBrEqReg_1   )
Dma_Declare_Descriptor(Cpu_OpBrNeImm_1   )
Dma_Declare_Descriptor(Cpu_OpBrEqImm_1   )
Dma_Declare_Descriptor(Cpu_OpBitNot_1    )
Dma_Declare_Descriptor(Cpu_OpBitAnd_1    )
Dma_Declare_Descriptor(Cpu_OpBitOr_1     )
Dma_Declare_Descriptor(Cpu_OpBitEor_1    )
Dma_Declare_Descriptor(Cpu_OpRor_1       )
Dma_Declare_Descriptor(Cpu_OpRol_1       )
Dma_Declare_Descriptor(Cpu_OpLo4_1       )
Dma_Declare_Descriptor(Cpu_OpHi4_1       )
Dma_Declare_Descriptor(Cpu_OpShl4_1      )
Dma_Declare_Descriptor(Cpu_OpJal_1       )
Dma_Declare_Descriptor(Cpu_OpLit32_1     )
Dma_Declare_Descriptor(Cpu_OpLoadByte_1  )
Dma_Declare_Descriptor(Cpu_OpStoreByte_1 )
Dma_Declare_Descriptor(Cpu_OpLoadHalf_1  )
Dma_Declare_Descriptor(Cpu_OpStoreHalf_1 )
Dma_Declare_Descriptor(Cpu_OpLoadWord_1  )
Dma_Declare_Descriptor(Cpu_OpStoreWord_1 )
Dma_Declare_Descriptor(Cpu_OpUndef_1     )

//-----------------------------------------------------------------------------------------
//
// DMACU Literals and Constants
//
//-----------------------------------------------------------------------------------------

/// \brief Constructs the address of an 8-bit literal.
///
/// \note We re-use the identity LUT to provide the literals.
///
/// \param _v is the literal value.
/// \return The address of a literal byte of value \c _v.
#define Dmacu_PtrToByteLiteral(_v) \
    Dma_PtrToAddr(&Lut_Identity[(_v) & 0xFFu])

///
/// Instruction decode table
///
DMACU_ALIGNED(256)
DMACU_PRIVATE const Dmacu_UIntPtr_t Lut_InstructionTable[32u] =
{
    Dma_PtrToAddr(&Cpu_OpNop_1       ), // 0x00 - NOP                                       (No-operation)
    Dma_PtrToAddr(&Cpu_OpMovImm_1    ), // 0x01 - MOV rZ, #imm8                             (Move from 8-bit immediate to register pair)
    Dma_PtrToAddr(&Cpu_OpMov2Imm_1   ), // 0x02 - MOV rZ+1:rZ, #imm16                       (Move from 16-bit immediate to register pair)
    Dma_PtrToAddr(&Cpu_OpMov2Reg_1   ), // 0x03 - MOV rZ+1:rZ, rB:rA                        (Move from register pair to register pair)
    Dma_PtrToAddr(&Cpu_OpAddImm8_1   ), // 0x04 - ADD rZ, rB, #imm8                         (Add 8-bit immediate)
    Dma_PtrToAddr(&Cpu_OpAcyImm8_1   ), // 0x05 - ACY rZ, rB, #imm8                         (Generate carry from add with 8-bit immediate)
    Dma_PtrToAddr(&Cpu_OpAddReg_1    ), // 0x06 - ADD rZ, rB, rA                            (Add 8-bit registers)
    Dma_PtrToAddr(&Cpu_OpAcyReg_1    ), // 0x07 - ACY rZ, rB, rA                            (Generate carry from add with 8-bit registers)
    Dma_PtrToAddr(&Cpu_OpJmpImm16_1  ), // 0x08 - JMP #imm16                                (Jump absolute)
    Dma_PtrToAddr(&Cpu_OpJmpReg16_1  ), // 0x09 - JMP rB:rA                                 (Jump register indirect)
    Dma_PtrToAddr(&Cpu_OpBrNeReg_1   ), // 0x0A - BNE (+off8) rZ, rB                        (Branch if not equal)
    Dma_PtrToAddr(&Cpu_OpBrEqReg_1   ), // 0x0B - BEQ (+off8) rZ, rB                        (Branch if equal)
    Dma_PtrToAddr(&Cpu_OpBrNeImm_1   ), // 0x0C - BNE (+off8) rZ, #imm8                     (Branch if not equal immediate)
    Dma_PtrToAddr(&Cpu_OpBrEqImm_1   ), // 0x0D - BEQ (+off8) rZ, #imm8                     (Branch if equal immediate)
    Dma_PtrToAddr(&Cpu_OpBitNot_1    ), // 0x0E - NOT rZ, rB                                (Bitwise NOT)
    Dma_PtrToAddr(&Cpu_OpBitAnd_1    ), // 0x0F - AND rZ, rB, rA                            (Bitwise AND)
    Dma_PtrToAddr(&Cpu_OpBitOr_1     ), // 0x10 - OR  rZ, rB, rA                            (Bitwise OR)
    Dma_PtrToAddr(&Cpu_OpBitEor_1    ), // 0x11 - EOR rZ, rB, rA                            (Bitwise Exclusive-OR)
    Dma_PtrToAddr(&Cpu_OpRor_1       ), // 0x12 - ROR rZ, zB, #1                            (Rotate-Right by 1)
    Dma_PtrToAddr(&Cpu_OpRol_1       ), // 0x13 - ROL rZ, zB, #1                            (Rotate-Left by 1)
    Dma_PtrToAddr(&Cpu_OpLo4_1       ), // 0x14 - LO4 rZ, rB                                (Extract lower 4 bits)
    Dma_PtrToAddr(&Cpu_OpHi4_1       ), // 0x15 - HI4 rZ, rB                                (Insert upper 4 bits)
    Dma_PtrToAddr(&Cpu_OpShl4_1      ), // 0x16 - SHL rZ, rB, #4                            (Shift left by 4 / multiply by 16)
    Dma_PtrToAddr(&Cpu_OpJal_1       ), // 0x17 - JAL rZ+1:rZ, #imm16                       (Jump and Link)
    Dma_PtrToAddr(&Cpu_OpLit32_1     ), // 0x18 - LIT32 (+off16) rZ+3:rZ+2:rZ+1:rZ          (Load 32-bit literal from a PC relative offset)
    Dma_PtrToAddr(&Cpu_OpLoadByte_1  ), // 0x19 - LDB rZ, [rB+1:rB:rA+1:rA]                 (Load byte indirect)
    Dma_PtrToAddr(&Cpu_OpStoreByte_1 ), // 0x1A - STB rZ, [rB+1:rB:rA+1:rA]                 (Store byte indirect)
    Dma_PtrToAddr(&Cpu_OpLoadHalf_1  ), // 0x1B - LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Load half-word indirect)
    Dma_PtrToAddr(&Cpu_OpStoreHalf_1 ), // 0x1C - STH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Store half-word indirect)
    Dma_PtrToAddr(&Cpu_OpLoadWord_1  ), // 0x1D - LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Load word indirect)
    Dma_PtrToAddr(&Cpu_OpStoreWord_1 ), // 0x1E - STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Store word indirect)
    Dma_PtrToAddr(&Cpu_OpUndef_1     ), // 0x1F - UND #imm24
};

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Execution State
//
//-----------------------------------------------------------------------------------------

typedef struct Dmacu_Cpu
{
    // Register file (256 registers)
    uint8_t RegFile[256u];

    // Guard zone (catches off-by-one/two/three access for regfile corner-cases)
    uint32_t GuardZone;

    // Current program counter
    uint32_t PC;

    // Next program counter
    uint32_t NextPC;

    // Program base address (initial PC)
    uint32_t ProgramBase;

    // Current instruction word
    uint8_t CurrentOPC[4u];

    // Operand values
    struct
    {
        // Current A operand value
        uint32_t A;

        // Current B operand value
        uint32_t B;

        // Current Z result value
        uint32_t Z;
    } Operands;

    // Scratchpad for temporary values
    uint32_t Scratchpad;

    // Active SBOX (for shared logic pipeline)
    uint32_t ActiveLogicSbox;
} Dmacu_Cpu_t;

// Global instance of the CPU execution state
DMACU_PRIVATE Dmacu_Cpu_t gCpu;

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Fetch/Decode/Execute/Writeback Stages
//
//-----------------------------------------------------------------------------------------

Dma_Declare_Descriptor(Cpu_Reset_1)
Dma_Declare_Descriptor(Cpu_Fetch_1)
Dma_Declare_Descriptor(Cpu_Decode_1)

Dma_Declare_Descriptor(Cpu_Writeback_FourRegs)
Dma_Declare_Descriptor(Cpu_Writeback_TwoRegs)
Dma_Declare_Descriptor(Cpu_Writeback_OneReg)
Dma_Declare_Descriptor(Cpu_Writeback_PC)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Reset
//
//-----------------------------------------------------------------------------------------

Dma_Declare_Descriptor(Cpu_Reset_2)

// RST.1: Capture the program base address (=initial PC)
Dma_ByteCopy(Cpu_Reset_1, &gCpu.ProgramBase, &gCpu.PC, sizeof(uint32_t),   &Cpu_Reset_2)

// RST.2: Clear the register file
Dma_ByteFill(Cpu_Reset_2, &gCpu.RegFile[0], Dmacu_PtrToByteLiteral(0x00u), sizeof(gCpu.RegFile), &Cpu_Fetch_1)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Fetch Stage
//
//-----------------------------------------------------------------------------------------

Dma_Declare_Descriptor(Cpu_Fetch_2)
Dma_Declare_Descriptor(Cpu_Fetch_3)
Dma_Declare_Descriptor(Cpu_Fetch_4)

// FE.1: Setup source address for instruction fetch
Dma_PatchSrc(Cpu_Fetch_1, &Cpu_Fetch_2, &gCpu.PC, &Cpu_Fetch_2)

// FE.2: Fetch current instruction into opcode buffer
Dma_ByteCopy(Cpu_Fetch_2, &gCpu.CurrentOPC[0], DMACU_INVALID_ADDR, sizeof(gCpu.CurrentOPC), &Cpu_Fetch_3)

// FE.3: Generate lower 16 bit of next program counter

// FIXME: Implement Cpu_AddImm16
// Cpu_Add16Imm Cpu_NextPC, Cpu_PC, 4, .LCpu_Fetch.4

// FE.4: Copy upper 16 bit of program counter then link to decode stage
Dma_ByteCopy(Cpu_Fetch_4, Dma_PtrToAddr(&gCpu.NextPC) + 2u, Dma_PtrToAddr(&gCpu.PC) + 2u, 2u, &Cpu_Decode_1)


//-----------------------------------------------------------------------------------------
//
// DMACU CPU Decode Stage
//
//-----------------------------------------------------------------------------------------

Dma_Declare_Descriptor(Cpu_Decode_2)
Dma_Declare_Descriptor(Cpu_Decode_3)
Dma_Declare_Descriptor(Cpu_Decode_4)
Dma_Declare_Descriptor(Cpu_Decode_5)
Dma_Declare_Descriptor(Cpu_Decode_6)
Dma_Declare_Descriptor(Cpu_Decode_7)
Dma_Declare_Descriptor(Cpu_Decode_8)

// DE.1: Generate the LLI address to the opcode (via tableswitch on opcode)
//  Major opcode is in CurrentOPC[31:24]
//
// FIXME: Implement Dma_TableSwitch64
// Dma_TableSwitch64 (.LCpu_Decode.8 + 8), (Cpu_CurrentOPC + 3), Lut_InstructionTable, .LCpu_Decode.2

// DE.2: Clear the current A. B and Z operand values
Dma_ByteFill(Cpu_Decode_2, &gCpu.Operands, Dmacu_PtrToByteLiteral(0x00), sizeof(gCpu.Operands), &Cpu_Decode_3)

// DE.3: Prepare loading the A operand from Regfile[CurrentOPC[7:0]] (rA)
Dma_PatchSrcLo8(Cpu_Decode_3, &Cpu_Decode_4, &gCpu.CurrentOPC[0u], &Cpu_Decode_4)

// DE.4: Load the A operand from Regfile[CurrentOPC[7:0]] (rA)
//
// NOTE: We always load rA+1:rA
Dma_ByteCopy(Cpu_Decode_4, &gCpu.Operands.A, &gCpu.RegFile[0], 2u, &Cpu_Decode_5)

// DE.5: Prepare loading the B operand from Regfile[CurrentOPC[15:8]] (rB)
Dma_PatchSrcLo8(Cpu_Decode_5, &Cpu_Decode_6, &gCpu.CurrentOPC[1u], &Cpu_Decode_6)

// DE.6: Load the B operand from Regfile[CurrentOPC[15:8]] (rB)
//
// NOTE: We always load rB+1:rB
Dma_ByteCopy(Cpu_Decode_6, &gCpu.Operands.B, &gCpu.RegFile[0u], 2u, &Cpu_Decode_7)

// DE.7: Prepare loading the Z operand from Regfile[CurrentOPC[23:16]] (rZ)
Dma_PatchSrcLo8(Cpu_Decode_7, &Cpu_Decode_8, &gCpu.CurrentOPC[2u], &Cpu_Decode_8)

// DE.8: Load the Z operand from Regfile[CurrentOPC[23:16]] (rB)
//   Then dispatch to the execute stage (LLI patched by .LCpu_Decode.1)
//
// NOTE: We always load rZ+3:rZ+2:rZ+1:rZ+0
Dma_ByteCopy(Cpu_Decode_8, &gCpu.Operands.Z, &gCpu.RegFile[0u], 4u, DMACU_INVALID_ADDR)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Writeback Stage
//
// - TODO: We should be able to merge the rZ decode and regfile writeback part if we introduce
//   a Dma_PatchSize8 to patch the transfer size (and patch the "commit" descriptor)
//
//-----------------------------------------------------------------------------------------

Dma_Declare_Descriptor(Cpu_Writeback_FourRegs_Commit)
Dma_Declare_Descriptor(Cpu_Writeback_TwoRegs_Commit)
Dma_Declare_Descriptor(Cpu_Writeback_OneReg_Commit)

// WB.FOUR.1: Setup copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
Dma_PatchDstLo8(Cpu_Writeback_FourRegs, &Cpu_Writeback_FourRegs_Commit, &gCpu.CurrentOPC[2u], &Cpu_Writeback_FourRegs_Commit)

// WB.FOUR.2: Do copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
Dma_ByteCopy(Cpu_Writeback_FourRegs_Commit, &gCpu.RegFile[0u], &gCpu.Operands.Z, 4u, &Cpu_Writeback_PC)

// WB.TWO.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
Dma_PatchDstLo8(Cpu_Writeback_TwoRegs, &Cpu_Writeback_TwoRegs_Commit, &gCpu.CurrentOPC[2u], &Cpu_Writeback_TwoRegs_Commit)

// WB.TWO.2: Do copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
Dma_ByteCopy(Cpu_Writeback_TwoRegs_Commit, &gCpu.RegFile[0u], &gCpu.Operands.Z, 2u, &Cpu_Writeback_PC)

// WB.ONE.1: Setup copy from CurrentZ[7:0] to Regfile[rZ]
Dma_PatchDstLo8(Cpu_Writeback_OneReg, &Cpu_Writeback_OneReg_Commit, &gCpu.CurrentOPC[2u], &Cpu_Writeback_OneReg_Commit)

// WB.ONE.2: Do copy from CurrentZ[7:0] to Regfile[rZ]
Dma_ByteCopy(Cpu_Writeback_OneReg_Commit, &gCpu.RegFile[0], &gCpu.Operands.Z, 1u, &Cpu_Writeback_PC)

// WB.PC: Copy NextPC to PC, link to fetch stage
Dma_ByteCopy(Cpu_Writeback_PC, &gCpu.PC, &gCpu.NextPC, 4u, &Cpu_Fetch_1)
