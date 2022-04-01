	/**
	 * Runtime library for DMA based processing (ARM PL080 variant)
	 *
	 * Copyright (c) 2021 Johannes Winter
	 *
	 * This file is licensed under the MIT License. See LICENSE in the root directory
	 * of the prohect for the license text.
	 */

	/*******************************************************************************************
	 * Basic DMA descriptors
	 ******************************************************************************************/
	/*
	 * Basic byte-wise DMA copy operation
	 *
	 * Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
	 */
	.macro Dma_ByteCopy dst, src, size, lli
	.long (\src)
	.long (\dst)
	.long (\lli)
	.long (0x0C000000 + \size)
	.endm

	/*
	 * Basic byte-wise DMA fill operation.
	 *
	 * Fills a block of "size" bytes at "dst" with the byte found at "src". Then links to the
	 * next descriptor at "lli".
	 */
	.macro Dma_ByteFill dst, src, size, lli
	.long (\src)
	.long (\dst)
	.long (\lli)
	.long (0x08000000 + \size)
	.endm

	/*******************************************************************************************
	 * Descriptor source address patch operations
	 ******************************************************************************************/

	/*
	 * Patches bits [7:0] of the source address of the DMA descriptor at "dst" with the byte
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchSrcLo8 dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 1, \lli
	.endm

	/*
	 * Patches bits [15:8] of the source address of the DMA descriptor at "dst" with the byte
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchSrcHi8 dst, src, lli
	Dma_ByteCopy (\dst+1), (\src), 1, \lli
	.endm

	/*
	 * Patches bits [15:0] of the source address of the DMA descriptor at "dst" with the
	 * half-word found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchSrcLo16 dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 2, \lli
	.endm

	/*
	 * Patches bits [31:16] of the source address of the DMA descriptor at "dst" with the
	 * half-word found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchSrcHi16 dst, src, lli
	Dma_ByteCopy (\dst+2), (\src), 2, \lli
	.endm

	/*
	 * Patches the whole destination address of the DMA descriptor at "dst" with the word
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchSrc dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 4, \lli
	.endm

	/*******************************************************************************************
	 * Descriptor destination address patch operations
	 ******************************************************************************************/

	/*
	 * Patches bits [7:0] of the destination address of DMA descriptor at "dst" with the byte
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchDstLo8 dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 1, \lli
	.endm

	/*
	 * Patches bits [15:8] of the destination address of DMA descriptor at "dst" with the byte
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchDstHi8 dst, src, lli
	Dma_ByteCopy (\dst+5), (\src), 1, \lli
	.endm

	/*
	 * Patches bits [15:0] of the destinatoin address of the DMA descriptor at "dst" with the
	 * half-word found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchDstLo16 dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 2, \lli
	.endm

	/*
	 * Patches bits [31:16] of the destinatoin address of the DMA descriptor at "dst" with the
	 * half-word found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchDstHi16 dst, src, lli
	Dma_ByteCopy (\dst+6), (\src), 2, \lli
	.endm

	/*
	 * Patches the entire destination address of the DMA descriptor at "dst" with the word
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchDst dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 4, \lli
	.endm

	/*******************************************************************************************
	 * Descriptor link address patch operations
	 ******************************************************************************************/

	/*
	 * Patches the entire link address (lli) of the DMA descriptor at "dst" with the word
	 * found at "src". Then links to the next descriptor at "lli".
	 */
	.macro Dma_PatchLink dst, src, lli
	Dma_ByteCopy (\dst+8), (\src), 4, \lli
	.endm

	/*******************************************************************************************
	 * Lookup-Tables (SBOXes)
	 ******************************************************************************************/

	/**
	 * Substitutes a byte read from "src" via the lookup table given by "sbox" and
	 * stores the result byte at "dst". Then links to the next descriptor at "lli".
	 *
	 *
	 * C model:
	 *   void Dma_Sbox8(uint8_t* dst, const uint8_t* src, const uint8_t sbox[256u])
	 *   {
	 *      *dst = sbox[*src];
	 *   }
	 *
	 * Constraints:
	 *   The lookup table at "sbox" must be aligned to a 256-byte boundary for proper
	 *   operation.
	 */
	.macro Dma_Sbox8 dst, src, sbox, lli
	// Step 1: Load the source byte from src and substitute it into the sbox address
	Dma_PatchSrcLo8 .LDma_Sbox8_Lookup\@, \src, .LDma_Sbox8_Lookup\@

	// Step 2: Read the byte from the (patched) sbox location and store to dst
