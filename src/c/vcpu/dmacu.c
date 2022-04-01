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
Dma_ByteCopy(Cpu_Fetch_2, &gCpu.CurrentOPC[0], DMA_INVALID_ADDR, sizeof(gCpu.CurrentOPC), &Cpu_Fetch_3)

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

//-----------------------------------------------------------------------------------------
//
// DMACU CPU Opcodes (Execute Stage)
//
//-----------------------------------------------------------------------------------------

#if NOT_YET_PORTED
	/**********************************************************************************************
	 *
	 * DMACU CPU Opcodes (Execute Stage)
	 *
	 **********************************************************************************************/

	// Start of an opcode implementation
	.macro Cpu_Opcode_Begin name
	.pushsection ".data.Cpu_Op\name", "aw", "progbits"
	.p2align 2
Cpu_Op\name:
	.endm

	// End of an opcode implementation
	.macro Cpu_Opcode_End name
	.type Cpu_Op\name, "object"
	.size Cpu_Op\name, . - Cpu_Op\name
	.popsection
	.endm

	/*
	 * NOP       - No Operation
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x00 | (0)  | (0)  | (0)  |
	 * +------+------+------+------+
	 *
	 * The NOP instruction is implemented as direct link from the decoder's dispatch table to the
	 * PC writeback stage (No separate DMA descriptors needed).
	*/
	.set Cpu_OpNop, .LCpu_Writeback.PC

	/*
	 * MOV rZ, #imm8 - Move to register from 8-bit immediate
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x01 | rZ   | (0)  | imm8 |
	 * +------+------+------+------+
	*/
	// Copy from CurrentOPC[7:0] to CurrentZ, then link to one register writeback
Cpu_Opcode_Begin MovImm
	Dma_ByteCopy Cpu_CurrentZ, (Cpu_CurrentOPC + 0), 1, .LCpu_Writeback.OneReg
Cpu_Opcode_End MovImm

	/*
	 * MOV rZ+1:rZ, #imm16 - Move to register pair from 16-bit immediate
	 *
	 *  31  24     16             0
	 * +------+------+-------------+
	 * | 0x02 | rZ   |       imm16 |
	 * +------+------+-------------+
	*/
Cpu_Opcode_Begin Mov2Imm
	// Copy from CurrentOPC[15:0] to CurrentZ, then link to one register writeback
	Dma_ByteCopy Cpu_CurrentZ, (Cpu_CurrentOPC + 0), 2, .LCpu_Writeback.TwoRegs
Cpu_Opcode_End Mov2Imm

	/*
	 * MOV2 rZ+1:rZ, rB:rA - Move from register pair to register pair
	 * MOV  rZ, rA         - (Pseudo-Instruction) Move from register to register (if rB=rZ+1)
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x03 |  rZ  | rB   |  rA  |
	 * +------+------+------+------+
	*/
Cpu_Opcode_Begin Mov2Reg
	// Copy from CurrentA to CurrentZ{7:0]
	Dma_ByteCopy (Cpu_CurrentZ + 0), Cpu_CurrentA, 1, Cpu_OpMov2Reg.WriteSecondReg

	// Copy from CurrentB to CurrentZ[15:8]
Cpu_OpMov2Reg.WriteSecondReg:
	Dma_ByteCopy (Cpu_CurrentZ + 1), Cpu_CurrentB, 1, .LCpu_Writeback.TwoRegs
Cpu_Opcode_End Mov2Reg

	/*
	 * ADD rZ, rB, #imm8               - Add register and 8-bit immediate
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x04 |  rZ  | rB   | imm8 |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin AddImm8
	// Add the 8-bit immediate (from instruction word [7:0]) to rB, store result in rZ
	Dma_Add8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentOPC + 0), .LCpu_Writeback.OneReg
Cpu_Opcode_End AddImm8

	/*
	 * ACY rZ, rB, #imm8               - Generate carry from add with 8-bit immediate
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x05 |  rZ  | rB   | imm8 |
	 * +------+------+------+------+
	*/
Cpu_Opcode_Begin AcyImm8
	// Generate the carry from rB+imm8, store in rZ
	Dma_CarryFromAdd8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentOPC + 0), .LCpu_Writeback.OneReg
