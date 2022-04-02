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
#include "dmacu.h"

#pragma clang diagnostic ignored "-Wunused-const-variable"
#pragma clang diagnostic ignored "-Wunused-variable"

//-------------------------------------------------------------------------------------------------
// DMA descriptor manipulation helpers
//

/// \brief Patches a field of a DMA descriptor
///
/// Patches field @p _field of the DMA descriptor at @p _desc with @p _size bytes
/// from @p _src. Then links to descriptor @p _lli
#define Dma_PatchField(_self,_dst,_field,_off,_src,_size,_lli) \
    Dma_ByteCopy(_self, \
        (Dma_PtrToAddr(_dst) + Dma_OffsetOf(Dma_Descriptor_t, _field) + ((uint32_t) (_off))), \
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
    Dma_Declare_Local_Descriptor(_self, Sbox8_Lookup) \
    Dma_PatchSrc(_self, Dma_Local_Reference(_self, Sbox8_Lookup), (_tableptr), (_lli))

// Reads a byte from "src", looks up the matching word from the table at "table" and stores
// the (word) result at "dst". Then links to the next descriptor at "lli".
//
// C model:
//   void Dma_TableSwitch64(uint32_t* dst, const uint8_t* src, const uint32_t table[64u])
//   {
//     *dst = table[*src % 64u];
//   }
//
// Constraints:
//  The value table must be aligned on a 256 byte boundary. The byte value at "src" must be
//  should be in range 0..63 (the construction of Lut_TableSwitch64 ensures that byte values >=64
//  are reduced modulo 64 for purpose of lookup address generation).
//
#define Dma_TableSwitch64(_self,_dst,_src,_table,_lli) \
	/* Step 1: Patch the byte-copy operation that performs the fetch from the table lookup */ \
	/*         We actually perform an SBOX lookup into the multiply-by-4 LUT for the patch */ \
	Dma_Declare_Local_Descriptor(_self, TableSwitch_DoLookup) \
	Dma_Sbox8(_self, \
		&Dma_Local_Reference(_self, TableSwitch_DoLookup)->src, \
		(_src), \
		&Lut_Mul4[0u], \
		Dma_Local_Reference(_self, TableSwitch_DoLookup) \
	) \
	/* Step 2: Read a 4-byte value from the table. */ \
	Dma_ByteCopy(Dma_Local_Name(_self, TableSwitch_DoLookup), (_dst), (_table), 4u, (_lli))


// Temporary LUTs
DMACU_ALIGNED(256u) DMACU_PRIVATE uint8_t Lut_Temporary[256u];
DMACU_PRIVATE uint8_t Lut_Scratchpad[16u];

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

//
// 8-bit arbitrary logic function (AND/OR/XOR) with 2 inputs.
//
// Reads two source bytes from "src1" and "src2", applies the logic function described
// by the 4-bit x 4-bit lookup table "table" and stores the result in "dst". Then links
// to next descriptor at "lli".
//
// Storing a full LUT for 8-bit inputs src1 and src2 would require 64k entries. We use a divide and conquer
// approach to implement 8-bit logic functions on top of 4-bit x 4-bit LUT:
//
// C model:
//   void Dma_LogicSbox4(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, const uint8_t *table)
//   {
//      uint lo = table[(*src1 & 0x0F) + ((*src2 & 0x0F) << 4u)];
//      uint hi = table[((*src1 >> 4) & 0x0F) + (((*src2 >> 4) & 0x0F) << 4u)];
//      *dst = (hi << 4) + lo;
//   }
//
// Constraints:
//   This operation uses Lut_Scratchpad for processing.
//   This macro defines local labels "1" and "2" to enable seamless interaction with Dma_LogicSbox4_Indirect
//
#define Dma_LogicSbox4(_self,_dst,_src1,_src2,_table,_lli) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo4_B) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo4_Mul16_B) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo_Combine) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo_Lookup) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi4_A) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi4_B) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi4_Mul16_B) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi_Combine) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi_Lookup) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi_Shift) \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Result) \
	/* Step 1: Extract lower 4 bits of operand A into t0 */ \
	Dma_Sbox8(_self, \
		&Lut_Scratchpad[0u], \
		(_src1), \
		&Lut_Lo4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Lo4_B) \
	) \
	/* Step 2: Extract lower 4 bits of operand B into t1 */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Lo4_B), \
		&Lut_Scratchpad[1u], \
		(_src2), \
		&Lut_Lo4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Lo4_Mul16_B) \
	) \
	/* Step 3: Multiply t1 by 16 */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Lo4_Mul16_B), \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[1u], \
		&Lut_Mul16[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Lo_Combine) \
	) \
	/* Step 4: Add t0 and t1 to get the lookup table index into the 4-bit x 4-bit LUT */ \
	Dma_Add8(Dma_Local_Name(_self, LogicSbox4_Lo_Combine), \
		 &Lut_Scratchpad[2u], \
		 &Lut_Scratchpad[1u], \
		 &Lut_Scratchpad[0u], \
		 Dma_Local_Reference(_self, LogicSbox4_Lo_Lookup) \
	) \
	/* Step 5: Lookup on lower 4 bits */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Lo_Lookup), \
		 &Lut_Scratchpad[2u], \
		 &Lut_Scratchpad[2u], \
		 (_table), \
		 Dma_Local_Reference(_self, LogicSbox4_Hi4_A) \
	) \
	/* Step 6: Extract lower 4 bits of operand A into t0 */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Hi4_A), \
		&Lut_Scratchpad[0u], \
		(_src1), \
		&Lut_Hi4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi4_B) \
	) \
	/* Step 7: Extract lower 4 bits of operand B into t1 */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Hi4_B), \
		&Lut_Scratchpad[1u], \
		(_src2), \
		&Lut_Hi4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi4_Mul16_B) \
	) \
	/* Step 8: Multiply t1 by 16 */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Hi4_Mul16_B), \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[1u], \
		&Lut_Mul16[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi_Combine) \
	) \
	/* Step 9: Add t0 and t1 to get the lookup table index into the 4-bit x 4-bit LUT */ \
	Dma_Add8(Dma_Local_Name(_self, LogicSbox4_Hi_Combine), \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi_Lookup) \
	) \
	/* Step 10: Lookup on upper 4 bits */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Hi_Lookup), \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[1u], \
		(_table), \
		Dma_Local_Reference(_self, LogicSbox4_Hi_Shift) \
	) \
	/* Step 11: Shift lookup result for higer bits by 4 bits */ \
	Dma_Sbox8(Dma_Local_Name(_self, LogicSbox4_Hi_Shift), \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[1u], \
		&Lut_Mul16[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Result) \
	) \
	/* Step 12: Assemble the result, then link to writeback */ \
	Dma_Add8(Dma_Local_Name(_self, LogicSbox4_Result), \
		(_dst), \
		&Lut_Scratchpad[1u], \
		&Lut_Scratchpad[2u], \
		(_lli) \
	)