.LDma_Sbox8_Lookup\@:
	Dma_ByteCopy    \dst, \sbox, 1, \lli
	.endm

	/**
	 * Reads a word from "tableptr" and patches the lookup table pointer
	 * at the Dma_Sbox8 primitive found at "dst". Then links to the next descriptor at "lli".
	 *
	 * C model (roughly):
	 *   void Dma_Sbox8_PatchTableImm_And_Lookup(uint8_t* dst, const uint8_t* src, const uint8_t **tableptr)
	 *   {
	 *      // Dma_Sbox8_PatchTableImm (logically) fetches the lookup table pointer of the following lookup
	 *      // (implementation wise this is achived by patching "sbox" of the following Dma_Sbox8)
	 *      const uint8_t *sbox = *tableptr;
	 *
	 *      // Dma_Sbox8 performs the actual lookup
	 *      *dst = sbox[*src];
	 *   }
	 *
	 */
	.macro Dma_Sbox8_PatchTableImm dst, tableptr, lli
	// We patch the SBOX in step 2 of the lookup in the Dma_Sbox8 macro
	Dma_PatchSrc (\dst+16), (\tableptr), \lli
	.endm

	/**
	 * Starts the definition of a constant (read-only) look-up table.
	 */
	.macro Lut_Begin name, align=8
	.pushsection ".rodata.dma.Lut_\name", "a", "progbits"
	.p2align \align
Lut_\name:
	.endm

	/**
	 * Ends the definition of a constant (read-only) look-up table.
	 */
	.macro Lut_End name
	.type Lut_\name, "object"
	.size Lut_\name, . - Lut_\name
	.popsection
	.endm

	/**
	 * Temporary Look-Up Table
	 *
	 * This lookup table is used by addition and carry generation as a scratchpad area.
	 * (see e.g. Dma_Add8)
	 */
	.pushsection ".bss.dma.Lut_Temporary", "a", "nobits"
	.p2align 8
Lut_Temporary:
	.space 0x100, 0x00
	.type Lut_Temporary, "object"
	.size Lut_Temporary, . - Lut_Temporary
	.popsection

	/**
	 * Scratchpad Memory for Lookup-Table Operations
	 *
	 * This lookup table is used by addition and carry generation as a scratchpad area.
	 * (see e.g. Dma_Add8)
	 */
	.pushsection ".bss.dma.Lut_Scratchpad", "a", "nobits"
	.p2align 2
Lut_Scratchpad:
	.space 0x10, 0x00
	.type Lut_Scratchpad, "object"
	.size Lut_Scratchpad, . - Lut_Scratchpad
	.popsection

	/*-----------------------------------------------------------------------------------------*/
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

	/*-----------------------------------------------------------------------------------------
	 * Addition and carry generation
	*-----------------------------------------------------------------------------------------*/

	/**
	 * Adds two bytes read from memory operands "src1" and "src2" and store the result in dst.
	 *
	 * C model:
	 *   void Dma_Add8(uint8_t *dst, const uint8_t *src1, const uint8_t *src2)
	 *   {
	 *     *dst = (*src1 + *src2) & 0xFF;
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Temporary for processing
	 */
	.macro Dma_Add8 dst, src1, src2, lli
	// Step 1: Load source byte from src1 and patch it into the source address for loading the temporary LUT
	Dma_PatchSrcLo8 .LDma_Add8_LoadTempLut\@, \src1, .LDma_Add8_LoadTempLut\@

	// Step 2: Load the temporary LUT with with the identity LUT (offset by src1 memory operand)
.LDma_Add8_LoadTempLut\@:
	Dma_ByteCopy    Lut_Temporary, Lut_Identity, 0x100, .LDma_Add8_LookupSum\@

	// Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand)