Cpu_Opcode_End AcyImm8

	/*
	 * ADD rZ, rB, rA                  - Add two registers
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x06 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin AddReg
	// Add  rA and rB, store result in rZ
	Dma_Add8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentA + 0), .LCpu_Writeback.OneReg
Cpu_Opcode_End AddReg

	/*
	 * ACY rZ, rB, rA                 - Generate carry from add with 8-bit registers
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x07 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin AcyReg
	// Generate the carry from rA+rB, store in rZ
	Dma_CarryFromAdd8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentA + 0), .LCpu_Writeback.OneReg
Cpu_Opcode_End AcyReg

	/*
	 * JMP #imm16                    - Jump absolute
	 *
	 *  31  24 23                 0
	 * +------+------+-------------+
	 * | 0x08 |  (0) | imm16       |
	 * +------+------+-------------+
	 */
Cpu_Opcode_Begin JmpImm16
	// Load the program base into Cpu_NextPC
Cpu_OpJmpImm16.1:
	Dma_ByteCopy (Cpu_NextPC + 0), (Cpu_ProgramBase + 0), 4, Cpu_OpJmpImm16.2

	// Add lower 8-bit to program counter
Cpu_OpJmpImm16.2:
	Cpu_Add8To16 (Cpu_NextPC + 0), (Cpu_ProgramBase + 0), (Cpu_CurrentOPC + 0), Cpu_OpJmpImm16.3

	// Add upper 8-bit to program counter
Cpu_OpJmpImm16.3:
	Cpu_Add8To16 (Cpu_NextPC + 1), (Cpu_NextPC + 1), (Cpu_CurrentOPC + 1), Cpu_OpJmpImm16.4

	// Clip the upper 16 bit to the program base (this ensures module-16 behavior that is consistent
	// with the normal program counter increments). Then resume at fetch stage.
Cpu_OpJmpImm16.4:
	Dma_ByteCopy (Cpu_NextPC + 2), (Cpu_ProgramBase + 2), 2, .LCpu_Writeback.PC
