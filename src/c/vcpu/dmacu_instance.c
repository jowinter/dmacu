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
#define DMACU_ARCH_DETAILS 1
#include "dmacu_instance.h"

//-------------------------------------------------------------------------------------------------
// DMA descriptor manipulation helpers
//

/// \brief Patches a field of a DMA descriptor
///
/// Patches field @p _field of the DMA descriptor at @p _desc with @p _size bytes
/// from @p _src. Then links to descriptor @p _lli
#define Dma_PatchField_Core(_qual,_self,_dst,_field,_off,_src,_size,_lli) \
	_qual Dma_ByteCopy(_self, \
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
#define Dma_PatchSrcLo8_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), src, 0u, (_src), 1u, (_lli))

#define Dma_FixedPatchSrcLo8(_self,_dst,_src,_lli) \
	Dma_PatchSrcLo8_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patch bits [15:8] of a DMA descriptor's source address.
///
/// Patches bits [15:8] of the source address of the DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcHi8_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), src, 1u, (_src), 1u, (_lli))

#define Dma_FixedPatchSrcHi8(_self,_dst,_src,_lli) \
	Dma_PatchSrcHi8_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patch bits [15:0] of a DMA descriptor's source address.
///
/// Patches bits [15:0] of the source address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcLo16_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), src, 0u, (_src), 2u, (_lli))

#define Dma_FixedPatchSrcLo16(_self,_dst,_src,_lli) \
	Dma_PatchSrcLo16_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patch bits [31:16] of a DMA descriptor's source address.
///
/// Patches bits [31:16] of the source address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrcHi16_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), src, 2u, (_src), 2u, (_lli))

#define Dma_FixedPatchSrcHi16(_self,_dst,_src,_lli) \
	Dma_PatchSrcHi16_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patches a DMA descriptor's source address.
///
/// Patches the whole destination address of the DMA descriptor at "dst" with the word
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchSrc_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), src, 0u, (_src), 4u, (_lli))

#define Dma_FixedPatchSrc(_self,_dst,_src,_lli) \
	Dma_PatchSrc_Core(DMACU_READONLY, _self, _dst, _src, _lli)

//-------------------------------------------------------------------------------------------------
// Descriptor destination address patch operations
//

/// \brief Patches bits[7:0] of a DMA descriptors destination address.
///
/// Patches bits [7:0] of the destination address of DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstLo8_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), dst, 0u, (_src), 1u, (_lli))

#define Dma_FixedPatchDstLo8(_self,_dst,_src,_lli) \
	Dma_PatchDstLo8_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patches bits[15:8] of a DMA descriptors destination address.
///
/// Patches bits [15:8] of the destination address of DMA descriptor at "dst" with the byte
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstHi8_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), dst, 1u, (_src), 1u, (_lli))

#define Dma_FixedPatchDstHi8(_self,_dst,_src,_lli) \
	Dma_PatchDstHi8_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patches bits[15:0] of a DMA descriptor's destination address.
///
/// Patches bits [15:0] of the destinatoin address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstLo16_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), dst, 0u, (_src), 2u, (_lli))

#define Dma_FixedPatchDstLo16(_self,_dst,_src,_lli) \
	Dma_PatchDstLo16_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patches bits[31:16] of a DMA descriptor's destination address.
///
/// Patches bits [31:16] of the destinatoin address of the DMA descriptor at "dst" with the
/// half-word found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDstHi16_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), dst, 2u, (_src), 2u, (_lli))

#define Dma_FixedPatchDstHi16(_self,_dst,_src,_lli) \
	Dma_PatchDstHi16_Core(DMACU_READONLY, _self, _dst, _src, _lli)

/// \brief Patches the destination address of a DMA descriptor.
///
/// Patches the entire destination address of the DMA descriptor at "dst" with the word
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchDst_Core(_qual,_self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), dst, 0u, (_src), 4u, (_lli))

#define Dma_FixedPatchDst(_self,_dst,_src,_lli) \
	Dma_PatchDst_Core(DMACU_READONLY, _self, _dst, _src, _lli)

//-------------------------------------------------------------------------------------------------
// Descriptor destination address patch operations
//

/// \brief Patches the link address a DMA descriptor.
///
/// Patches the entire link address (lli) of the DMA descriptor at "dst" with the word
/// found at "src". Then links to the next descriptor at "lli".
///
#define Dma_PatchLink_Core(_qual, _self,_dst,_src,_lli) \
	Dma_PatchField_Core(_qual, _self, (_dst), lli, 0u, (_src), 4u, (_lli))

#define Dma_FixedPatchLink(_self,_dst,_src,_lli) \
	Dma_PatchLink_Core(DMACU_READONLY, _self, _dst, _src, _lli)

//-------------------------------------------------------------------------------------------------
// Lookup-Tables (common helpers and support macros)
//

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
#define Dma_Sbox8_Core(_qual,_self,_dst,_src,_sbox,_lli) \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, Sbox8_Lookup) \
	/* Step 1: Load the source byte from src and substitute it into the sbox's source address */ \
	Dma_PatchSrcLo8_Core(_qual, _self, \
		Dma_Local_Reference(_self, Sbox8_Lookup), \
		(_src), \
		Dma_Local_Reference(_self, Sbox8_Lookup)  \
	) \
	/* Step 2: Read the byte from the (patched) sbox location and store to dst */ \
	DMACU_READWRITE Dma_ByteCopy(Dma_Local_Name(_self, Sbox8_Lookup), (_dst), (_sbox), 1u, (_lli))

// Fixed (non-patchable) version of Dma_Sbox8
#define Dma_FixedSbox8(_self,_dst,_src,_sbox,_lli) \
	Dma_Sbox8_Core(DMACU_READONLY, _self, _dst, _src, _sbox, _lli)

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
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, Sbox8_Lookup) \
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
// The _qual parameter specifies the extra qualifiers (const, non-const).
//

#define Dma_TableSwitch64_Core(_qual,_self,_dst,_src,_table,_lli) \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, TableSwitch_DoLookup) \
	/* Step 1: Patch the byte-copy operation that performs the fetch from the table lookup */ \
	/*         We actually perform an SBOX lookup into the multiply-by-4 LUT for the patch */ \
	Dma_Sbox8_Core(_qual, _self, \
		&Dma_Local_Reference(_self, TableSwitch_DoLookup)->src, \
		(_src), \
		&Lut_Mul4[0u], \
		Dma_Local_Reference(_self, TableSwitch_DoLookup) \
	) \
	/* Step 2: Read a 4-byte value from the table. */ \
	Dma_ByteCopy(Dma_Local_Name(_self, TableSwitch_DoLookup), (_dst), (_table), 4u, (_lli))

// Non-patchable table switch
#define Dma_FixedTableSwitch64(_self,_dst,_src,_table,_lli) \
	Dma_TableSwitch64_Core(DMACU_READONLY, _self, _dst, _src, _table, _lli)

// Temporary LUTs
DMACU_ALIGNED(256u) DMACU_PRIVATE uint8_t Dma_Global_Name(Lut_Temporary)[256u];
DMACU_PRIVATE uint8_t Dma_Global_Name(Lut_Scratchpad)[16u];

//-------------------------------------------------------------------------------------------------
// Lookup tables for Unary Functions (uint8_t -> uint8_t)