.LDma_Add8_LookupSum\@:
	Dma_Sbox8       \dst, \src2, Lut_Temporary, \lli
	.endm

	/**
	 * Adds the 8-bit immediate "imm8" to the byte read from memory operand "src1" and stores the
	 * result in "dst".
	 *
	 * C model:
	 *   void Dma_Add8Imm(uint8_t *dst, const uint8_t *src1, const uint8_t imm8)
	 *   {
	 *     *dst = (*src1 + imm8) & 0xFF;
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Temporary for processing
	 */
	.macro Dma_Add8Imm dst, src1, imm8, lli
	// Step 1: Load the temporary LUT with with the identity LUT offset by imm8 operand
	Dma_ByteCopy    Lut_Temporary, (Lut_Identity + \imm8), 0x100, .LDma_Add8Imm_LookupSum\@

	// Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand)
.LDma_Add8Imm_LookupSum\@:
	Dma_Sbox8       \dst, \src1, Lut_Temporary, \lli
	.endm

	/**
	 * Subtracts the 8-bit immediate "imm8" from the byte read from memory operand "src1" and stores the
	 * result in "dst".
	 *
	 * C model:
	 *   void Dma_Sub8Imm(uint8_t *dst, const uint8_t *src1, const uint8_t imm8)
	 *   {
	 *     *dst = (*src1 + (0x100 - imm8)) & 0xFF;
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Temporary for processing
	 */
	.macro Dma_Sub8Imm dst, src1, imm8, lli
	// Implement as Add8Imm using using the upper half of the identity LUT as starting point.
	Dma_Add8Imm \dst, \src1, (0x100 - \imm8), \lli
	.endm

	/*
	 * Adds the bytes read from two 8-bit memory operands "src1" and "src2" and stores the
	 * carry of the addition in "dst".
	 *
	*
	 * C model:
	 *   void Dma_CarryFromAdd8(uint8_t *dst, const uint8_t *src1, const uint8_t *src2)
	 *   {
	 *     *dst = ((*src1 + *src2) >> 8) & 0x01;
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Temporary for processing
	 */
	.macro Dma_CarryFromAdd8 dst, src1, src2, lli
	// Step 1: Patch the source address of the of the carry LUT copy operation
	Dma_PatchSrcLo8 .LDma_CarryFromAdd8_LoadTempLut\@, \src1, .LDma_CarryFromAdd8_LoadTempLut\@

	// Step 2: Load the temporary LUT with with the carry LUT offset by imm8 operand
.LDma_CarryFromAdd8_LoadTempLut\@:
	Dma_ByteCopy    Lut_Temporary, Lut_Carry, 0x100, .LDma_CarryFromAdd8_LookupCarry\@

	// Step 3: Lookup the carry using the temporary LUT (indexed by src2 memory operand)
.LDma_CarryFromAdd8_LookupCarry\@:
	Dma_Sbox8       \dst, \src2, Lut_Temporary, \lli
	.endm

	/**
	 * Adds the 8-bit immediate "imm8" to the byte read from memory operand "src1" and stores
	 * the carry of the addition in "dst".
	 *
	 *
	 * C model:
	 *   void Dma_CarryFromAdd8Imm(uint8_t *dst, const uint8_t *src1, const uint8_t imm8)
	 *   {
	 *     *dst = ((*src1 + imm8) >> 8) & 0x01;
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Temporary for processing
	 */
	.macro Dma_CarryFromAdd8Imm dst, src1, imm8, lli
	// Step 1: Load the temporary LUT with with the carry LUT offset by imm8 operand
	Dma_ByteCopy    Lut_Temporary, (Lut_Carry + \imm8), 0x100, .LDma_CarryFromAdd8Imm_LookupCarry\@

	// Step 2: Lookup the carry using the temporary LUT (indexed by src2 memory operand)
