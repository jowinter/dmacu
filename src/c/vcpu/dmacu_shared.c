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
 * @brief Virtual CPU emulator core (PL080 backend; shared lookup tables)
 */
#include "dmacu.h"

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
DMACU_READONLY uint8_t Lut_BitNot[256u] =
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
DMACU_READONLY uint8_t Lut_Neg[256u] =
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
DMACU_READONLY uint8_t Lut_RotateRight[256u] =
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
DMACU_READONLY uint8_t Lut_RotateLeft[256u] =
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
DMACU_READONLY uint8_t Lut_Lo4[256u] =
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
DMACU_READONLY uint8_t Lut_Hi4[256u] =
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
DMACU_READONLY uint8_t Lut_Mul4[256u] =
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
DMACU_READONLY uint8_t Lut_Mul16[256u] =
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
DMACU_READONLY uint8_t Lut_BitAnd[256u] =
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
DMACU_READONLY uint8_t Lut_BitOr[256u] =
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
DMACU_READONLY uint8_t Lut_BitEor[256u] =
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
DMACU_READONLY uint8_t Lut_Identity[512u] =
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
DMACU_READONLY uint8_t Lut_Carry[512u] =
{
#define Lut_Carry_Generator(_x) \
    ((uint8_t) (((_x) >> 8u) & 0x01u))

    LUT_MAKE_512(Lut_Carry_Generator, 0u)
};