//
// 8-bit arbitrary logic function (AND/OR/XOR) with 2 inputs.
//
// This operation is a variant of Dma_LogicSbox4, which indirecly fetches
// the pointer to the logic lookup table. It can be used to factor-out the
// logic operations into a reusable descriptor chain.
//
// See Dma_LogicSbox4 for details on the operation.
//
// C model:
//   void Dma_LogicSbox4_Indirect(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, const uint8_t *const *pointer_to_table)
//   {
//      const uint8_t *table = *pointer_to_table ;
//      Dma_LogicSbox4(dst, src1, src2, table)
//   }
//
// Constraints:
//   This operation uses Lut_Scratchpad for processing
//   This macro defines local labels "1" and "2" to enable seamless interaction with Dma_LogicSbox4
//
#define Dma_LogicSbox4_Indirect(_dst,_src1,_src2,_pointer_to_table,_lli) \
	/* Step 1: Patch the first source lookup location */ \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Indirect_PatchHi) \
	Dma_Declare_Local_Descriptor(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Lo_Lookup) \
	Dma_Sbox8_PatchTableImm(_self, \
		Dma_Local_Reference(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Lo_Lookup), \
		(_pointer_to_table), \
		Dma_Local_Reference(_self,LogicSbox4_Indirect_PatchHi) \
	) \
	/* Step 2: Patch the second source lookup location and link */ \
	Dma_Declare_Local_Descriptor(_self, LogicSbox4_Indirect_Exec) \
	Dma_Declare_Local_Descriptor(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Hi_Lookup) \
	Dma_Sbox8_PatchTableImm(Dma_Local_Name(_self, LogicSbox4_Indirect_Exec), \
		Dma_Local_Reference(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Hi_Lookup), \
		(\pointer_to_table), \
		Dma_Local_Reference(_self,LogicSbox4_Indirect_Exec) \
	) \
	/* Step 3: Implement the Dma_LogicSbox4 chain */ \
	Dma_LogicSbox4(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec), \
		(_dst), \
		(_src1), \
		(_src2), \
		DMA_INVALID_ADDR, \
		(_lli) \
	)

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
// Addition and carry generation
//-----------------------------------------------------------------------------------------

//
// Adds two bytes read from memory operands "src1" and "src2", then stores the result in dst.
//
// C model:
//   void Dma_Add8(uint8_t *dst, const uint8_t *src1, const uint8_t *src2)
//   {
//     *dst = (*src1 + *src2) & 0xFF;
//   }
//
// Constraints:
//   This operation uses Lut_Temporary for processing
//
#define Dma_Add8(_self,_dst,_src1,_src2,_lli) \
	/* Step 1: Load source byte from src1 and patch it into the source address for loading the temporary LUT */ \
	Dma_Declare_Local_Descriptor(_self, Add8_LoadTempLut) \
	Dma_PatchSrcLo8(_self, \
		Dma_Local_Reference(_self, Add8_LoadTempLut), \
		(_src1), \
		Dma_Local_Reference(_self, Add8_LoadTempLut) \
	) \
	/* Step 2: Load the temporary LUT with with the identity LUT (offset by src1 memory operand) */ \
	Dma_Declare_Local_Descriptor(_self, Add8_LookupSum) \
	Dma_ByteCopy(Dma_Local_Name(_self, Add8_LoadTempLut), \
		&Lut_Temporary[0u], \
		&Lut_Identity[0u], \
		0x100u, \
		Dma_Local_Reference(_self, Add8_LookupSum) \
	) \
	/* Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8(Dma_Local_Name(_self, Add8_LookupSum), (_dst), (_src2), &Lut_Temporary[0u], (_lli))

//
// Adds the 8-bit immediate "imm8" to the byte read from memory operand "src1" and stores the
// result in "dst".
//
// C model:
//   void Dma_Add8Imm(uint8_t *dst, const uint8_t *src1, const uint8_t imm8)
//   {
//     *dst = (*src1 + imm8) & 0xFF;
//   }
//
// Constraints:
//   This operation uses Lut_Temporary for processing
//
#define Dma_Add8Imm(_self,_dst,_src1,_imm8,_lli) \
	/* Step 1: Load the temporary LUT with with the identity LUT offset by imm8 operand */ \
	Dma_Declare_Local_Descriptor(_self, Add8Imm_LookupSum) \
	Dma_ByteCopy(_self, \
		&Lut_Temporary[0u], \
		&Lut_Identity[(_imm8) & 0xFFu], \
		0x100u, \
		Dma_Local_Reference(_self, Add8Imm_LookupSum) \
	) \
	/* Step 2: Lookup the sum using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8(Dma_Local_Name(_self, Add8Imm_LookupSum), \
	    (_dst), \
		(_src1), \
		&Lut_Temporary[0u], \
		(_lli) \
	)

//
// Subtracts the 8-bit immediate "imm8" from the byte read from memory operand "src1" and stores the
// result in "dst".
//
// C model:
//   void Dma_Sub8Imm(uint8_t *dst, const uint8_t *src1, const uint8_t imm8)
//   {
//     *dst = (*src1 + (0x100 - imm8)) & 0xFF;
//   }
//
// Constraints:
//   This operation uses Lut_Temporary for processing
//
#define Dma_Sub8Imm(_self,_dst,_src1,_imm8,_lli) \
	/* Implemented as Add8Imm using using the upper half of the identity LUT as starting point. */ \
	Dma_Add8Imm(_self, (_dst), (_src1), (0x100u - (_imm8)), (_lli))