// See dmacu_shared.c for the (shared) implementation
extern DMACU_READONLY uint8_t Lut_BitNot[256u];
extern DMACU_READONLY uint8_t Lut_Neg[256u];
extern DMACU_READONLY uint8_t Lut_RotateRight[256u];
extern DMACU_READONLY uint8_t Lut_RotateLeft[256u];
extern DMACU_READONLY uint8_t Lut_Lo4[256u];
extern DMACU_READONLY uint8_t Lut_Hi4[256u];
extern DMACU_READONLY uint8_t Lut_Mul4[256u];
extern DMACU_READONLY uint8_t Lut_Mul16[256u];

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
//   This operation uses Dma_Global_Name(Lut_Scratchpad) for processing.
//   This macro defines local labels "1" and "2" to enable seamless interaction with Dma_LogicSbox4_Indirect
//
#define Dma_LogicSbox4_Core(_qual,_self,_dst,_src1,_src2,_table,_lli) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo4_B) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo4_Mul16_B) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo_Combine) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Lo_Lookup) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi4_A) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi4_B) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi4_Mul16_B) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi_Combine) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi_Lookup) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Hi_Shift) \
	_qual Dma_Declare_Local_Descriptor(_self, LogicSbox4_Result) \
	/* Step 1: Extract lower 4 bits of operand A into t0 */ \
	Dma_Sbox8_Core(_qual, _self, \
		&Dma_Global_Name(Lut_Scratchpad)[0u], \
		(_src1), \
		&Lut_Lo4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Lo4_B) \
	) \
	/* Step 2: Extract lower 4 bits of operand B into t1 */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Lo4_B), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		(_src2), \
		&Lut_Lo4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Lo4_Mul16_B) \
	) \
	/* Step 3: Multiply t1 by 16 */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Lo4_Mul16_B), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Lut_Mul16[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Lo_Combine) \
	) \
	/* Step 4: Add t0 and t1 to get the lookup table index into the 4-bit x 4-bit LUT */ \
	Dma_Add8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Lo_Combine), \
		 &Dma_Global_Name(Lut_Scratchpad)[2u], \
		 &Dma_Global_Name(Lut_Scratchpad)[1u], \
		 &Dma_Global_Name(Lut_Scratchpad)[0u], \
		 Dma_Local_Reference(_self, LogicSbox4_Lo_Lookup) \
	) \
	/* Step 5: Lookup on lower 4 bits */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Lo_Lookup), \
		 &Dma_Global_Name(Lut_Scratchpad)[2u], \
		 &Dma_Global_Name(Lut_Scratchpad)[2u], \
		 (_table), \
		 Dma_Local_Reference(_self, LogicSbox4_Hi4_A) \
	) \
	/* Step 6: Extract lower 4 bits of operand A into t0 */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Hi4_A), \
		&Dma_Global_Name(Lut_Scratchpad)[0u], \
		(_src1), \
		&Lut_Hi4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi4_B) \
	) \
	/* Step 7: Extract lower 4 bits of operand B into t1 */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Hi4_B), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		(_src2), \
		&Lut_Hi4[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi4_Mul16_B) \
	) \
	/* Step 8: Multiply t1 by 16 */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Hi4_Mul16_B), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Lut_Mul16[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi_Combine) \
	) \
	/* Step 9: Add t0 and t1 to get the lookup table index into the 4-bit x 4-bit LUT */ \
	Dma_Add8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Hi_Combine), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Hi_Lookup) \
	) \
	/* Step 10: Lookup on upper 4 bits */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Hi_Lookup), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		(_table), \
		Dma_Local_Reference(_self, LogicSbox4_Hi_Shift) \
	) \
	/* Step 11: Shift lookup result for higer bits by 4 bits */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Hi_Shift), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Lut_Mul16[0u], \
		Dma_Local_Reference(_self, LogicSbox4_Result) \
	) \
	/* Step 12: Assemble the result, then link to writeback */ \
	Dma_Add8_Core(_qual, Dma_Local_Name(_self, LogicSbox4_Result), \
		(_dst), \
		&Dma_Global_Name(Lut_Scratchpad)[1u], \
		&Dma_Global_Name(Lut_Scratchpad)[2u], \
		(_lli) \
	)

#define Dma_FixedLogicSbox4(_self,_dst,_src1,_src2,_table,_lli) \
	Dma_LogicSbox4_Core(DMACU_READONLY, _dst, _src1, _src2, _table, _lli)

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
//   This operation uses Dma_Global_Name(Lut_Scratchpad) for processing
//   This macro defines local labels "1" and "2" to enable seamless interaction with Dma_LogicSbox4
//
#define Dma_LogicSbox4_Indirect(_dst,_src1,_src2,_pointer_to_table,_lli) \
	/* Step 1: Patch the first source lookup location */ \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, LogicSbox4_Indirect_PatchHi) \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Lo_Lookup) \
	Dma_Sbox8_PatchTableImm(_self, \
		Dma_Local_Reference(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Lo_Lookup), \
		(_pointer_to_table), \
		Dma_Local_Reference(_self,LogicSbox4_Indirect_PatchHi) \
	) \
	/* Step 2: Patch the second source lookup location and link */ \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, LogicSbox4_Indirect_Exec) \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(Dma_Local_Name(_self,LogicSbox4_Indirect_Exec),LogicSbox4_Hi_Lookup) \
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