Cpu_Opcode_End JmpImm16

	/*
	 * JMP rB:rA                    - Jump register indirect
	 * RET rA                       - (Pseudo-Instruction) Return from Subroutine (if rB=rZ+1)
	 *
	 * +------+------+------+------+
	 * | 0x09 |  (0) | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin JmpReg16
	// Copy rB:rA into lower 16 bits of CurrentOPC, then delegate to JmpImm16
Cpu_OpJmpReg16.1:
	Dma_ByteCopy (Cpu_CurrentOPC + 0), (Cpu_CurrentA + 0), 1, Cpu_OpJmpReg16.2
Cpu_OpJmpReg16.2:
	Dma_ByteCopy (Cpu_CurrentOPC + 1), (Cpu_CurrentB + 0), 1, Cpu_OpJmpImm16.1
Cpu_Opcode_End JmpReg16

	/*
	 * BNE (+off8) rZ, rB                   - Branch if not equal
	 *
	 * +------+------+------+------+
	 * | 0x0A |  rZ  | rB   | off8 |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BrNeReg
	// Copy rB value into imm8 field, to BrNeImm
	Dma_ByteCopy (Cpu_CurrentOPC + 1), (Cpu_CurrentB + 0), 1, Cpu_OpBrNeImm
Cpu_Opcode_End   BrNeReg

	/*
	 * BEQ (+off8) rZ, rB                   - Branch if equal
	 *
	 * +------+------+------+------+
	 * | 0x0B |  rZ  | rB   | off8 |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BrEqReg
	// Copy rB value into imm8 field, to BrEqImm
	Dma_ByteCopy (Cpu_CurrentOPC + 1), (Cpu_CurrentB + 0), 1, Cpu_OpBrEqImm
Cpu_Opcode_End BrEqReg


	/*
	 * BNE (+off8) rZ, #imm8                - Branch if not equal
	 *
	 * +------+------+------+------+
	 * | 0x0C |  rZ  | imm8 | off8 |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BrNeImm

Cpu_OpBrNeImm.1:
	// Fill the temporary LUT with the offset for branch taken (+off8)
	Dma_ByteFill Lut_Temporary, (Cpu_CurrentOPC + 0), 256, Cpu_OpBrNeImm.2

Cpu_OpBrNeImm.2:
	// Prepare for patching the match location with offset for branch not taken (+4)
	Dma_PatchDstLo8 Cpu_OpBrNeImm.3, (Cpu_CurrentOPC + 1), Cpu_OpBrNeImm.3

Cpu_OpBrNeImm.3:
	// Patch the branch not taken location in the temporary LUT
	Dma_ByteCopy Lut_Temporary, Lit_04, 1, Cpu_OpBrNeImm.4

Cpu_OpBrNeImm.4:
	// Lookup the branch offset from the temporary LUT
	Dma_Sbox8 (Cpu_Scratchpad + 1), (Cpu_CurrentZ + 0), Lut_Temporary, Cpu_OpBrNeImm.5

Cpu_OpBrNeImm.5:
	// Update the lower 16-bits of the next PC (keep upper 16 bits intact)
	Cpu_Add8To16 (Cpu_NextPC + 0), (Cpu_PC + 0), (Cpu_Scratchpad + 1), Cpu_OpBrNeImm.6

Cpu_OpBrNeImm.6:
	// Clip the upper 16 bit
	Dma_ByteCopy (Cpu_NextPC + 2), (Cpu_PC + 2), 2, .LCpu_Writeback.PC
Cpu_Opcode_End   BrNeImm

	/*
	 * BEQ (+off8) rZ, #imm8                - Branch if equal
	 *
	 * +------+------+------+------+
	 * | 0x0D |  rZ  | imm8 | off8 |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BrEqImm
Cpu_OpBrEqImm.1:
	// Fill the temporary LUT with the offset for branch not taken (+4)
	Dma_ByteFill Lut_Temporary, Lit_04, 256, Cpu_OpBrEqImm.2

Cpu_OpBrEqImm.2:
	// Prepare for patching the match location with offset for branch not taken (+4)
	Dma_PatchDstLo8 Cpu_OpBrEqImm.3, (Cpu_CurrentOPC + 1), Cpu_OpBrEqImm.3

Cpu_OpBrEqImm.3:
	// Patch the branch taken location in the temporary LUT; then tail-call to the BrNeImm implemntation
	Dma_ByteCopy Lut_Temporary, (Cpu_CurrentOPC + 0), 1, Cpu_OpBrNeImm.4
Cpu_Opcode_End BrEqImm

	/*
	 * NOT rZ, rB                      - Bitwise NOT
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x0E |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BitNot
	// Lookup via bitwise NOT table
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_BitNot, .LCpu_Writeback.OneReg
Cpu_Opcode_End BitNot

	/*
	 * AND rZ, rB, rA                  - Bitwise AND
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x0F |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BitAnd
	// Lookup via 4-bit x 4-bit logic AND LUT
	Cpu_LogicSbox4 Lut_BitAnd
Cpu_Opcode_End BitAnd

	/*
	 * OR  rZ, rB, rA                  - Bitwise OR
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x10 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BitOr
	// Lookup via 4-bit x 4-bit logic AND LUT
	Cpu_LogicSbox4 Lut_BitOr
Cpu_Opcode_End BitOr

	/*
	 * EOR rZ, rB, rA                  - Bitwise XOR
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x11 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin BitEor
	// Lookup via 4-bit x 4-bit logic EOR LUT
	Cpu_LogicSbox4 Lut_BitEor
Cpu_Opcode_End BitEor

	/*
	 * ROR rZ, rB, #1                  - Rotate-Right by 1
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x12 |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin Ror
	// Lookup via ROR table
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_RotateRight, .LCpu_Writeback.OneReg
Cpu_Opcode_End Ror

	/*
	 * ROL rZ, rB, #1                  - Rotate-Left by 1
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x13 |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin Rol
	// Lookup via ROL table (note: could also be done as 8 times ROR)
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_RotateLeft, .LCpu_Writeback.OneReg
Cpu_Opcode_End Rol

	/*
	 * LO4 rZ, rB                      - Extract lower 4 bits
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x14 |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin Lo4
	// Lookup via bitwise LO4 table
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_Lo4, .LCpu_Writeback.OneReg
Cpu_Opcode_End Lo4

	/*
	 * HI4 rZ, rB                      - Extract upper 4 bits
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x15 |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin Hi4
	// Lookup via bitwise HI4 table
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_Hi4, .LCpu_Writeback.OneReg
Cpu_Opcode_End Hi4

	/*
	 * SHL4 rZ, rB                     - Shift left by 4 bits
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x16 |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin Shl4
	// Lookup via bitwise SHL4 table
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_Mul16, .LCpu_Writeback.OneReg
Cpu_Opcode_End Shl4

	/*
	 * JAL rZ+1:rZ, #imm16             - Jump and Link
	 *
	 *  31  24     16      8      0
	 * +------+------+-------------+
	 * | 0x17 |  rZ  | imm16       |
	 * +------+------+-------------+
	 */