//
// Adds the bytes read from two 8-bit memory operands "src1" and "src2" and stores the
// carry of the addition in "dst".
//
//
// C model:
//   void Dma_CarryFromAdd8(uint8_t *dst, const uint8_t *src1, const uint8_t *src2)
//   {
//     *dst = ((*src1 + *src2) >> 8) & 0x01;
//   }
//
// Constraints:
//   This operation uses Lut_Temporary for processing
//
#define Dma_CarryFromAdd8(_self,_dst,_src1,_src2,_lli) \
	/* Step 1: Patch the source address of the of the carry LUT copy operation */ \
	Dma_Declare_Local_Descriptor(_self, CarryFromAdd8_LoadTempLut) \
	Dma_PatchSrcLo8(_self, \
		Dma_Local_Reference(_self, CarryFromAdd8_LoadTempLut), \
		(_src1), \
		Dma_Local_Reference(_self, CarryFromAdd8_LoadTempLut) \
	) \
	/* Step 2: Load the temporary LUT with with the carry LUT offset by imm8 operand */ \
	Dma_Declare_Local_Descriptor(_self, CarryFromAdd8_LookupCarry) \
	Dma_ByteCopy(Dma_Local_Name(_self, CarryFromAdd8_LoadTempLut), \
	    &Lut_Temporary[0u], \
		&Lut_Carry[0u], \
		0x100u, \
		Dma_Local_Reference(_self, CarryFromAdd8_LookupCarry) \
	) \
	/* Step 3: Lookup the carry using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8(Dma_Local_Name(_self, CarryFromAdd8_LookupCarry), \
		(_dst), \
		(_src2), \
		&Lut_Temporary[0u], \
		(_lli) \
	)

//
// Adds the 8-bit immediate "imm8" to the byte read from memory operand "src1" and stores
// the carry of the addition in "dst".
//
// C model:
//   void Dma_CarryFromAdd8Imm(uint8_t *dst, const uint8_t *src1, const uint8_t imm8)
//   {
//     *dst = ((*src1 + imm8) >> 8) & 0x01;
//   }
//
// Constraints:
//   This operation uses Lut_Temporary for processing
//
#define Dma_CarryFromAdd8Imm(_self,_dst,_src1,_imm8,_lli) \
	/* Step 1: Load the temporary LUT with with the carry LUT offset by imm8 operand */ \
	Dma_Declare_Local_Descriptor(_self, CarryFromAdd8Imm_LookupCarry) \
	Dma_ByteCopy(_self, \
		&Lut_Temporary[0u], \
		&Lut_Carry[(_imm8) & 0xFFu], \
		0x100u, \
		Dma_Local_Reference(_self,CarryFromAdd8Imm_LookupCarry) \
	) \
	/* Step 2: Lookup the carry using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8(Dma_Local_Name(_self, CarryFromAdd8Imm_LookupCarry), \
	    (_dst), \
		(_src1), \
		&Lut_Temporary[0u], \
		(_lli) \
	)

//-----------------------------------------------------------------------------------------
//
// Arithmetic/Logic helpers for the CPU
//
//-----------------------------------------------------------------------------------------

//
// Add 8-bit immediate imm8 to 16-bit value (little endian) at memory operand src1 and store the result in dst1
//
// This operation uses Lut_Temporary and Cpu_Scratchpad for processing
//
#define Cpu_Add16Imm(_self,_dst,_src1,_imm8,_lli) \
	/* Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the */ \
	/*   immediate of the upper part of the addition */ \
	Dma_Declare_Local_Descriptor(_self, Add16Imm_AddLo8) \
	Dma_CarryFromAdd8Imm(_self, \
		&gCpu.Scratchpad[0u], \
		(_src1), \
		(_imm8), \
		Dma_Local_Reference(_self, Add16Imm_AddLo8) \
	) \
	/* Step 2: Perform the 8-bit addition in the lower byte */ \
	Dma_Declare_Local_Descriptor(_self, Add16Imm_AddHi8) \
	Dma_Add8Imm(Dma_Local_Name(_self, Add16Imm_AddLo8), \
		(Dma_PtrToAddr(_dst)  + 0u), \
		(Dma_PtrToAddr(_src1) + 0u), \
		(_imm8), \
		Dma_Local_Reference(_self, Add16Imm_AddHi8) \
	) \
	/* Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value) */ \
	Dma_Add8(Dma_Local_Name(_self, Add16Imm_AddHi8), \
		(Dma_PtrToAddr(_dst)  + 1u), \
		(Dma_PtrToAddr(_src1) + 1u), \
	 	&gCpu.Scratchpad[0u], \
		(_lli) \
	)

//
// Adds an 8-bit value (in src2) to 16-bit value (little endian) at memory operand src1 and store the result in dst1
//
// This operation uses Lut_Temporary and Cpu_Scratchpad for processing
//
#define Cpu_Add8to16(_self,_dst,_src1,_src2,_lli) \
	Dma_Declare_Local_Descriptor(_self, Add8to16_AddLo8) \
	Dma_Declare_Local_Descriptor(_self, Add8to16_AddHi8) \
	/* Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the */ \
	/* immediate of the upper part of the addition */ \
	Dma_CarryFromAdd8(_self, \
		&gCpu.Scratchpad[0u], \
		(_src1), \
		(_src2), \
		Dma_Local_Reference(_self, Add8to16_AddLo8) \
	) \
	/* Step 2: Perform the 8-bit addition in the lower byte */ \
	Dma_Add8(Dma_Local_Name(_self, Add8to16_AddLo8), \
		(Dma_PtrToAddr(_dst)  + 0u), \
		(Dma_PtrToAddr(_src1) + 0u), \
		(Dma_PtrToAddr(_src2) + 0u), \
		Dma_Local_Reference(_self, Add8to16_AddHi8) \
	) \
	/* Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value) */ \
	Dma_Add8(Dma_Local_Name(_self, Add8to16_AddHi8), \
		(Dma_PtrToAddr(_dst)  + 1u), \
		(Dma_PtrToAddr(_src1) + 1u), \
		&gCpu.Scratchpad[0u], \
		(_lli) \
	)

//
// 8-bit arbitrary logic function (AND/OR/XOR)
//
// Storing a full LUT for 8-bit inputs src1 and src2 would require 64k entries. We use a divide and conquer
// approach to implement 8-bit logic functions on top of 4-bit x 4-bit LUT:
//
// FIXME: Back-port the shared Cpu_Execute_Logic chain from the assembler implementation (this saves
// significantly on space, as we only need _one_ instance of Dma_LogicSbox4 from a constant sbox).
//
#define Cpu_LogicSbox4(_self,_table) \
	/* In-place implementation  */ \
	Dma_LogicSbox4(_self, \
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u), \
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u), \
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u), \
		(_table), \
		&Cpu_Writeback_OneReg \
	)

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
DMACU_PRIVATE const Dma_UIntPtr_t Lut_InstructionTable[32u] =
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

// Global instance of the CPU execution state
DMACU_PRIVATE Dmacu_Cpu_t gCpu;