// See dmacu_shared.c for the (shared) implementation
extern DMACU_READONLY uint8_t Lut_BitAnd[256u];
extern DMACU_READONLY uint8_t Lut_BitOr[256u];
extern DMACU_READONLY uint8_t Lut_BitEor[256u];
extern DMACU_READONLY uint8_t Lut_Identity[512u];
extern DMACU_READONLY uint8_t Lut_Carry[512u];

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
//   This operation uses Dma_Global_Name(Lut_Temporary) for processing
//
#define Dma_Add8_Core(_qual, _self,_dst,_src1,_src2,_lli) \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, Add8_LoadTempLut) \
	_qual           Dma_Declare_Local_Descriptor(_self, Add8_LookupSum) \
	/* Step 1: Load source byte from src1 and patch it into the source address for loading the temporary LUT */ \
	Dma_PatchSrcLo8_Core(_qual, _self, \
		Dma_Local_Reference(_self, Add8_LoadTempLut), \
		(_src1), \
		Dma_Local_Reference(_self, Add8_LoadTempLut) \
	) \
	/* Step 2: Load the temporary LUT with with the identity LUT (offset by src1 memory operand) */ \
	Dma_ByteCopy(Dma_Local_Name(_self, Add8_LoadTempLut), \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		&Lut_Identity[0u], \
		0x100u, \
		Dma_Local_Reference(_self, Add8_LookupSum) \
	) \
	/* Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, Add8_LookupSum), (_dst), (_src2), &Dma_Global_Name(Lut_Temporary)[0u], (_lli))

#define Dma_FixedAdd8(_self,_dst,_src1,_src2,_lli) \
	Dma_Add8_Core(DMACU_READONLY, _self,_dst,_src1,_src2,_lli)

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
//   This operation uses Dma_Global_Name(Lut_Temporary) for processing
//
#define Dma_Add8Imm_Core(_qual,_self,_dst,_src1,_imm8,_lli) \
	/* Step 1: Load the temporary LUT with with the identity LUT offset by imm8 operand */ \
	_qual Dma_Declare_Local_Descriptor(_self, Add8Imm_LookupSum) \
	Dma_ByteCopy_Core(_qual, _self, \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		&Lut_Identity[(_imm8) & 0xFFu], \
		0x100u, \
		Dma_Local_Reference(_self, Add8Imm_LookupSum) \
	) \
	/* Step 2: Lookup the sum using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, Add8Imm_LookupSum), \
		(_dst), \
		(_src1), \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		(_lli) \
	)

#define Dma_FixedAdd8Imm(_self,_dst,_src1,_imm8,_lli) \
	 Dma_Add8Imm_Core(DMACU_READONLY, _self,_dst,_src1,_imm8,_lli)

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
//   This operation uses Dma_Global_Name(Lut_Temporary) for processing
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
//   This operation uses Dma_Global_Name(Lut_Temporary) for processing
//
#define Dma_CarryFromAdd8_Core(_qual,_self,_dst,_src1,_src2,_lli) \
	DMACU_READWRITE Dma_Declare_Local_Descriptor(_self, CarryFromAdd8_LoadTempLut) \
	_qual           Dma_Declare_Local_Descriptor(_self, CarryFromAdd8_LookupCarry) \
	/* Step 1: Patch the source address of the of the carry LUT copy operation */ \
	Dma_PatchSrcLo8_Core(_qual, _self, \
		Dma_Local_Reference(_self, CarryFromAdd8_LoadTempLut), \
		(_src1), \
		Dma_Local_Reference(_self, CarryFromAdd8_LoadTempLut) \
	) \
	/* Step 2: Load the temporary LUT with with the carry LUT offset by imm8 operand */ \
	Dma_ByteCopy(Dma_Local_Name(_self, CarryFromAdd8_LoadTempLut), \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		&Lut_Carry[0u], \
		0x100u, \
		Dma_Local_Reference(_self, CarryFromAdd8_LookupCarry) \
	) \
	/* Step 3: Lookup the carry using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, CarryFromAdd8_LookupCarry), \
		(_dst), \
		(_src2), \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		(_lli) \
	)

#define Dma_FixedCarryFromAdd8(_self,_dst,_src1,_src2,_lli) \
	Dma_CarryFromAdd8_Core(DMACU_READONLY,_self,_dst,_src1,_src2,_lli) \

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
//   This operation uses Dma_Global_Name(Lut_Temporary) for processing
//
#define Dma_CarryFromAdd8Imm_Core(_qual,_self,_dst,_src1,_imm8,_lli) \
	_qual Dma_Declare_Local_Descriptor(_self, CarryFromAdd8Imm_LookupCarry) \
	/* Step 1: Load the temporary LUT with with the carry LUT offset by imm8 operand */ \
	Dma_ByteCopy_Core(_qual, _self, \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		&Lut_Carry[(_imm8) & 0xFFu], \
		0x100u, \
		Dma_Local_Reference(_self,CarryFromAdd8Imm_LookupCarry) \
	) \
	/* Step 2: Lookup the carry using the temporary LUT (indexed by src2 memory operand) */ \
	Dma_Sbox8_Core(_qual, Dma_Local_Name(_self, CarryFromAdd8Imm_LookupCarry), \
		(_dst), \
		(_src1), \
		&Dma_Global_Name(Lut_Temporary)[0u], \
		(_lli) \
	)

#define Dma_FixedCarryFromAdd8Imm(_self,_dst,_src1,_imm8,_lli) \
	Dma_CarryFromAdd8Imm_Core(DMACU_READONLY,_self,_dst,_src1,_imm8,_lli)

//-----------------------------------------------------------------------------------------
//
// Arithmetic/Logic helpers for the CPU
//
//-----------------------------------------------------------------------------------------

//
// Add 8-bit immediate imm8 to 16-bit value (little endian) at memory operand src1 and store the result in dst1
//
// This operation uses Dma_Global_Name(Lut_Temporary) and Cpu_Scratchpad for processing
//
#define Cpu_Add16Imm_Core(_qual,_self,_dst,_src1,_imm8,_lli) \
	_qual Dma_Declare_Local_Descriptor(_self, Add16Imm_AddLo8) \
	_qual Dma_Declare_Local_Descriptor(_self, Add16Imm_AddHi8) \
	/* Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the */ \
	/*   immediate of the upper part of the addition */ \
	Dma_CarryFromAdd8Imm_Core(_qual, _self, \
		&Dma_Global_Name(gCpu).Scratchpad[0u], \
		(_src1), \
		(_imm8), \
		Dma_Local_Reference(_self, Add16Imm_AddLo8) \
	) \
	/* Step 2: Perform the 8-bit addition in the lower byte */ \
	Dma_Add8Imm_Core(_qual, Dma_Local_Name(_self, Add16Imm_AddLo8), \
		(Dma_PtrToAddr(_dst)  + 0u), \
		(Dma_PtrToAddr(_src1) + 0u), \
		(_imm8), \
		Dma_Local_Reference(_self, Add16Imm_AddHi8) \
	) \
	/* Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value) */ \
	Dma_Add8_Core(_qual, Dma_Local_Name(_self, Add16Imm_AddHi8), \
		(Dma_PtrToAddr(_dst)  + 1u), \
		(Dma_PtrToAddr(_src1) + 1u), \
		&Dma_Global_Name(gCpu).Scratchpad[0u], \
		(_lli) \
	)

#define Cpu_FixedAdd16Imm(_self,_dst,_src1,_imm8,_lli) \
	Cpu_Add16Imm_Core(DMACU_READONLY,_self,_dst,_src1,_imm8,_lli)

//
// Adds an 8-bit value (in src2) to 16-bit value (little endian) at memory operand src1 and store the result in dst1
//
// This operation uses Dma_Global_Name(Lut_Temporary) and Cpu_Scratchpad for processing
//
#define Cpu_Add8to16_Core(_qual,_self,_dst,_src1,_src2,_lli) \
	_qual Dma_Declare_Local_Descriptor(_self, Add8to16_AddLo8) \
	_qual Dma_Declare_Local_Descriptor(_self, Add8to16_AddHi8) \
	/* Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the */ \
	/* immediate of the upper part of the addition */ \
	Dma_CarryFromAdd8_Core(_qual, _self, \
		&Dma_Global_Name(gCpu).Scratchpad[0u], \
		(_src1), \
		(_src2), \
		Dma_Local_Reference(_self, Add8to16_AddLo8) \
	) \
	/* Step 2: Perform the 8-bit addition in the lower byte */ \
	Dma_Add8_Core(_qual, Dma_Local_Name(_self, Add8to16_AddLo8), \
		(Dma_PtrToAddr(_dst)  + 0u), \
		(Dma_PtrToAddr(_src1) + 0u), \
		(Dma_PtrToAddr(_src2) + 0u), \
		Dma_Local_Reference(_self, Add8to16_AddHi8) \
	) \
	/* Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value) */ \
	Dma_Add8_Core(_qual, Dma_Local_Name(_self, Add8to16_AddHi8), \
		(Dma_PtrToAddr(_dst)  + 1u), \
		(Dma_PtrToAddr(_src1) + 1u), \
		&Dma_Global_Name(gCpu).Scratchpad[0u], \
		(_lli) \
	)