Cpu_Opcode_Begin Jal
	// Copy the lower half of next PC value to rZ, then link to JmpReg16
	// (Clipping is consistent with program counter increment)
Cpu_OpJal.1:
	Dma_ByteCopy (Cpu_CurrentZ + 0), (Cpu_NextPC + 0), 2, Cpu_OpJal.2

Cpu_OpJal.2:
	// WB.FOUR.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+2]:...:Regfile[rZ]
	Dma_PatchDstLo8 Cpu_OpJal.3, (Cpu_CurrentOPC + 2), Cpu_OpJal.3

Cpu_OpJal.3:
	// WB.FOUR.2: Do copy from CurrentZ[15:0] to Regfile[rZ+2]:...:Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 2, Cpu_OpJmpImm16
Cpu_Opcode_End Jal

	/*
	 * LIT32 rZ+3:rZ+2:rZ+1:rZ, (off16) - Load a 32-bit literal
	 *
	 *  31  24     16      8      0
	 * +------+------+-------------+
	 * | 0x17 |  rZ  | (off16)     |
	 * +------+------+-------------+
	 */
Cpu_Opcode_Begin Lit32
	// Load the program base into the source address of the copy operation at step 4
Cpu_OpLit32.1:
	Dma_ByteCopy (Cpu_OpLit32.Commit + 0), (Cpu_ProgramBase + 0), 4, Cpu_OpLit32.2

	// Add lower 8-bit to rZ
Cpu_OpLit32.2:
	Cpu_Add8To16 (Cpu_OpLit32.Commit + 0), (Cpu_ProgramBase + 0), (Cpu_CurrentOPC + 0), Cpu_OpLit32.3

	// Add upper 8-bit to program counter
Cpu_OpLit32.3:
	Cpu_Add8To16 (Cpu_OpLit32.Commit + 1), (Cpu_OpLit32.Commit + 1), (Cpu_CurrentOPC + 1), Cpu_OpLit32.Commit

	// Ignore clipping for LIT32 offsets (this allows is to load literals that sit slightly outside of the
	// 64k code segment)
Cpu_OpLit32.Commit:
	Dma_ByteCopy (Cpu_CurrentZ + 0), (0xBADC0DE0), 4, .LCpu_Writeback.FourRegs