//-----------------------------------------------------------------------------------------
extern Dmacu_Cpu_t* Dmacu_GetCpu(void)
{
	return &gCpu;
}

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
void Dmacu_Run(const uint32_t *initial_pc)
{
	// Setup the CPU's initial program counter
    gCpu.ProgramBase = Dma_PtrToAddr(initial_pc);

	// Start execution of our virtual CPU
    Hal_DmaTransfer(&Cpu_Reset_1);
}

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
Dma_ByteCopy(Cpu_Fetch_2, &gCpu.CurrentOPC.Bytes[0], DMA_INVALID_ADDR, sizeof(gCpu.CurrentOPC), &Cpu_Fetch_3)

// FE.3: Generate lower 16 bit of next program counter
Cpu_Add16Imm(Cpu_Fetch_3, &gCpu.NextPC, &gCpu.PC, 4u, &Cpu_Fetch_4)

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
//  Major opcode is in CurrentOPC.Bytes[31:24]
//
Dma_TableSwitch64(Cpu_Decode_1, &Cpu_Decode_8.lli, &gCpu.CurrentOPC.Bytes[3u], &Lut_InstructionTable[0u], &Cpu_Decode_2)

// DE.2: Clear the current A. B and Z operand values
Dma_ByteFill(Cpu_Decode_2, &gCpu.Operands, Dmacu_PtrToByteLiteral(0x00), sizeof(gCpu.Operands), &Cpu_Decode_3)

// DE.3: Prepare loading the A operand from Regfile[CurrentOPC.Bytes[7:0]] (rA)
Dma_PatchSrcLo8(Cpu_Decode_3, &Cpu_Decode_4, &gCpu.CurrentOPC.Bytes[0u], &Cpu_Decode_4)

// DE.4: Load the A operand from Regfile[CurrentOPC.Bytes[7:0]] (rA)
//
// NOTE: We always load rA+1:rA
Dma_ByteCopy(Cpu_Decode_4, &gCpu.Operands.A, &gCpu.RegFile[0], 2u, &Cpu_Decode_5)

// DE.5: Prepare loading the B operand from Regfile[CurrentOPC.Bytes[15:8]] (rB)
Dma_PatchSrcLo8(Cpu_Decode_5, &Cpu_Decode_6, &gCpu.CurrentOPC.Bytes[1u], &Cpu_Decode_6)

// DE.6: Load the B operand from Regfile[CurrentOPC.Bytes[15:8]] (rB)
//
// NOTE: We always load rB+1:rB
Dma_ByteCopy(Cpu_Decode_6, &gCpu.Operands.B, &gCpu.RegFile[0u], 2u, &Cpu_Decode_7)

// DE.7: Prepare loading the Z operand from Regfile[CurrentOPC.Bytes[23:16]] (rZ)
Dma_PatchSrcLo8(Cpu_Decode_7, &Cpu_Decode_8, &gCpu.CurrentOPC.Bytes[2u], &Cpu_Decode_8)

// DE.8: Load the Z operand from Regfile[CurrentOPC.Bytes[23:16]] (rB)
//   Then dispatch to the execute stage (LLI patched by .LCpu_Decode.1)
//
// NOTE: We always load rZ+3:rZ+2:rZ+1:rZ+0
Dma_ByteCopy(Cpu_Decode_8, &gCpu.Operands.Z, &gCpu.RegFile[0u], 4u, DMA_INVALID_ADDR)

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
Dma_PatchDstLo8(Cpu_Writeback_FourRegs, &Cpu_Writeback_FourRegs_Commit, &gCpu.CurrentOPC.Bytes[2u], &Cpu_Writeback_FourRegs_Commit)

// WB.FOUR.2: Do copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
Dma_ByteCopy(Cpu_Writeback_FourRegs_Commit, &gCpu.RegFile[0u], &gCpu.Operands.Z, 4u, &Cpu_Writeback_PC)

// WB.TWO.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
Dma_PatchDstLo8(Cpu_Writeback_TwoRegs, &Cpu_Writeback_TwoRegs_Commit, &gCpu.CurrentOPC.Bytes[2u], &Cpu_Writeback_TwoRegs_Commit)

// WB.TWO.2: Do copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
Dma_ByteCopy(Cpu_Writeback_TwoRegs_Commit, &gCpu.RegFile[0u], &gCpu.Operands.Z, 2u, &Cpu_Writeback_PC)

// WB.ONE.1: Setup copy from CurrentZ[7:0] to Regfile[rZ]
Dma_PatchDstLo8(Cpu_Writeback_OneReg, &Cpu_Writeback_OneReg_Commit, &gCpu.CurrentOPC.Bytes[2u], &Cpu_Writeback_OneReg_Commit)

// WB.ONE.2: Do copy from CurrentZ[7:0] to Regfile[rZ]
Dma_ByteCopy(Cpu_Writeback_OneReg_Commit, &gCpu.RegFile[0], &gCpu.Operands.Z, 1u, &Cpu_Writeback_PC)

// WB.PC: Copy NextPC to PC, link to fetch stage
Dma_ByteCopy(Cpu_Writeback_PC, &gCpu.PC, &gCpu.NextPC, 4u, &Cpu_Fetch_1)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Opcodes (Execute Stage)
//
//-----------------------------------------------------------------------------------------

#define Cpu_Opcode_Begin(name)
#define Cpu_Opcode_End(name)

//
// NOP       - No Operation
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x00 | (0)  | (0)  | (0)  |
// +------+------+------+------+
//
// The NOP instruction is implemented as a dummy copy in the CPU scratchpad followed by a link
// to the PC writeback stage (No separate DMA descriptors needed).
//
Cpu_Opcode_Begin(Nop)
	Dma_ByteCopy(Cpu_OpNop_1, &gCpu.Scratchpad[0u], &gCpu.Scratchpad[0u], 1u, &Cpu_Writeback_PC)
Cpu_Opcode_Begin(Nop)

//
// MOV rZ, #imm8 - Move to register from 8-bit immediate
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x01 | rZ   | (0)  | imm8 |
// +------+------+------+------+
//
// Copy from CurrentOPC.Bytes[7:0] to CurrentZ, then link to one register writeback.
//
Cpu_Opcode_Begin(MovImm)
	Dma_ByteCopy(Cpu_OpMovImm_1, &gCpu.Operands.Z, &gCpu.CurrentOPC.Bytes[0u], 1u, &Cpu_Writeback_OneReg)