#define Cpu_FixedAdd8to16(_self,_dst,_src1,_src2,_lli) \
	Cpu_Add8to16_Core(DMACU_READONLY,_self,_dst,_src1,_src2,_lli)

//
// 8-bit arbitrary logic function (AND/OR/XOR)
//
// Storing a full LUT for 8-bit inputs src1 and src2 would require 64k entries. We use a divide and conquer
// approach to implement 8-bit logic functions on top of 4-bit x 4-bit LUT:
//
// FIXME: Back-port the shared Cpu_Execute_Logic chain from the assembler implementation (this saves
// significantly on space, as we only need _one_ instance of Dma_LogicSbox4 from a constant sbox).
//
#define Cpu_LogicSbox4_Core(_qual,_self,_table) \
	/* In-place implementation  */ \
	Dma_LogicSbox4_Core(_qual,_self, \
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u), \
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u), \
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u), \
		(_table), \
		&Dma_Global_Name(Cpu_Writeback_OneReg) \
	)

#define Cpu_FixedLogicSbox4(_self,_table) \
	Cpu_LogicSbox4_Core(DMACU_READONLY,_self,_table)

//-----------------------------------------------------------------------------------------
//
// Forward declarations (instructions)
//
//-----------------------------------------------------------------------------------------

DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpNop_1       )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpMovImm_1    )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpMov2Imm_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpMov2Reg_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpAddImm8_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpAcyImm8_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpAddReg_1    )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpAcyReg_1    )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpImm16_1  )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpReg16_1  )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBrNeReg_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBrEqReg_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBrNeImm_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBrEqImm_1   )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBitNot_1    )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBitAnd_1    )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBitOr_1     )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpBitEor_1    )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpRor_1       )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpRol_1       )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpLo4_1       )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpHi4_1       )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpShl4_1      )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJal_1       )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpLit32_1     )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpLoadByte_1  )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpStoreByte_1 )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpLoadHalf_1  )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpStoreHalf_1 )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpLoadWord_1  )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpStoreWord_1 )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpUndef_1     )
DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpDmaCpy_1    )

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
DMACU_PRIVATE DMACU_READONLY Dma_UIntPtr_t Dma_Global_Name(Lut_InstructionTable)[64u] =
{
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpNop_1      )), // 0x00 - NOP                                       (No-operation)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpMovImm_1   )), // 0x01 - MOV rZ, #imm8                             (Move from 8-bit immediate to register pair)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpMov2Imm_1  )), // 0x02 - MOV rZ+1:rZ, #imm16                       (Move from 16-bit immediate to register pair)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpMov2Reg_1  )), // 0x03 - MOV rZ+1:rZ, rB:rA                        (Move from register pair to register pair)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpAddImm8_1  )), // 0x04 - ADD rZ, rB, #imm8                         (Add 8-bit immediate)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpAcyImm8_1  )), // 0x05 - ACY rZ, rB, #imm8                         (Generate carry from add with 8-bit immediate)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpAddReg_1   )), // 0x06 - ADD rZ, rB, rA                            (Add 8-bit registers)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpAcyReg_1   )), // 0x07 - ACY rZ, rB, rA                            (Generate carry from add with 8-bit registers)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpJmpImm16_1 )), // 0x08 - JMP #imm16                                (Jump absolute)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpJmpReg16_1 )), // 0x09 - JMP rB:rA                                 (Jump register indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBrNeReg_1  )), // 0x0A - BNE (+off8) rZ, rB                        (Branch if not equal)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBrEqReg_1  )), // 0x0B - BEQ (+off8) rZ, rB                        (Branch if equal)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBrNeImm_1  )), // 0x0C - BNE (+off8) rZ, #imm8                     (Branch if not equal immediate)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBrEqImm_1  )), // 0x0D - BEQ (+off8) rZ, #imm8                     (Branch if equal immediate)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBitNot_1   )), // 0x0E - NOT rZ, rB                                (Bitwise NOT)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBitAnd_1   )), // 0x0F - AND rZ, rB, rA                            (Bitwise AND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBitOr_1    )), // 0x10 - OR  rZ, rB, rA                            (Bitwise OR)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpBitEor_1   )), // 0x11 - EOR rZ, rB, rA                            (Bitwise Exclusive-OR)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpRor_1      )), // 0x12 - ROR rZ, zB, #1                            (Rotate-Right by 1)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpRol_1      )), // 0x13 - ROL rZ, zB, #1                            (Rotate-Left by 1)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpLo4_1      )), // 0x14 - LO4 rZ, rB                                (Extract lower 4 bits)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpHi4_1      )), // 0x15 - HI4 rZ, rB                                (Insert upper 4 bits)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpShl4_1     )), // 0x16 - SHL rZ, rB, #4                            (Shift left by 4 / multiply by 16)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpJal_1      )), // 0x17 - JAL rZ+1:rZ, #imm16                       (Jump and Link)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpLit32_1    )), // 0x18 - LIT32 (+off16) rZ+3:rZ+2:rZ+1:rZ          (Load 32-bit literal from a PC relative offset)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpLoadByte_1 )), // 0x19 - LDB rZ, [rB+1:rB:rA+1:rA]                 (Load byte indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpStoreByte_1)), // 0x1A - STB rZ, [rB+1:rB:rA+1:rA]                 (Store byte indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpLoadHalf_1 )), // 0x1B - LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Load half-word indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpStoreHalf_1)), // 0x1C - STH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Store half-word indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpLoadWord_1 )), // 0x1D - LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Load word indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpStoreWord_1)), // 0x1E - STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Store word indirect)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x1F - UND #imm24

	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpDmaCpy_1   )), // 0x20 - DMACPY rZ+3:rZ+2:rZ+1:rZ, rB+3:rB+2:rB+1:rB, rA+3:rA+2:rA+1:rA  (PL080 DMA Copy)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x21 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x22 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x23 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x24 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x25 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x26 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x27 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x28 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x29 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x2A - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x2B - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x2C - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x2D - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x2E - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x2F - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x30 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x31 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x32 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x33 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x34 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x35 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x36 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x37 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x38 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x39 - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x3A - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x3B - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x3C - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x3D - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x3E - (reserved; mapped to UND)
	Dma_PtrToAddr(Dma_Global_Reference(Cpu_OpUndef_1    )), // 0x3F - (reserved; mapped to UND)
};

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Execution State
//
//-----------------------------------------------------------------------------------------

// Global instance of the CPU execution state
DMACU_ALIGNED(256)
DMACU_PRIVATE Dmacu_Cpu_t Dma_Global_Name(gCpu);

//-----------------------------------------------------------------------------------------
extern Dmacu_Cpu_t* Dma_Global_Name(GetCpu)(void)
{
	return &Dma_Global_Name(gCpu);
}

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Fetch/Decode/Execute/Writeback Stages
//
//-----------------------------------------------------------------------------------------

DMACU_READONLY Dma_Declare_Descriptor(Cpu_Reset_1)
DMACU_READONLY Dma_Declare_Descriptor(Cpu_Fetch_1)
DMACU_READONLY Dma_Declare_Descriptor(Cpu_Decode_1)