.LDma_CarryFromAdd8Imm_LookupCarry\@:
	Dma_Sbox8       \dst, \src1, Lut_Temporary, \lli
	.endm

	/*-----------------------------------------------------------------------------------------
	 * Lookup tables for Unary Functions (uint8_t -> uint8_t)
	 *-----------------------------------------------------------------------------------------*/
	/**
	 * Bitwise Complement (1's complement)
	 *
	 * C model:
	 *   uint8_t BitNot(const uint8_t a)
	 *   {
	 *     return ~a & 0xFFu;
	 *   }
	 */
	Lut_Begin BitNot
	.set .L_i, 0
	.rept 256

	.byte (~.L_i & 0xFF)

	.set .L_i, .L_i + 1
	.endr
	Lut_End BitNot

	/**
	 * Two's Complement / Negation
	 *
	 * C model:
	 *   uint8_t BitNeg(const uint8_t a)
	 *   {
	 *     return -a & 0xFFu;
	 *   }
	 */
	Lut_Begin Neg
	.set .L_i, 0
	.rept 256

	.byte (-.L_i & 0xFF)

	.set .L_i, .L_i + 1
	.endr
	Lut_End Neg

	/**
	 * Logic Rotate-Right by 1
	 *
	 * C model:
	 *   uint8_t RotateRight(const uint8_t a)
	 *   {
	 *     return (a >> 1u) | ((a & 0x1) << 7u);
	 *   }
	 */
	Lut_Begin RotateRight
	.set .L_i, 0
	.rept 256

	.byte ((.L_i >> 1) | (.L_i & 1) << 7)

	.set .L_i, .L_i + 1
	.endr
	Lut_End RotateRight

	/**
	 * Logic Rotate-Left by 1
	 *
	 * C model:
	 *   uint8_t RotateLeft(const uint8_t a)
	 *   {
	 *     return ((a & 0x7Fu) << 1u) | (a >> 7u);
	 *   }
	 */
	Lut_Begin RotateLeft
	.set .L_i, 0
	.rept 256

	.byte ((.L_i & 0x7F) << 1) | (.L_i >> 1)

	.set .L_i, .L_i + 1
	.endr
	Lut_End RotateLeft

	/*
	 * Extract Lower Nibble / Mask with 0x0F
	 *
	 * C model:
	 *   uint8_t Lo4(const uint8_t a)
	 *   {
	 *     return a & 0x0Fu;
	 *   }
	 */
	Lut_Begin Lo4
	.set .L_i, 0
	.rept 256

	.byte (.L_i & 0x0F)

	.set .L_i, .L_i + 1
	.endr
	Lut_End Lo4

	/*
	 * Divide by 16 / Logic-Shift Right by 4 / Extract Upper Nibble
	 *
	 * C model:
	 *   uint8_t Hi4(const uint8_t a)
	 *   {
	 *     return (a >> 4u) & 0x0Fu;
	 *   }
	 */
	Lut_Begin Hi4
	.set .L_i, 0
	.rept 256

	.byte ((.L_i >> 4) & 0x0F)

	.set .L_i, .L_i + 1
	.endr
	Lut_End Hi4

	/**
	 * Multiply by 4 / Logic Shift-Left by 2
	 */
	Lut_Begin Mul4
	.set .L_i, 0
	.rept 256

	.byte ((.L_i * 4) & 0xFF)

	.set .L_i, .L_i + 1
	.endr
	Lut_End Mul4

	/**
	 * Multiply by 16 / Logic Shift-Left by 4
	 *
	 * C model:
	 *   uint8_t Mul16(const uint8_t a)
	 *   {
	 *     return (a & 0x0Fu) << 4u;
	 *   }
	 */
	Lut_Begin Mul16
	.set .L_i, 0
	.rept 256

	.byte ((.L_i * 16) & 0xFF)

	.set .L_i, .L_i + 1
	.endr
	Lut_End Mul16

	/*-----------------------------------------------------------------------------------------
	 * Lookup tables for Binary Functions (Lower Nibble)
	 *
	 * Logic functions:
	 *  Full lookup tables for 8-bit x 8-bit lookups would occupy 64k for each table. To conserve
	 *  ROM/flash space we store 4-bit x 4-bit lookup tables and use construct the 8-bit result
	 *  from from two lookups on the upper/lower nibble of the operand bytes.
	 *
	 *-----------------------------------------------------------------------------------------*/

	/**
	 * 8-bit arbitrary logic function (AND/OR/XOR) with 2 inputs.
	 *
	 * Reads two source bytes from "src1" and "src2", applies the logic function described
	 * by the 4-bit x 4-bit lookup table "table" and stores the result in "dst". Then links
	 * to next descriptor at "lli".
	 *
	 * Storing a full LUT for 8-bit inputs src1 and src2 would require 64k entries. We use a divide and conquer
	 * approach to implement 8-bit logic functions on top of 4-bit x 4-bit LUT:
	 *
	 * C model:
	 *   void Dma_LogicSbox4(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, const uint8_t *table)
	 *   {
	 *      uint lo = table[(*src1 & 0x0F) + ((*src2 & 0x0F) << 4u)];
	 *      uint hi = table[((*src1 >> 4) & 0x0F) + (((*src2 >> 4) & 0x0F) << 4u)];
	 *      *dst = (hi << 4) + lo;
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Scratchpad for processing.
	 *   This macro defines local labels "1" and "2" to enable seamless interaction with Dma_LogicSbox4_Indirect
	 */
	.macro Dma_LogicSbox4 dst, src1, src2, table, lli
	// Step 1: Extract lower 4 bits of operand A into t0