Cpu_Opcode_End(MovImm)

//
// MOV rZ+1:rZ, #imm16 - Move to register pair from 16-bit immediate
//
//  31  24     16             0
// +------+------+-------------+
// | 0x02 | rZ   |       imm16 |
// +------+------+-------------+
//
Cpu_Opcode_Begin(Mov2Imm)
	// Copy from CurrentOPC.Bytes[15:0] to CurrentZ, then link to one register writeback
	Dma_ByteCopy(Cpu_OpMov2Imm_1, &gCpu.Operands.Z, &gCpu.CurrentOPC.Bytes[0u], 2u, &Cpu_Writeback_TwoRegs)
Cpu_Opcode_End(Mov2Imm)

//
// MOV2 rZ+1:rZ, rB:rA - Move from register pair to register pair
// MOV  rZ, rA         - (Pseudo-Instruction) Move from register to register (if rB=rZ+1)
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x03 |  rZ  | rB   |  rA  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(Mov2Reg)
	Dma_Declare_Descriptor(Cpu_OpMov2Reg_2)

	// Copy from CurrentA to CurrentZ{7:0]
	Dma_ByteCopy(Cpu_OpMov2Reg_1, (Dma_PtrToAddr(&gCpu.Operands.Z) + 0u), &gCpu.Operands.A, 1u, &Cpu_OpMov2Reg_2)

	// Copy from CurrentB to CurrentZ[15:8]
	Dma_ByteCopy(Cpu_OpMov2Reg_2, (Dma_PtrToAddr(&gCpu.Operands.Z) + 1u), &gCpu.Operands.B, 1u, &Cpu_Writeback_TwoRegs)
Cpu_Opcode_End(Mov2Reg)