DMACU_READONLY Dma_Declare_Descriptor(Cpu_Writeback_FourRegs)
DMACU_READONLY Dma_Declare_Descriptor(Cpu_Writeback_TwoRegs)
DMACU_READONLY Dma_Declare_Descriptor(Cpu_Writeback_OneReg)
DMACU_READONLY Dma_Declare_Descriptor(Cpu_Writeback_PC)

#define Cpu_Stage_Begin(name)
#define Cpu_Stage_End(name)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Reset
//
//-----------------------------------------------------------------------------------------
Cpu_Stage_Begin(Cpu_Fetch)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Reset_2)

	// RST.1: Capture the program base address (=initial PC)
	Dma_FixedWordCopy(Cpu_Reset_1, &Dma_Global_Name(gCpu).ProgramBase, &Dma_Global_Name(gCpu).PC, 1u, &Dma_Global_Name(Cpu_Reset_2))

	// RST.2: Clear registers r0-r223 (r224-r255 are provided by the environment)
	Dma_FixedByteFill(Cpu_Reset_2, &Dma_Global_Name(gCpu).RegFile[0], Dmacu_PtrToByteLiteral(0x00u), sizeof(Dma_Global_Name(gCpu).RegFile) - 32u, &Dma_Global_Name(Cpu_Fetch_1))
Cpu_Stage_End(Cpu_Fetch)

//-----------------------------------------------------------------------------------------
const Dma_Descriptor_t* Dma_Global_Name(CpuBootDescriptor)(void)
{
	// Get the DMA descriptor for a CPU boot (reset)
	return &Dma_Global_Name(Cpu_Reset_1);
}

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Fetch Stage
//
//-----------------------------------------------------------------------------------------
Cpu_Stage_Begin(Cpu_Fetch)
	Dma_Declare_Descriptor(Cpu_Fetch_2)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Fetch_3)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Fetch_4)

	// FE.1: Setup source address for instruction fetch
	Dma_FixedPatchSrc(Cpu_Fetch_1, &Dma_Global_Name(Cpu_Fetch_2), &Dma_Global_Name(gCpu).PC, &Dma_Global_Name(Cpu_Fetch_2))

	// FE.2: Fetch current instruction into opcode buffer (we assume that the PC is always word-aligned)
	Dma_WordCopy(Cpu_Fetch_2, &Dma_Global_Name(gCpu).CurrentOPC, DMA_INVALID_ADDR, 1u, &Dma_Global_Name(Cpu_Fetch_3))

	// FE.3: Generate lower 16 bit of next program counter
	Cpu_FixedAdd16Imm(Cpu_Fetch_3, &Dma_Global_Name(gCpu).NextPC, &Dma_Global_Name(gCpu).PC, 4u, &Dma_Global_Name(Cpu_Fetch_4))

	// FE.4: Copy upper 16 bit of program counter then link to decode stage
	Dma_FixedHalfWordCopy(Cpu_Fetch_4, Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC) + 2u, Dma_PtrToAddr(&Dma_Global_Name(gCpu).PC) + 2u, 1u, &Dma_Global_Name(Cpu_Decode_1))
Cpu_Stage_End(Cpu_Fetch)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Decode Stage
//
//-----------------------------------------------------------------------------------------
Cpu_Stage_Begin(Cpu_Decode)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Decode_2)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Decode_3)
	Dma_Declare_Descriptor(Cpu_Decode_4)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Decode_5)
	Dma_Declare_Descriptor(Cpu_Decode_6)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_Decode_7)
	Dma_Declare_Descriptor(Cpu_Decode_8)

	// DE.1: Generate the LLI address to the opcode (via tableswitch on opcode)
	//  Major opcode is in CurrentOPC.Bytes[31:24]
	//
	Dma_FixedTableSwitch64(Cpu_Decode_1, &Dma_Global_Name(Cpu_Decode_8).lli, &Dma_Global_Name(gCpu).CurrentOPC.Bytes[3u], &Dma_Global_Name(Lut_InstructionTable)[0u], &Dma_Global_Name(Cpu_Decode_2))

	// DE.2: Clear the current A. B and Z operand values
	Dma_FixedByteFill(Cpu_Decode_2, &Dma_Global_Name(gCpu).Operands, Dmacu_PtrToByteLiteral(0x00), sizeof(Dma_Global_Name(gCpu).Operands), &Dma_Global_Name(Cpu_Decode_3))

	// DE.3: Prepare loading the A operand from Regfile[CurrentOPC.Bytes[7:0]] (rA)
	Dma_FixedPatchSrcLo8(Cpu_Decode_3, &Dma_Global_Name(Cpu_Decode_4), &Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u], &Dma_Global_Name(Cpu_Decode_4))

	// DE.4: Load the A operand from Regfile[CurrentOPC.Bytes[7:0]] (rA)
	//
	// NOTE: We always load rA+1:rA
	Dma_ByteCopy(Cpu_Decode_4, &Dma_Global_Name(gCpu).Operands.A, &Dma_Global_Name(gCpu).RegFile[0], 4u, &Dma_Global_Name(Cpu_Decode_5))

	// DE.5: Prepare loading the B operand from Regfile[CurrentOPC.Bytes[15:8]] (rB)
	Dma_FixedPatchSrcLo8(Cpu_Decode_5, &Dma_Global_Name(Cpu_Decode_6), &Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u], &Dma_Global_Name(Cpu_Decode_6))

	// DE.6: Load the B operand from Regfile[CurrentOPC.Bytes[15:8]] (rB)
	//
	// NOTE: We always load rB+1:rB
	Dma_ByteCopy(Cpu_Decode_6, &Dma_Global_Name(gCpu).Operands.B, &Dma_Global_Name(gCpu).RegFile[0u], 4u, &Dma_Global_Name(Cpu_Decode_7))

	// DE.7: Prepare loading the Z operand from Regfile[CurrentOPC.Bytes[23:16]] (rZ)
	Dma_FixedPatchSrcLo8(Cpu_Decode_7, &Dma_Global_Name(Cpu_Decode_8), &Dma_Global_Name(gCpu).CurrentOPC.Bytes[2u], &Dma_Global_Name(Cpu_Decode_8))

	// DE.8: Load the Z operand from Regfile[CurrentOPC.Bytes[23:16]] (rB)
	//   Then dispatch to the execute stage (LLI patched by .LCpu_Decode.1)
	//
	// NOTE: We always load rZ+3:rZ+2:rZ+1:rZ+0
	Dma_ByteCopy(Cpu_Decode_8, &Dma_Global_Name(gCpu).Operands.Z, &Dma_Global_Name(gCpu).RegFile[0u], 4u, DMA_INVALID_ADDR)
Cpu_Stage_End(Cpu_Decode)

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Writeback Stage
//
// - TODO: We should be able to merge the rZ decode and regfile writeback part if we introduce
//   a Dma_PatchSize8 to patch the transfer size (and patch the "commit" descriptor)
//
//-----------------------------------------------------------------------------------------