.LDma_LogicSbox4_Lo4_A\@:
	Dma_Sbox8 (Lut_Scratchpad + 0), \src1, Lut_Lo4, .LDma_LogicSbox4_Lo4_B\@

	// Step 2: Extract lower 4 bits of operand B into t1
.LDma_LogicSbox4_Lo4_B\@:
	Dma_Sbox8 (Lut_Scratchpad + 1), \src2, Lut_Lo4, .LDma_LogicSbox4_Lo4_Mul16_B\@

	// Step 3: Multiply t1 by 16
.LDma_LogicSbox4_Lo4_Mul16_B\@:
	Dma_Sbox8 (Lut_Scratchpad + 1), (Lut_Scratchpad + 1), Lut_Mul16, .LDma_LogicSbox4_Lo_Combine\@

	// Step 4: Add t0 and t1 to get the lookup table index into the 4-bit x 4-bit LUT
.LDma_LogicSbox4_Lo_Combine\@:
	Dma_Add8  (Lut_Scratchpad + 2), (Lut_Scratchpad + 1), (Lut_Scratchpad + 0), .LDma_LogicSbox4_Lo_Lookup\@

	// Step 5: Lookup on lower 4 bits
.LDma_LogicSbox4_Lo_Lookup\@:
1:
	Dma_Sbox8 (Lut_Scratchpad + 2), (Lut_Scratchpad + 2), \table, .LDma_LogicSbox4_Hi4_A\@

	// Step 6: Extract lower 4 bits of operand A into t0
.LDma_LogicSbox4_Hi4_A\@:
	Dma_Sbox8 (Lut_Scratchpad + 0), \src1, Lut_Hi4, .LDma_LogicSbox4_Hi4_B\@

	// Step 7: Extract lower 4 bits of operand B into t1
.LDma_LogicSbox4_Hi4_B\@:
	Dma_Sbox8 (Lut_Scratchpad + 1), \src2, Lut_Hi4, .LDma_LogicSbox4_Hi4_Mul16_B\@

	// Step 8: Multiply t1 by 16
.LDma_LogicSbox4_Hi4_Mul16_B\@:
	Dma_Sbox8 (Lut_Scratchpad + 1), (Lut_Scratchpad + 1), Lut_Mul16, .LDma_LogicSbox4_Hi_Combine\@

	// Step 9: Add t0 and t1 to get the lookup table index into the 4-bit x 4-bit LUT
.LDma_LogicSbox4_Hi_Combine\@:
	Dma_Add8  (Lut_Scratchpad + 1), (Lut_Scratchpad + 1), (Lut_Scratchpad + 0), .LDma_LogicSbox4_Hi_Lookup\@

	// Step 10: Lookup on upper 4 bits
.LDma_LogicSbox4_Hi_Lookup\@:
2:
	Dma_Sbox8 (Lut_Scratchpad + 1), (Lut_Scratchpad + 1), \table, .LDma_LogicSbox4_Hi_Shift\@

	// Step 11: Shift lookup result for higer bits by 4 bits
 .LDma_LogicSbox4_Hi_Shift\@:
	Dma_Sbox8 (Lut_Scratchpad + 1), (Lut_Scratchpad + 1), Lut_Mul16, .LDma_LogicSbox4_Result\@

	// Step 12: Assemble the result, then link to writeback