//
// ADD rZ, rB, #imm8               - Add register and 8-bit immediate
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x04 |  rZ  | rB   | imm8 |
// +------+------+------+------+
//
Cpu_Opcode_Begin(AddImm8)
	// Add the 8-bit immediate (from instruction word [7:0]) to rB, store result in rZ
	Dma_Add8(Cpu_OpAddImm8_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&gCpu.CurrentOPC.Bytes[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(AddImm8)

// `
// `ACY rZ, rB, #imm8               - Generate carry from add with 8-bit immediate
// `
// ` 31  24     16      8      0
// `+------+------+------+------+
// `| 0x05 |  rZ  | rB   | imm8 |
// `+------+------+------+------+
// `
Cpu_Opcode_Begin(AcyImm8)
	// Generate the carry from rB+imm8, store in rZ
	Dma_CarryFromAdd8(Cpu_OpAcyImm8_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&gCpu.CurrentOPC.Bytes[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(AcyImm8)

//
// ADD rZ, rB, rA                  - Add two registers
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x06 |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(AddReg)
	// Add  rA and rB, store result in rZ
	Dma_Add8(Cpu_OpAddReg_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(AddReg)

//
// ACY rZ, rB, rA                 - Generate carry from add with 8-bit registers
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x07 |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(AcyReg)
	// Generate the carry from rA+rB, store in rZ
	Dma_CarryFromAdd8(Cpu_OpAcyReg_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(AcyReg)

//
// JMP #imm16                    - Jump absolute
//
//  31  24 23                 0
// +------+------+-------------+
// | 0x08 |  (0) | imm16       |
// +------+------+-------------+
//
Cpu_Opcode_Begin(JmpImm16)
	Dma_Declare_Descriptor(Cpu_OpJmpImm16_2)
	Dma_Declare_Descriptor(Cpu_OpJmpImm16_3)
	Dma_Declare_Descriptor(Cpu_OpJmpImm16_4)

	// Load the program base into Cpu_NextPC
	Dma_ByteCopy(Cpu_OpJmpImm16_1,
		(Dma_PtrToAddr(&gCpu.NextPC) + 0u),
		(Dma_PtrToAddr(&gCpu.ProgramBase) + 0u),
		4u,
		&Cpu_OpJmpImm16_2
	)

	// Add lower 8-bit to program counter
	Cpu_Add8to16(Cpu_OpJmpImm16_2,
		(Dma_PtrToAddr(&gCpu.NextPC) + 0u),
		(Dma_PtrToAddr(&gCpu.ProgramBase) + 0u),
		&gCpu.CurrentOPC.Bytes[0u],
		&Cpu_OpJmpImm16_3
	)

	// Add upper 8-bit to program counter
	Cpu_Add8to16(Cpu_OpJmpImm16_3,
		(Dma_PtrToAddr(&gCpu.NextPC) + 1u),
		(Dma_PtrToAddr(&gCpu.NextPC) + 1u),
		&gCpu.CurrentOPC.Bytes[1u],
		&Cpu_OpJmpImm16_4
	)

	// Clip the upper 16 bit to the program base (this ensures module-16 behavior that is consistent
	// with the normal program counter increments). Then resume at fetch stage.
	Dma_ByteCopy(Cpu_OpJmpImm16_4,
		(Dma_PtrToAddr(&gCpu.NextPC) + 2u),
		(Dma_PtrToAddr(&gCpu.ProgramBase) + 2u),
		2,
		&Cpu_Writeback_PC
	)
Cpu_Opcode_End(JmpImm16)

//
// JMP rB:rA                    - Jump register indirect
//
// +------+------+------+------+
// | 0x09 |  (0) | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(JmpReg16)
	Dma_Declare_Descriptor(Cpu_OpJmpReg16_2)

	// Copy rB:rA into lower 16 bits of CurrentOPC, then delegate to JmpImm16

	// TODO: Merge into a single copy operation for two bytes
	Dma_ByteCopy(Cpu_OpJmpReg16_1,
		&gCpu.CurrentOPC.Bytes[0u],
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		1u,
		&Cpu_OpJmpReg16_2
	)

	Dma_ByteCopy(Cpu_OpJmpReg16_2,
		&gCpu.CurrentOPC.Bytes[1u],
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		1u,
		&Cpu_OpJmpImm16_1
	)
Cpu_Opcode_End(JmpReg16)

//
// BNE (+off8) rZ, rB                   - Branch if not equal
//
// +------+------+------+------+
// | 0x0A |  rZ  | rB   | off8 |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BrNeReg)
	// Copy rB value into imm8 field, to BrNeImm
	Dma_ByteCopy(Cpu_OpBrNeReg_1,
		&gCpu.CurrentOPC.Bytes[1u],
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		1u,
		&Cpu_OpBrNeImm_1
	)
Cpu_Opcode_End(BrNeReg)

//
// BEQ (+off8) rZ, rB                   - Branch if equal
//
// +------+------+------+------+
// | 0x0B |  rZ  | rB   | off8 |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BrEqReg)
	// Copy rB value into imm8 field, to BrEqImm
	Dma_ByteCopy(Cpu_OpBrEqReg_1,
		&gCpu.CurrentOPC.Bytes[1u],
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		1u,
		&Cpu_OpBrEqImm_1
	)
Cpu_Opcode_End(BrEqReg)

//
// BNE (+off8) rZ, #imm8                - Branch if not equal
//
// +------+------+------+------+
// | 0x0C |  rZ  | imm8 | off8 |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BrNeImm)
	Dma_Declare_Descriptor(Cpu_OpBrNeImm_2)
	Dma_Declare_Descriptor(Cpu_OpBrNeImm_3)
	Dma_Declare_Descriptor(Cpu_OpBrNeImm_4)
	Dma_Declare_Descriptor(Cpu_OpBrNeImm_5)
	Dma_Declare_Descriptor(Cpu_OpBrNeImm_6)

	// Fill the temporary LUT with the offset for branch taken (+off8)
	Dma_ByteFill(Cpu_OpBrNeImm_1,
		&Lut_Temporary[0u],
		&gCpu.CurrentOPC.Bytes[0u],
		256u,
		&Cpu_OpBrNeImm_2
	)

	// Prepare for patching the match location with offset for branch not taken (+4)
	Dma_PatchDstLo8(Cpu_OpBrNeImm_2,
		&Cpu_OpBrNeImm_3,
		&gCpu.CurrentOPC.Bytes[1u],
		&Cpu_OpBrNeImm_3
	)

	// Patch the branch not taken location in the temporary LUT
	Dma_ByteCopy(Cpu_OpBrNeImm_3,
		&Lut_Temporary[0u],
		Dmacu_PtrToByteLiteral(4u),
		1u,
		&Cpu_OpBrNeImm_4
	)

	// Lookup the branch offset from the temporary LUT
	Dma_Sbox8(Cpu_OpBrNeImm_4,
		&gCpu.Scratchpad[1u],
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		&Lut_Temporary[0u],
		&Cpu_OpBrNeImm_5
	)

	// Update the lower 16-bits of the next PC (keep upper 16 bits intact)
	Cpu_Add8to16(Cpu_OpBrNeImm_5,
		(Dma_PtrToAddr(&gCpu.NextPC) + 0u),
		(Dma_PtrToAddr(&gCpu.PC) + 0u),
		&gCpu.Scratchpad[1u],
		&Cpu_OpBrNeImm_6
	)

	// Clip the upper 16 bit
	Dma_ByteCopy(Cpu_OpBrNeImm_6,
		(Dma_PtrToAddr(&gCpu.NextPC) + 2u),
		(Dma_PtrToAddr(&gCpu.PC) + 2u),
		2u,
		&Cpu_Writeback_PC
	)
Cpu_Opcode_End(BrNeImm)

//
// BEQ (+off8) rZ, #imm8                - Branch if equal
//
// +------+------+------+------+
// | 0x0D |  rZ  | imm8 | off8 |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BrEqImm)
	Dma_Declare_Descriptor(Cpu_OpBrEqImm_2)
	Dma_Declare_Descriptor(Cpu_OpBrEqImm_3)

	// Fill the temporary LUT with the offset for branch not taken (+4)
	Dma_ByteFill(Cpu_OpBrEqImm_1,
		&Lut_Temporary[0u],
		Dmacu_PtrToByteLiteral(4u),
		256u,
		&Cpu_OpBrEqImm_2
	)

	// Prepare for patching the match location with offset for branch not taken (+4)
	Dma_PatchDstLo8(Cpu_OpBrEqImm_2,
		&Cpu_OpBrEqImm_3,
		&gCpu.CurrentOPC.Bytes[1u],
		&Cpu_OpBrEqImm_3
	)

	// Patch the branch taken location in the temporary LUT; then tail-call to the BrNeImm implemntation (from stage 4)
	Dma_ByteCopy(Cpu_OpBrEqImm_3,
		&Lut_Temporary[0u],
		&gCpu.CurrentOPC.Bytes[0u],
		1u,
		&Cpu_OpBrNeImm_4
	)
Cpu_Opcode_End(BrEqImm)

//
// NOT rZ, rB                      - Bitwise NOT
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x0E |  rZ  | rB   | (0)  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BitNot)
	// Lookup via bitwise NOT table
	Dma_Sbox8(Cpu_OpBitNot_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Lut_BitNot[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(BitNot)

//
// AND rZ, rB, rA                  - Bitwise AND
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x0F |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BitAnd)
	// Lookup via 4-bit x 4-bit logic AND LUT
	Cpu_LogicSbox4(Cpu_OpBitAnd_1, &Lut_BitAnd[0u])
Cpu_Opcode_End(BitAnd)

//
// OR  rZ, rB, rA                  - Bitwise OR
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x10 |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BitOr)
	// Lookup via 4-bit x 4-bit logic AND LUT
	Cpu_LogicSbox4(Cpu_OpBitOr_1, &Lut_BitOr[0u])
Cpu_Opcode_End(BitOr)

//
// EOR rZ, rB, rA                  - Bitwise XOR
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x11 |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(BitEor)
	// Lookup via 4-bit x 4-bit logic EOR LUT
	Cpu_LogicSbox4(Cpu_OpBitEor_1, &Lut_BitEor[0u])
Cpu_Opcode_End(BitEor)

//
// ROR rZ, rB, #1                  - Rotate-Right by 1
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x12 |  rZ  | rB   | (0)  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(Ror)
	// Lookup via ROR table
	Dma_Sbox8(Cpu_OpRor_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Lut_RotateRight[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(Ror)


//
// ROL rZ, rB, #1                  - Rotate-Left by 1
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x13 |  rZ  | rB   | (0)  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(Rol)
	// Lookup via ROL table (note: could also be done as 8 times ROR)
	Dma_Sbox8(Cpu_OpRol_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Lut_RotateLeft[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(Rol)

//
// LO4 rZ, rB                      - Extract lower 4 bits
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x14 |  rZ  | rB   | (0)  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(Lo4)
	// Lookup via bitwise LO4 table
	Dma_Sbox8(Cpu_OpLo4_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Lut_Lo4[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(Lo4)

//
// HI4 rZ, rB                      - Extract upper 4 bits
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x15 |  rZ  | rB   | (0)  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(Hi4)
	// Lookup via bitwise HI4 table
	Dma_Sbox8(Cpu_OpHi4_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Lut_Hi4[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(Hi4)

//
// SHL4 rZ, rB                     - Shift left by 4 bits
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x16 |  rZ  | rB   | (0)  |
// +------+------+------+------+
//
Cpu_Opcode_Begin(Shl4)
	// Lookup via bitwise SHL4 table
	Dma_Sbox8(Cpu_OpShl4_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Lut_Mul16[0u],
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(Shl4)

//
// JAL rZ+1:rZ, #imm16             - Jump and Link
//
//  31  24     16      8      0
// +------+------+-------------+
// | 0x17 |  rZ  | imm16       |
// +------+------+-------------+
//
Cpu_Opcode_Begin(Jal)
	Dma_Declare_Descriptor(Cpu_OpJal_2)
	Dma_Declare_Descriptor(Cpu_OpJal_3)

	// Copy the lower half of next PC value to rZ, then link to JmpReg16
	// (Clipping is consistent with program counter increment)
	Dma_ByteCopy(Cpu_OpJal_1,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		(Dma_PtrToAddr(&gCpu.NextPC) + 0u),
		2u,
		&Cpu_OpJal_2
	)

	// WB.FOUR.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+2]:...:Regfile[rZ]
	Dma_PatchDstLo8(Cpu_OpJal_2,
		&Cpu_OpJal_3,
		&gCpu.CurrentOPC.Bytes[2u],
		&Cpu_OpJal_3
	)

	// WB.FOUR.2: Do copy from CurrentZ[15:0] to Regfile[rZ+2]:...:Regfile[rZ]
	Dma_ByteCopy(Cpu_OpJal_3,
		&gCpu.RegFile[0u],
		&gCpu.Operands.Z,
		2u,
		&Cpu_OpJmpImm16_1
	)
Cpu_Opcode_End(Jal)

//
// LIT32 rZ+3:rZ+2:rZ+1:rZ, (off16) - Load a 32-bit literal
//
//  31  24     16      8      0
// +------+------+-------------+
// | 0x17 |  rZ  | (off16)     |
// +------+------+-------------+
//
Cpu_Opcode_Begin(Lit32)
	Dma_Declare_Descriptor(Cpu_OpLit32_2)
	Dma_Declare_Descriptor(Cpu_OpLit32_3)
	Dma_Declare_Descriptor(Cpu_OpLit32_Commit)

	// Load the program base into the source address of the copy operation at step 4
	Dma_ByteCopy(Cpu_OpLit32_1,
		(Dma_PtrToAddr(&Cpu_OpLit32_Commit.src) + 0u),
		(Dma_PtrToAddr(&gCpu.ProgramBase) + 0u),
		4u,
		&Cpu_OpLit32_2
	)

	// Add lower 8-bit to the source address
	Cpu_Add8to16(Cpu_OpLit32_2,
		(Dma_PtrToAddr(&Cpu_OpLit32_Commit.src) + 0u),
		(Dma_PtrToAddr(&gCpu.ProgramBase) + 0u),
		&gCpu.CurrentOPC.Bytes[0u],
		&Cpu_OpLit32_3
	)

	// Add upper 8-bit to the source address
	Cpu_Add8to16(Cpu_OpLit32_3,
		(Dma_PtrToAddr(&Cpu_OpLit32_Commit.src) + 1u),
		(Dma_PtrToAddr(&Cpu_OpLit32_Commit.src) + 1u),
		&gCpu.CurrentOPC.Bytes[1u],
		&Cpu_OpLit32_Commit
	)

	// Ignore clipping for LIT32 offsets (this allows is to load literals that sit slightly outside of the
	// 64k code segment)
	Dma_ByteCopy(Cpu_OpLit32_Commit,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		4u,
		&Cpu_Writeback_FourRegs
	)
Cpu_Opcode_End(Lit32)

//
// LDB rZ, [rB+1:rB:rA+1:rA]        - Load byte indirect
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x19 |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(LoadByte)
	Dma_Declare_Descriptor(Cpu_OpLoadByte_2)
	Dma_Declare_Descriptor(Cpu_OpLoadByte_3)

	// Step 1: Patch in the lower 16 bits of the source address
	Dma_PatchSrcLo16(Cpu_OpLoadByte_1,
		(Dma_PtrToAddr(&Cpu_OpLoadByte_3.src) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_OpLoadByte_2
	)

	// Step 2: Patch in the upper 16 bits of the source address
	Dma_PatchSrcHi16(Cpu_OpLoadByte_2,
		(Dma_PtrToAddr(&Cpu_OpLoadByte_3.src) + 2u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Cpu_OpLoadByte_3
	)

	// Step 3: Perform the load operation (byte)
	Dma_ByteCopy(Cpu_OpLoadByte_3,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		1u,
		&Cpu_Writeback_OneReg
	)
Cpu_Opcode_End(LoadByte)

//
// LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load half-word indirect
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x1B |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(LoadHalf)
	Dma_Declare_Descriptor(Cpu_OpLoadHalf_2)
	Dma_Declare_Descriptor(Cpu_OpLoadHalf_3)

	// Step 1: Patch in the lower 16 bits of the source address
	Dma_PatchSrcLo16(Cpu_OpLoadHalf_1,
		(Dma_PtrToAddr(&Cpu_OpLoadHalf_3.src) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_OpLoadHalf_2
	)

	// Step 2: Patch in the upper 16 bits of the source address
	Dma_PatchSrcHi16(Cpu_OpLoadHalf_2,
		(Dma_PtrToAddr(&Cpu_OpLoadHalf_3.src) + 2u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Cpu_OpLoadHalf_3
	)

	// Step 3: Perform the load operation (half-word)
	//
	// FIXME: Use a 16-bit DMA access (instead of two 8-bit DMA accesses)
	Dma_ByteCopy(Cpu_OpLoadHalf_3,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		2u,
		&Cpu_Writeback_TwoRegs
	)
Cpu_Opcode_End(LoadHalf)

//
// LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load word indirect
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x1D |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(LoadWord)
	Dma_Declare_Descriptor(Cpu_OpLoadWord_2)
	Dma_Declare_Descriptor(Cpu_OpLoadWord_3)

	// Step 1: Patch in the lower 16 bits of the source address
	Dma_PatchSrcLo16(Cpu_OpLoadWord_1,
		(Dma_PtrToAddr(&Cpu_OpLoadWord_3.src) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_OpLoadWord_2
	)

	// Step 2: Patch in the upper 16 bits of the source address
	Dma_PatchSrcHi16(Cpu_OpLoadWord_2,
		(Dma_PtrToAddr(&Cpu_OpLoadWord_3.src) + 2u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Cpu_OpLoadWord_3
	)

	// Step 3: Perform the load operation (half-word)
	//
	// FIXME: Use a 32-bit DMA access (instead of four 8-bit DMA accesses)
	Dma_ByteCopy(Cpu_OpLoadWord_3,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		4u,
		&Cpu_Writeback_FourRegs
	)
Cpu_Opcode_End(LoadWord)

//
// STB rZ, [rB+1:rB:rA+1:rA]        - Store byte indirect
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x1A |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(StoreByte)
	Dma_Declare_Descriptor(Cpu_OpStoreByte_2)
	Dma_Declare_Descriptor(Cpu_OpStoreByte_3)

	// Step 1: Patch in the lower 16 bits of the destination address
	Dma_PatchSrcLo16(Cpu_OpStoreByte_1,
		(Dma_PtrToAddr(&Cpu_OpStoreByte_3.dst) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_OpStoreByte_2
	)

	// Step 2: Patch in the lower 16 bits of the destination address
	Dma_PatchSrcHi16(Cpu_OpStoreByte_2,
		(Dma_PtrToAddr(&Cpu_OpStoreByte_3.dst) + 2u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Cpu_OpStoreByte_3
	)

	// Step 3: Perform the store operation (byte)
	Dma_ByteCopy(Cpu_OpStoreByte_3,
	    0,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		1u,
		&Cpu_Writeback_PC
	)
Cpu_Opcode_End(StoreByte)

//
// STH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store half-word indirect
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x1C |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(StoreHalf)
	Dma_Declare_Descriptor(Cpu_OpStoreHalf_2)
	Dma_Declare_Descriptor(Cpu_OpStoreHalf_3)

	// Step 1: Patch in the lower 16 bits of the destination address
	Dma_PatchSrcLo16(Cpu_OpStoreHalf_1,
		(Dma_PtrToAddr(&Cpu_OpStoreHalf_3.dst) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_OpStoreByte_2
	)

	// Step 2: Patch in the lower 16 bits of the destination address
	Dma_PatchSrcHi16(Cpu_OpStoreHalf_2,
		(Dma_PtrToAddr(&Cpu_OpStoreHalf_3.dst) + 2u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Cpu_OpStoreByte_3
	)

	// Step 3: Perform the store operation (byte)
	//
	// FIXME: Use a 16-bit DMA access (instead of two 8-bit DMA accesses)
	Dma_ByteCopy(Cpu_OpStoreHalf_3,
	    DMA_INVALID_ADDR,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		2u,
		&Cpu_Writeback_PC
	)
Cpu_Opcode_End(StoreHalf)

//
// STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store word indirect
//
//  31  24     16      8      0
// +------+------+------+------+
// | 0x1E |  rZ  | rB   | rA   |
// +------+------+------+------+
//
Cpu_Opcode_Begin(StoreWord)
	Dma_Declare_Descriptor(Cpu_OpStoreWord_2)
	Dma_Declare_Descriptor(Cpu_OpStoreWord_3)

	// Step 1: Patch in the lower 16 bits of the destination address
	Dma_PatchSrcLo16(Cpu_OpStoreWord_1,
		(Dma_PtrToAddr(&Cpu_OpStoreWord_3.dst) + 0u),
		(Dma_PtrToAddr(&gCpu.Operands.A) + 0u),
		&Cpu_OpStoreByte_2
	)

	// Step 2: Patch in the lower 16 bits of the destination address
	Dma_PatchSrcHi16(Cpu_OpStoreWord_2,
		(Dma_PtrToAddr(&Cpu_OpStoreWord_3.dst) + 2u),
		(Dma_PtrToAddr(&gCpu.Operands.B) + 0u),
		&Cpu_OpStoreByte_3
	)

	// Step 3: Perform the store operation (byte)
	//
	// FIXME: Use a 32-bit DMA access (instead of four 8-bit DMA accesses)
	Dma_ByteCopy(Cpu_OpStoreWord_3,
	    DMA_INVALID_ADDR,
		(Dma_PtrToAddr(&gCpu.Operands.Z) + 0u),
		4u,
		&Cpu_Writeback_PC
	)
Cpu_Opcode_End(StoreWord)

//
// UND #imm24 - Undefined Instruction
//
//  31     24     16      8      0
// +---------+------+------+------+
// | 0x1F(*) | (0)  | (0)  | (0)  |
// +---------+------+------+------+
//
// (*) Canonical encoding of the undefined instruction
//
// The UND instruction (or any other undefined instruction encoding) writes the special
// value 0xDEADC0DE to the gCpu.NextPC descriptor and terminates further DMA processing
// (by linking to the NULL descriptor). The instruction itself (and its 24-bit immediate
// operand) are retained in the Cpu_CurrentOPC register and can be used for debugging
// purposes (from the host system).
//
// Idea: Mapping of ARM semihosting calls:
// -> Trap the UND instruction on the host CPU (DMA transfer done, gCpu.NextPC shows
//    the magic value 0xDEADC0DE).
//
// -> Map rZ to the ARM semicall number
// -> Use rB:rA as 16-bit offset (like LIT32) to locate the semicall parameter block
// -> Let BKPT #0xAB (on Cortex-M) do its thing
//
// Idea: Trivial (custom) semihosting (portable):
// -> Wrap the host CPU's "DMA" transfer in semihosting interpreter loop
// -> Host starts the DMA transfer
// -> DMA transfer finishes (as result of the UND)
// -> Host interprets gCpu.Operanfs.{A,B,Z} and handles semihosting call
// -> Host sets gCpu.NextPC (typ. to gCpu.PC) and restarts DMA from Cpu_Fetch_1 stage.
//
Cpu_Opcode_Begin(Undef)
	DMACU_PRIVATE const uint32_t Cpu_OpUndef_Lit_DEADC0DE = 0xDEADC0DEu;

	// Copy the 0xDEADC0DE value to Cpu_NextPC, then halt via LLI=0
	Dma_ByteCopy(Cpu_OpUndef_1,
		&gCpu.NextPC,
		&Cpu_OpUndef_Lit_DEADC0DE,
		4u,
		DMA_INVALID_ADDR
	)
Cpu_Opcode_End(Undef)