Cpu_Stage_Begin(Cpu_Writeback)
	Dma_Declare_Descriptor(Cpu_Writeback_FourRegs_Commit)
	Dma_Declare_Descriptor(Cpu_Writeback_TwoRegs_Commit)
	Dma_Declare_Descriptor(Cpu_Writeback_OneReg_Commit)

	// WB.FOUR.1: Setup copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
	Dma_FixedPatchDstLo8(Cpu_Writeback_FourRegs, &Dma_Global_Name(Cpu_Writeback_FourRegs_Commit), &Dma_Global_Name(gCpu).CurrentOPC.Bytes[2u], &Dma_Global_Name(Cpu_Writeback_FourRegs_Commit))

	// WB.FOUR.2: Do copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
	Dma_ByteCopy(Cpu_Writeback_FourRegs_Commit, &Dma_Global_Name(gCpu).RegFile[0u], &Dma_Global_Name(gCpu).Operands.Z, 4u, &Dma_Global_Name(Cpu_Writeback_PC))

	// WB.TWO.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
	Dma_FixedPatchDstLo8(Cpu_Writeback_TwoRegs, &Dma_Global_Name(Cpu_Writeback_TwoRegs_Commit), &Dma_Global_Name(gCpu).CurrentOPC.Bytes[2u], &Dma_Global_Name(Cpu_Writeback_TwoRegs_Commit))

	// WB.TWO.2: Do copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
	Dma_ByteCopy(Cpu_Writeback_TwoRegs_Commit, &Dma_Global_Name(gCpu).RegFile[0u], &Dma_Global_Name(gCpu).Operands.Z, 2u, &Dma_Global_Name(Cpu_Writeback_PC))

	// WB.ONE.1: Setup copy from CurrentZ[7:0] to Regfile[rZ]
	Dma_FixedPatchDstLo8(Cpu_Writeback_OneReg, &Dma_Global_Name(Cpu_Writeback_OneReg_Commit), &Dma_Global_Name(gCpu).CurrentOPC.Bytes[2u], &Dma_Global_Name(Cpu_Writeback_OneReg_Commit))

	// WB.ONE.2: Do copy from CurrentZ[7:0] to Regfile[rZ]
	Dma_ByteCopy(Cpu_Writeback_OneReg_Commit, &Dma_Global_Name(gCpu).RegFile[0], &Dma_Global_Name(gCpu).Operands.Z, 1u, &Dma_Global_Name(Cpu_Writeback_PC))

	// WB.PC: Copy NextPC to PC, link to fetch stage
	Dma_FixedByteCopy(Cpu_Writeback_PC, &Dma_Global_Name(gCpu).PC, &Dma_Global_Name(gCpu).NextPC, 4u, &Dma_Global_Name(Cpu_Fetch_1))