.LDma_LogicSbox4_Result\@:
	Dma_Add8 \dst, (Lut_Scratchpad + 1), (Lut_Scratchpad + 2), \lli
	.endm

	/**
	 * 8-bit arbitrary logic function (AND/OR/XOR) with 2 inputs.
	 *
	 * This operation is a variant of Dma_LogicSbox4, which indirecly fetches
	 * the pointer to the logic lookup table. It can be used to factor-out the
	 * logic operations into a reusable descriptor chain.
	 *
	 * See Dma_LogicSbox4 for details on the operation.
	 *
	 * C model:
	 *   void Dma_LogicSbox4_Indirect(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, const uint8_t *const *pointer_to_table)
	 *   {
	 *      const uint8_t *table = *pointer_to_table ;
	 *      Dma_LogicSbox4(dst, src1, src2, pointer_to_table)
	 *   }
	 *
	 * Constraints:
	 *   This operation uses Lut_Scratchpad for processing
	 *   This macro defines local labels "1" and "2" to enable seamless interaction with Dma_LogicSbox4
	 */
	.macro Dma_LogicSbox4_Indirect dst, src1, src2, pointer_to_table, lli

	// Step 1: Patch the first source lookup location (Dma_Logic_Sbox4 annotates the patch location with local label "1")
	Dma_Sbox8_PatchTableImm 1f, \pointer_to_table, .LDma_LogicSbox4_Indirect_PatchHi\@

	// Step 2: Patch the second source lookup location and link (Dma_Logic_Sbox4 annotates the patch location with local label "2")
.LDma_LogicSbox4_Indirect_PatchHi\@:
	Dma_Sbox8_PatchTableImm 2f, \pointer_to_table, .LDma_LogicSbox4_Indirect_Exec\@

	// Step 3: Implement the Dma_LogicSbox4 chain
.LDma_LogicSbox4_Indirect_Exec\@:
	Dma_LogicSbox4 \dst, \src1, \src2, (0xBADC0DE0), \lli
	.endm

	/**
	 * Bitwise AND (Lower Nibble)
	 *
	 * C model:
	 *   uint8_t BitAnd(uint8_t a, uint8_t b)
	 *   {
	 *     return (a & b) & 0x0F;
	 *   }
	 */
	Lut_Begin BitAnd

	.set .L_i, 0
	.rept 256

	.set .L_a, (.L_i & 0x0F)
	.set .L_b, ((.L_i >> 4) & 0x0F)

	.byte (.L_a & .L_b)

	.set .L_i, .L_i + 1
	.endr
	Lut_End BitAnd

	/**
	 * Bitwise OR (Lower Nibble)
	 *
	 * C model:
	 *   uint8_t BitOr(uint8_t a, uint8_t b)
	 *   {
	 *     return (a | b) & 0x0F;
	 *   }
	 */
	Lut_Begin BitOr

	.set .L_i, 0
	.rept 256

	.set .L_a, (.L_i & 0x0F)
	.set .L_b, ((.L_i >> 4) & 0x0F)

	.byte (.L_a | .L_b)

	.set .L_i, .L_i + 1
	.endr
	Lut_End BitOr

	/**
	 * Bitwise XOR (Lower Nibble)
	 *
	 * C model:
	 *   uint8_t BitEor(uint8_t a, uint8_t b)
	 *   {
	 *     return (a ^ b) & 0x0F;
	 *   }
	 */
	Lut_Begin BitEor

	.set .L_i, 0
	.rept 256

	.set .L_a, (.L_i & 0x0F)
	.set .L_b, ((.L_i >> 4) & 0x0F)

	.byte (.L_a ^ .L_b)

	.set .L_i, .L_i + 1
	.endr
	Lut_End BitEor

	/**
	 * Identity lookup and carry generation.
	 *
	 * NOTE: The carry and the identity LUT are (currently) handled in a special way
	 * (alignment on 64k boundary) - is this still applicable?
	 */
	Lut_Begin Identity, align=16

	/* Identity Lookup Table (primary and secondary copy) */
	.set  .L_i, 0
	.rept 512

	.byte (.L_i & 0xFF)

	.set .L_i, .L_i + 1
	.endr

	/* Carry Lookup Table */
Lut_Carry:
	.set  .L_i, 0
	.rept 512

	.byte (.L_i >> 8) & 0x1

	.set .L_i, .L_i + 1
	.endr
	Lut_End Identity