Cpu_Opcode_End   Lit32

	/*
	 * LDB rZ, [rB+1:rB:rA+1:rA]        - Load byte indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x19 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin LoadByte
	Dma_PatchSrcLo16 (Cpu_OpLoadByte.Load), (Cpu_CurrentA + 0), Cpu_OpLoadByte.AdrHi
Cpu_OpLoadByte.AdrHi:
	Dma_PatchSrcHi16 (Cpu_OpLoadByte.Load), (Cpu_CurrentB + 0), Cpu_OpLoadByte.Load
Cpu_OpLoadByte.Load:
	Dma_ByteCopy     (Cpu_CurrentZ + 0), 0, 1, .LCpu_Writeback.OneReg
Cpu_Opcode_End LoadByte

	/*
	 * LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load half-word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1B |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin LoadHalf
	Dma_PatchSrcLo16 (Cpu_OpLoadHalf.Load), (Cpu_CurrentA + 0), Cpu_OpLoadHalf.AdrHi
Cpu_OpLoadHalf.AdrHi:
	Dma_PatchSrcHi16 (Cpu_OpLoadHalf.Load), (Cpu_CurrentB + 0), Cpu_OpLoadHalf.Load
Cpu_OpLoadHalf.Load:
	Dma_ByteCopy     (Cpu_CurrentZ + 0), 0, 2, .LCpu_Writeback.TwoRegs
Cpu_Opcode_End LoadHalf

	/*
	 * LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1D |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin LoadWord
	Dma_PatchSrcLo16 (Cpu_OpLoadWord.Load), (Cpu_CurrentA + 0), Cpu_OpLoadWord.AdrHi
Cpu_OpLoadWord.AdrHi:
	Dma_PatchSrcHi16 (Cpu_OpLoadWord.Load), (Cpu_CurrentB + 0), Cpu_OpLoadWord.Load
Cpu_OpLoadWord.Load:
	Dma_ByteCopy     (Cpu_CurrentZ + 0), 0, 4, .LCpu_Writeback.FourRegs
Cpu_Opcode_End LoadWord

	/*
	 * STB rZ, [rB+1:rB:rA+1:rA]        - Store byte indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1A |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin StoreByte
	Dma_PatchDstLo16 (Cpu_OpStoreByte.Store), (Cpu_CurrentA + 0), Cpu_OpStoreByte.AdrHi
Cpu_OpStoreByte.AdrHi:
	Dma_PatchDstHi16 (Cpu_OpStoreByte.Store), (Cpu_CurrentB + 0), Cpu_OpStoreByte.Store
Cpu_OpStoreByte.Store:
	Dma_ByteCopy     0, (Cpu_CurrentZ + 0), 1, .LCpu_Writeback.PC
Cpu_Opcode_End StoreByte

	/*
	 * STH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store half-word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1C |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin StoreHalf
	Dma_PatchDstLo16 (Cpu_OpStoreHalf.Store), (Cpu_CurrentA + 0), Cpu_OpStoreHalf.AdrHi
Cpu_OpStoreHalf.AdrHi:
	Dma_PatchDstHi16 (Cpu_OpStoreHalf.Store), (Cpu_CurrentB + 0), Cpu_OpStoreHalf.Store
Cpu_OpStoreHalf.Store:
	Dma_ByteCopy     0, (Cpu_CurrentZ + 0), 2, .LCpu_Writeback.PC
Cpu_Opcode_End StoreHalf

	/*
	 * STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1E |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_Opcode_Begin StoreWord
	Dma_PatchDstLo16 (Cpu_OpStoreWord.Store), (Cpu_CurrentA + 0), Cpu_OpStoreWord.AdrHi
Cpu_OpStoreWord.AdrHi:
	Dma_PatchDstHi16 (Cpu_OpStoreWord.Store), (Cpu_CurrentB + 0), Cpu_OpStoreWord.Store
Cpu_OpStoreWord.Store:
	Dma_ByteCopy     0, (Cpu_CurrentZ + 0), 4, .LCpu_Writeback.PC
Cpu_Opcode_End StoreWord

	/*
	 * UND #imm24 - Undefined Instruction
	 *
	 *  31     24     16      8      0
	 * +---------+------+------+------+
	 * | 0x1F(*) | (0)  | (0)  | (0)  |
	 * +---------+------+------+------+
	 *
	 * (*) Canonical encoding of the undefined instruction
	 *
	 * The UND instruction (or any other undefined instruction encoding) writes the special
	 * value 0xDEADC0DE to the Cpu_NextPC descriptor and terminates further DMA processing
	 * (by linking to the NULL descriptor). The instruction itself (and its 24-bit immediate
	 * operand) are retained in the Cpu_CurrentOPC register and can be used for debugging
	 * purposes (from the host system).
	 */
Cpu_Opcode_Begin Undef
	// Copy the 0xDEADC0DE value to Cpu_NextPC, then halt via LLI=0
	Dma_ByteCopy Cpu_NextPC, Cpu_OpUndef.Lit_DEADCODE, 4, 0x00000000

Cpu_OpUndef.Lit_DEADCODE:
	.long 0xDEADC0DE
Cpu_Opcode_End Undef

	/*
	 * Export the CPU entrypoint
	 *
	 * CPU processing starts at the RST.1 stage.
	 */
	.global Dma_UCode_CPU
	.set Dma_UCode_CPU, .LCpu_Reset.1

	/**********************************************************************************************
	 *
	 * DMACU CPU Pipelines (Execute Stage)
	 *
	**********************************************************************************************/
#if DMACU_USE_CPU_EXECUTE_LOGIC
	//
	// Use Cpu_Execute_Logic sub-pipline instead of the macro
	//
	.p2align 2
Cpu_Execute_Logic:
	// Step 1: Execute the active logic sbox given by Cpu_ActiveLogicSbox
	Dma_LogicSbox4_Indirect (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentA + 0), Cpu_ActiveLogicSbox, .LCpu_Writeback.OneReg
#endif
#endif