Cpu_Stage_End(Cpu_Writeback)
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
	Dma_FixedByteCopy(Cpu_OpNop_1, &Dma_Global_Name(gCpu).Scratchpad[0u], &Dma_Global_Name(gCpu).Scratchpad[0u], 1u, &Dma_Global_Name(Cpu_Writeback_PC))
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
	Dma_FixedByteCopy(Cpu_OpMovImm_1, &Dma_Global_Name(gCpu).Operands.Z, &Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u], 1u, &Dma_Global_Name(Cpu_Writeback_OneReg))
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
	Dma_FixedByteCopy(Cpu_OpMov2Imm_1, &Dma_Global_Name(gCpu).Operands.Z, &Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u], 2u, &Dma_Global_Name(Cpu_Writeback_TwoRegs))
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
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpMov2Reg_2)

	// Copy from CurrentA to CurrentZ{7:0]
	Dma_FixedByteCopy(Cpu_OpMov2Reg_1, (Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u), &Dma_Global_Name(gCpu).Operands.A, 1u, &Dma_Global_Name(Cpu_OpMov2Reg_2))

	// Copy from CurrentB to CurrentZ[15:8]
	Dma_FixedByteCopy(Cpu_OpMov2Reg_2, (Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 1u), &Dma_Global_Name(gCpu).Operands.B, 1u, &Dma_Global_Name(Cpu_Writeback_TwoRegs))
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
	Dma_FixedAdd8(Cpu_OpAddImm8_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedCarryFromAdd8(Cpu_OpAcyImm8_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedAdd8(Cpu_OpAddReg_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedCarryFromAdd8(Cpu_OpAcyReg_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpImm16_2)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpImm16_3)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpImm16_4)

	// Load the program base into Cpu_NextPC
	Dma_FixedByteCopy(Cpu_OpJmpImm16_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC)      + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).ProgramBase) + 0u),
		4u,
		&Dma_Global_Name(Cpu_OpJmpImm16_2)
	)

	// Add lower 8-bit to program counter
	Cpu_FixedAdd8to16(Cpu_OpJmpImm16_2,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC)      + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).ProgramBase) + 0u),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u],
		&Dma_Global_Name(Cpu_OpJmpImm16_3)
	)

	// Add upper 8-bit to program counter
	Cpu_FixedAdd8to16(Cpu_OpJmpImm16_3,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC) + 1u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC) + 1u),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u],
		&Dma_Global_Name(Cpu_OpJmpImm16_4)
	)

	// Clip the upper 16 bit to the program base (this ensures module-16 behavior that is consistent
	// with the normal program counter increments). Then resume at fetch stage.
	Dma_FixedByteCopy(Cpu_OpJmpImm16_4,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC)      + 2u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).ProgramBase) + 2u),
		2,
		&Dma_Global_Name(Cpu_Writeback_PC)
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
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpReg16_2)
	DMACU_READONLY Dma_Declare_Descriptor(Cpu_OpJmpReg16_3)

	// Copy rB:rA into lower 16 bits of CurrentOPC, then delegate to JmpImm16
	Dma_FixedByteCopy(Cpu_OpJmpReg16_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC)     + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpJmpReg16_2)
	)

	Dma_FixedByteCopy(Cpu_OpJmpReg16_2,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC)     + 1u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpJmpReg16_3)
	)

	// Clip the upper 16 bit to the program base (this ensures module-16 behavior that is consistent
	// with the normal program counter increments). Then resume at fetch stage.
	Dma_FixedByteCopy(Cpu_OpJmpReg16_3,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC)      + 2u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).ProgramBase) + 2u),
		2u,
		&Dma_Global_Name(Cpu_Writeback_PC)
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
	Dma_FixedByteCopy(Cpu_OpBrNeReg_1,
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u],
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpBrNeImm_1)
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
	Dma_FixedByteCopy(Cpu_OpBrEqReg_1,
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u],
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpBrEqImm_1)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpBrNeImm_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpBrNeImm_3)
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpBrNeImm_4)
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpBrNeImm_5)
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpBrNeImm_6)

	// Fill the temporary LUT with the offset for branch taken (+off8)
	Dma_FixedByteFill(Cpu_OpBrNeImm_1,
		&Dma_Global_Name(Lut_Temporary)[0u],
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u],
		256u,
		&Dma_Global_Name(Cpu_OpBrNeImm_2)
	)

	// Prepare for patching the match location with offset for branch not taken (+4)
	Dma_FixedPatchDstLo8(Cpu_OpBrNeImm_2,
		&Dma_Global_Name(Cpu_OpBrNeImm_3),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u],
		&Dma_Global_Name(Cpu_OpBrNeImm_3)
	)

	// Patch the branch not taken location in the temporary LUT
	Dma_ByteCopy(Cpu_OpBrNeImm_3,
		&Dma_Global_Name(Lut_Temporary)[0u],
		Dmacu_PtrToByteLiteral(4u),
		1u,
		&Dma_Global_Name(Cpu_OpBrNeImm_4)
	)

	// Lookup the branch offset from the temporary LUT
	Dma_FixedSbox8(Cpu_OpBrNeImm_4,
		&Dma_Global_Name(gCpu).Scratchpad[1u],
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		&Dma_Global_Name(Lut_Temporary)[0u],
		&Dma_Global_Name(Cpu_OpBrNeImm_5)
	)

	// Update the lower 16-bits of the next PC (keep upper 16 bits intact)
	Cpu_FixedAdd8to16(Cpu_OpBrNeImm_5,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).PC) + 0u),
		&Dma_Global_Name(gCpu).Scratchpad[1u],
		&Dma_Global_Name(Cpu_OpBrNeImm_6)
	)

	// Clip the upper 16 bit
	Dma_FixedByteCopy(Cpu_OpBrNeImm_6,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC) + 2u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).PC) + 2u),
		2u,
		&Dma_Global_Name(Cpu_Writeback_PC)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpBrEqImm_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpBrEqImm_3)

	// Fill the temporary LUT with the offset for branch not taken (+4)
	Dma_FixedByteFill(Cpu_OpBrEqImm_1,
		&Dma_Global_Name(Lut_Temporary)[0u],
		Dmacu_PtrToByteLiteral(4u),
		256u,
		&Dma_Global_Name(Cpu_OpBrEqImm_2)
	)

	// Prepare for patching the match location with offset for branch not taken (+4)
	Dma_FixedPatchDstLo8(Cpu_OpBrEqImm_2,
		&Dma_Global_Name(Cpu_OpBrEqImm_3),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u],
		&Dma_Global_Name(Cpu_OpBrEqImm_3)
	)

	// Patch the branch taken location in the temporary LUT; then tail-call to the BrNeImm implemntation (from stage 4)
	Dma_ByteCopy(Cpu_OpBrEqImm_3,
		&Dma_Global_Name(Lut_Temporary)[0u],
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u],
		1u,
		&Dma_Global_Name(Cpu_OpBrNeImm_4)
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
	Dma_FixedSbox8(Cpu_OpBitNot_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Lut_BitNot[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Cpu_FixedLogicSbox4(Cpu_OpBitAnd_1, &Lut_BitAnd[0u])
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
	Cpu_FixedLogicSbox4(Cpu_OpBitOr_1, &Lut_BitOr[0u])
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
	Cpu_FixedLogicSbox4(Cpu_OpBitEor_1, &Lut_BitEor[0u])
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
	Dma_FixedSbox8(Cpu_OpRor_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Lut_RotateRight[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedSbox8(Cpu_OpRol_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Lut_RotateLeft[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedSbox8(Cpu_OpLo4_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Lut_Lo4[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedSbox8(Cpu_OpHi4_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Lut_Hi4[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	Dma_FixedSbox8(Cpu_OpShl4_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Lut_Mul16[0u],
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpJal_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpJal_3)

	// Copy the lower half of next PC value to rZ, then link to JmpReg16
	// (Clipping is consistent with program counter increment)
	Dma_FixedByteCopy(Cpu_OpJal_1,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).NextPC) + 0u),
		2u,
		&Dma_Global_Name(Cpu_OpJal_2)
	)

	// WB.FOUR.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+2]:...:Regfile[rZ]
	Dma_FixedPatchDstLo8(Cpu_OpJal_2,
		&Dma_Global_Name(Cpu_OpJal_3),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[2u],
		&Dma_Global_Name(Cpu_OpJal_3)
	)

	// WB.FOUR.2: Do copy from CurrentZ[15:0] to Regfile[rZ+2]:...:Regfile[rZ]
	Dma_ByteCopy(Cpu_OpJal_3,
		&Dma_Global_Name(gCpu).RegFile[0u],
		&Dma_Global_Name(gCpu).Operands.Z,
		2u,
		&Dma_Global_Name(Cpu_OpJmpImm16_1)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpLit32_2)
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpLit32_3)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpLit32_Commit)

	// Load the program base into the source address of the copy operation at step 4
	Dma_FixedByteCopy(Cpu_OpLit32_1,
		(Dma_PtrToAddr(&Dma_Global_Name(Cpu_OpLit32_Commit).src) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).ProgramBase) + 0u),
		4u,
		&Dma_Global_Name(Cpu_OpLit32_2)
	)

	// Add lower 8-bit to the source address
	Cpu_FixedAdd8to16(Cpu_OpLit32_2,
		(Dma_PtrToAddr(&Dma_Global_Name(Cpu_OpLit32_Commit).src) + 0u),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).ProgramBase) + 0u),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[0u],
		&Dma_Global_Name(Cpu_OpLit32_3)
	)

	// Add upper 8-bit to the source address
	Cpu_FixedAdd8to16(Cpu_OpLit32_3,
		(Dma_PtrToAddr(&Dma_Global_Name(Cpu_OpLit32_Commit).src) + 1u),
		(Dma_PtrToAddr(&Dma_Global_Name(Cpu_OpLit32_Commit).src) + 1u),
		&Dma_Global_Name(gCpu).CurrentOPC.Bytes[1u],
		&Dma_Global_Name(Cpu_OpLit32_Commit)
	)

	// Ignore clipping for LIT32 offsets (this allows is to load literals that sit slightly outside of the
	// 64k code segment)
	Dma_ByteCopy(Cpu_OpLit32_Commit,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		4u,
		&Dma_Global_Name(Cpu_Writeback_FourRegs)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpLoadByte_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpLoadByte_3)

	// Step 1: Patch in the lower 16 bits of the source address
	Dma_FixedPatchSrcLo16(Cpu_OpLoadByte_1,
		&Dma_Global_Name(Cpu_OpLoadByte_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_OpLoadByte_2)
	)

	// Step 2: Patch in the upper 16 bits of the source address
	Dma_FixedPatchSrcHi16(Cpu_OpLoadByte_2,
		&Dma_Global_Name(Cpu_OpLoadByte_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(Cpu_OpLoadByte_3)
	)

	// Step 3: Perform the load operation (byte)
	Dma_ByteCopy(Cpu_OpLoadByte_3,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		1u,
		&Dma_Global_Name(Cpu_Writeback_OneReg)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpLoadHalf_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpLoadHalf_3)

	// Step 1: Patch in the lower 16 bits of the source address
	Dma_FixedPatchSrcLo16(Cpu_OpLoadHalf_1,
		&Dma_Global_Name(Cpu_OpLoadHalf_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_OpLoadHalf_2)
	)

	// Step 2: Patch in the upper 16 bits of the source address
	Dma_FixedPatchSrcHi16(Cpu_OpLoadHalf_2,
		&Dma_Global_Name(Cpu_OpLoadHalf_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(Cpu_OpLoadHalf_3)
	)

	// Step 3: Perform the load operation (half-word)
	//
	// FIXME: Use a 16-bit DMA access (instead of two 8-bit DMA accesses)
	Dma_HalfWordCopy(Cpu_OpLoadHalf_3,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		1u,
		&Dma_Global_Name(Cpu_Writeback_TwoRegs)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpLoadWord_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpLoadWord_3)

	// Step 1: Patch in the lower 16 bits of the source address
	Dma_FixedPatchSrcLo16(Cpu_OpLoadWord_1,
		&Dma_Global_Name(Cpu_OpLoadWord_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_OpLoadWord_2)
	)

	// Step 2: Patch in the upper 16 bits of the source address
	Dma_FixedPatchSrcHi16(Cpu_OpLoadWord_2,
		&Dma_Global_Name(Cpu_OpLoadWord_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(Cpu_OpLoadWord_3)
	)

	// Step 3: Perform the load operation (half-word)
	//
	// FIXME: Use a 32-bit DMA access (instead of four 8-bit DMA accesses)
	Dma_WordCopy(Cpu_OpLoadWord_3,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		DMA_INVALID_ADDR,
		1u,
		&Dma_Global_Name(Cpu_Writeback_FourRegs)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpStoreByte_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpStoreByte_3)

	// Step 1: Patch in the lower 16 bits of the destination address
	Dma_FixedPatchDstLo16(Cpu_OpStoreByte_1,
		&Dma_Global_Name(Cpu_OpStoreByte_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_OpStoreByte_2)
	)

	// Step 2: Patch in the lower 16 bits of the destination address
	Dma_FixedPatchDstHi16(Cpu_OpStoreByte_2,
		&Dma_Global_Name(Cpu_OpStoreByte_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(Cpu_OpStoreByte_3)
	)

	// Step 3: Perform the store operation (byte)
	Dma_ByteCopy(Cpu_OpStoreByte_3,
		0,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		1u,
		&Dma_Global_Name(Cpu_Writeback_PC)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpStoreHalf_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpStoreHalf_3)

	// Step 1: Patch in the lower 16 bits of the destination address
	Dma_FixedPatchDstLo16(Cpu_OpStoreHalf_1,
		&Dma_Global_Name(Cpu_OpStoreHalf_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_OpStoreHalf_2)
	)

	// Step 2: Patch in the lower 16 bits of the destination address
	Dma_FixedPatchDstHi16(Cpu_OpStoreHalf_2,
		&Dma_Global_Name(Cpu_OpStoreHalf_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(Cpu_OpStoreHalf_3)
	)

	// Step 3: Perform the store operation (byte)
	Dma_HalfWordCopy(Cpu_OpStoreHalf_3,
		DMA_INVALID_ADDR,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		1u,
		&Dma_Global_Name(Cpu_Writeback_PC)
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
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpStoreWord_2)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpStoreWord_3)

	// Step 1: Patch in the lower 16 bits of the destination address
	Dma_FixedPatchDstLo16(Cpu_OpStoreWord_1,
		&Dma_Global_Name(Cpu_OpStoreWord_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		&Dma_Global_Name(Cpu_OpStoreWord_2)
	)

	// Step 2: Patch in the lower 16 bits of the destination address
	Dma_FixedPatchDstHi16(Cpu_OpStoreWord_2,
		&Dma_Global_Name(Cpu_OpStoreWord_3),
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		&Dma_Global_Name(Cpu_OpStoreWord_3)
	)

	// Step 3: Perform the store operation (byte)
	Dma_WordCopy(Cpu_OpStoreWord_3,
		DMA_INVALID_ADDR,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		1u,
		&Dma_Global_Name(Cpu_Writeback_PC)
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
// value 0xDEADC0DE to the Dma_Global_Name(gCpu).NextPC descriptor and terminates further DMA processing
// (by linking to the NULL descriptor). The instruction itself (and its 24-bit immediate
// operand) are retained in the Cpu_CurrentOPC register and can be used for debugging
// purposes (from the host system).
//
// Idea: Mapping of ARM semihosting calls:
// -> Trap the UND instruction on the host CPU (DMA transfer done, Dma_Global_Name(gCpu).NextPC shows
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
// -> Host interprets Dma_Global_Name(gCpu).Operanfs.{A,B,Z} and handles semihosting call
// -> Host sets Dma_Global_Name(gCpu).NextPC (typ. to Dma_Global_Name(gCpu).PC) and restarts DMA from Cpu_Fetch_1 stage.
//
Cpu_Opcode_Begin(Undef)
	DMACU_PRIVATE DMACU_CONST uint32_t Dma_Global_Name(Lit_DEADC0DE) = 0xDEADC0DEu;

	// Copy the 0xDEADC0DE value to Cpu_NextPC, then halt via LLI=0 and trigger a terminal count interrupt
	Dma_FixedTerminalWordCopy(Cpu_OpUndef_1,
		&Dma_Global_Name(gCpu).NextPC,
		Dma_Global_Reference(Lit_DEADC0DE),
		1u,
		DMA_INVALID_ADDR
	)
Cpu_Opcode_End(Undef)


// 0x20 - DMACPY rZ+3:rZ+2:rZ+1:rZ, rB+3:rB+2:rB+1:rB, rA+3:rA+2:rA+1:rA - PL080 DMA Copy
//
//  31     24     16      8      0
// +---------+------+------+------+
// | 0x20    |  rZ  |  rB  |  rA  |
// +---------+------+------+------+
//
// The DMACPY instruction enables the guest program to dynamically configure PL080 DMA transfers that are
// executed on the underlying DMA controller. The linked list item (LLI) of the transfer is fixed (and provided
// by the DMACU core itself).
//
// rZ+3:rZ+2:rZ+1:rZ - Mapped to the Channel Destination Address (DMACCxDstAddr)
// rB+3:rB+2:rB+1:rB - Mapped to the Channel Source Address      (DMACCxSrcAddr)
// rA+3:rA+2:rA+1:rA - Mapped to the Channel Control Register    (DMACCxControl)
//
//
Cpu_Opcode_Begin(DmaCpy)
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpDmaCpy_2)
	DMACU_READONLY  Dma_Declare_Descriptor(Cpu_OpDmaCpy_3)
	DMACU_READWRITE Dma_Declare_Descriptor(Cpu_OpDmaCpy_4)

	// Step 1: Configure the channel destination address
	Dma_FixedWordCopy(Cpu_OpDmaCpy_1,
		&Dma_Global_Name(Cpu_OpDmaCpy_4).dst,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.Z) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpDmaCpy_2)
	)

	// Step 2: Configure the channel source address
	Dma_FixedWordCopy(Cpu_OpDmaCpy_2,
		&Dma_Global_Name(Cpu_OpDmaCpy_4).src,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.B) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpDmaCpy_3)
	)

	// Step 3: Configure the channel control register
	Dma_FixedWordCopy(Cpu_OpDmaCpy_3,
		&Dma_Global_Name(Cpu_OpDmaCpy_4).ctrl,
		(Dma_PtrToAddr(&Dma_Global_Name(gCpu).Operands.A) + 0u),
		1u,
		&Dma_Global_Name(Cpu_OpDmaCpy_4)
	)

	// Step 4: User-configured DMA transfer
	Dma_ByteCopy(Cpu_OpDmaCpy_4,
		DMA_INVALID_ADDR,
		DMA_INVALID_ADDR,
		0u,
		&Dma_Global_Name(Cpu_Writeback_PC)
	)
Cpu_Opcode_End(DmaCpy)
