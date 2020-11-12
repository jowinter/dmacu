	/**
	 * Generic DMACU Implementation for the ARM PL080 DMA Controller.
	 *
	 * Copyright (c) 2019 Johannes Winter
	 *
	 * This file is licensed under the MIT License. See LICENSE in the root directory
	 * of the prohect for the license text.
	 */

	/* Emit a DMA descriptor for a byte copy operation */
	.macro Dma_ByteCopy dst, src, size, lli
	.long (\src)
	.long (\dst)
	.long (\lli)
	.long (0x0C000000 + \size)
	.endm

	/* Patch srcaddr[7:0] of the descriptor given by dst */
	.macro Dma_PatchSrcLo8 dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 1, \lli
	.endm

	/* Patch srcaddr[15:8] of the descriptor given by dst */
	.macro Dma_PatchSrcHi8 dst, src, lli
	Dma_ByteCopy (\dst+1), (\src), 1, \lli
	.endm

	/* Patch srcaddr[15:0] of the descriptor given by dst */
	.macro Dma_PatchSrcLo16 dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 2, \lli
	.endm

	/* Patch srcaddr[31:16] of the descriptor given by dst */
	.macro Dma_PatchSrcHi16 dst, src, lli
	Dma_ByteCopy (\dst+2), (\src), 2, \lli
	.endm

	/* Patch dstaddr[7:0] of the descriptor given by dst */
	.macro Dma_PatchDstLo8 dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 1, \lli
	.endm

	/* Patch dstaddr[15:0] of the descriptor given by dst */
	.macro Dma_PatchDstHi8 dst, src, lli
	Dma_ByteCopy (\dst+5), (\src), 1, \lli
	.endm

	/* Patch dstaddr[15:0] of the descriptor given by dst */
	.macro Dma_PatchDstLo16 dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 2, \lli
	.endm

	/* Patch dstaddr[31:16] of the descriptor given by dst */
	.macro Dma_PatchDstHi16 dst, src, lli
	Dma_ByteCopy (\dst+6), (\src), 2, \lli
	.endm

	/*
	 * Substitute a byte from src via the given sbox and store the result in dst
	 *
	 * Constraints:
	 *   sbox must be aligned to a 256-byte boundary for proper operation.
	 */
	.macro Dma_Sbox8 dst, src, sbox, lli
	// Step 1: Load the source byte from src and substitute it into the sbox address
	Dma_PatchSrcLo8 LDma_Sbox8_Lookup\@, \src, LDma_Sbox8_Lookup\@

	// Step 2: Read the byte from the (patched) sbox location and store to dst
LDma_Sbox8_Lookup\@:
	Dma_ByteCopy    \dst, \sbox, 1, \lli
	.endm

	/*
	 * Add two bytes from memory operands src1 and src2 and store the result in dst.
	 *
	 * This operation uses Lut_Temporary for processing
	 */
	.macro Dma_Add8 dst, src1, src2, lli
	// Step 1: Load source byte from src1 and patch it into the source address for loading the temporary LUT
	Dma_PatchSrcLo8 LDma_Add8_LoadTempLut\@, \src1, LDma_Add8_LoadTempLut\@

	// Step 2: Load the temporary LUT with with the identity LUT (offset by src1 memory operand)
LDma_Add8_LoadTempLut\@:
	Dma_ByteCopy    Lut_Temporary, Lut_Identity, 0x100, LDma_Add8_LookupSum\@

	// Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand)
LDma_Add8_LookupSum\@:
	Dma_Sbox8       \dst, \src2, Lut_Temporary, \lli
	.endm

	/*
	 * Add 8-bit immediate imm8 to byte at memory operand src1 and store the result in dst.
	 *
	 * This operation uses Lut_Temporary for processing
	 */
	.macro Dma_Add8Imm dst, src1, imm8, lli
	// Step 1: Load the temporary LUT with with the identity LUT offset by imm8 operand
	Dma_ByteCopy    Lut_Temporary, (Lut_Identity + \imm8), 0x100, LDma_Add8Imm_LookupSum\@

	// Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand)
LDma_Add8Imm_LookupSum\@:
	Dma_Sbox8       \dst, \src1, Lut_Temporary, \lli
	.endm

	/*
	 * Add 8-bit immediate imm8 to byte at memory operand src1 and store the carry of the addition in dst.
	 *
	 * This operation uses Lut_Temporary for processing
	 */
	.macro Dma_CarryFromAdd8Imm dst, src1, imm8, lli
	// Step 1: Load the temporary LUT with with the carry LUT offset by imm8 operand
	Dma_ByteCopy    Lut_Temporary, (Lut_Carry + \imm8), 0x100, LDma_CarryFromAdd8Imm_LookupCarry\@

	// Step 2: Lookup the carry using the temporary LUT (indexed by src2 memory operand)
LDma_CarryFromAdd8Imm_LookupCarry\@:
	Dma_Sbox8       \dst, \src1, Lut_Temporary, \lli
	.endm

	/*
	 * Add two 8-bit memory operands src1 and src2 and store the carry of the addition in dst.
	 *
	 * This operation uses Lut_Temporary for processing
	 */
	.macro Dma_CarryFromAdd8 dst, src1, src2, lli
	// Step 1: Patch the source address of the of the carry LUT copy operation
	Dma_PatchSrcLo8 LDma_CarryFromAdd8_LoadTempLut\@, \src1, LDma_CarryFromAdd8_LoadTempLut\@

	// Step 2: Load the temporary LUT with with the carry LUT offset by imm8 operand
LDma_CarryFromAdd8_LoadTempLut\@:
	Dma_ByteCopy    Lut_Temporary, Lut_Carry, 0x100, LDma_CarryFromAdd8_LookupCarry\@

	// Step 3: Lookup the carry using the temporary LUT (indexed by src2 memory operand)
LDma_CarryFromAdd8_LookupCarry\@:
	Dma_Sbox8       \dst, \src2, Lut_Temporary, \lli
	.endm

	/*
	 * Subtract 8-bit immediate imm8 from byte at memory operand src1 and store the result in dst.
	 *
	 * This operation uses Lut_Temporary for processing
	 */
	.macro Dma_Sub8Imm dst, src1, imm8, lli
	// Step 1: Load the temporary LUT with with the identity LUT (2nd copy) offset by imm8 operand
	Dma_ByteCopy    Lut_Temporary, (Lut_Identity2 - \imm8), 0x100, LDma_Sub8Imm_LookupSum\@

	// Step 3: Lookup the sum using the temporary LUT (indexed by src2 memory operand)
LDma_Sub8Imm_LookupSum\@:
	Dma_Sbox8       \dst, \src1, Lut_Temporary, \lli
	.endm

	/*
	 * Add 8-bit immediate imm8 to 16-bit value (little endian) at memory operand src1 and store the result in dst1
	 *
	 * This operation uses Lut_Temporary and Cpu_Scratchpad for processing
	 */
	.macro Dma_Add16Imm dst, src1, imm8, lli
	// Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the
	//   immediate of the upper part of the addition
	Dma_CarryFromAdd8Imm Cpu_Scratchpad, \src1, \imm8, LDma_Add16Imm_AddLo8\@

	// Step 2: Perform the 8-bit addition in the lower byte
LDma_Add16Imm_AddLo8\@:
	Dma_Add8Imm (\dst + 0), (\src1 + 0), \imm8, LDma_Add16Imm_AddHi8\@

	// Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value)
LDma_Add16Imm_AddHi8\@:
	Dma_Add8    (\dst + 1), (\src1 + 1), Cpu_Scratchpad, \lli
	.endm

	/*
	 * Indirect lookup (switch) with up to 64 entries.
	 */
	.macro Dma_TableSwitch64 dst, src, table, lli
	// Step 1: Patch the lookup address in the switch table
LDma_TableSwitch_PrepareLookup\@:
	Dma_Sbox8 (LDma_TableSwitch_DoLookup\@ + 0), \src, Lut_TableSwitch64, LDma_TableSwitch_DoLookup\@

	// Step 2: Read a 4-byte value from the table.
LDma_TableSwitch_DoLookup\@:
	Dma_ByteCopy \dst, \table, 4, \lli
	.endm

	/**
	 * Workspace (bss-like)
	 */
	.section ".bss", "aw", "nobits"

	// Temporary LUT / scratchpad memory
	.align 8
Lut_Temporary:
	.space 0x100, 0x00

	// Register file (240x 8-bit, last 16 bytes are used by Cpu_PC and Cpu_NextPC)
	.global Cpu_Regfile
Cpu_Regfile:
	.space 0x100, 0x00

	// Guard Zone (catches off by one writes, e.g. if MOV2 is made to r255)
	.long 0

	// Current program counter
	.global Cpu_PC
Cpu_PC:
	.long 0

	// Next program counter
	.global Cpu_NextPC
Cpu_NextPC:
	.long 0

	// Current instruction word
	.global Cpu_CurrentOPC
Cpu_CurrentOPC:
	.long 0

	// Current A operand value
	.global Cpu_CurrentA
Cpu_CurrentA:
	.short 0

	// Current B operand value
	.global Cpu_CurrentB
Cpu_CurrentB:
	.short 0

	// Current Z result value
	.global Cpu_CurrentZ
Cpu_CurrentZ:
	.long 0

	// Scratchpad for temporary values
Cpu_Scratchpad:
	.long 0

	/**
	 * S-Boxes / Lookup-Tables
	 *
	 * TODO: Check whether we can reduce table sizes here (at cost of higher execution time) by using a
	 * double-sized temp LUT (and by doing an in-place copy in the temp lut)
	 */
	.section ".rodata", "a", "progbits"
	.align 16
Lut_Identity:
	/* Identity lookup table */
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
	.byte 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f
	.byte 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f
	.byte 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f
	.byte 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f
	.byte 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f
	.byte 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f
	.byte 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f
	.byte 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf
	.byte 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf
	.byte 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf
	.byte 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf
	.byte 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef
	.byte 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff

	/* Identity lookup table (second copy) */
Lut_Identity2:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
	.byte 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f
	.byte 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f
	.byte 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f
	.byte 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f
	.byte 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f
	.byte 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f
	.byte 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f
	.byte 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf
	.byte 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf
	.byte 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf
	.byte 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf
	.byte 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef
	.byte 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff

	/*
	 * Carry LUT
	 */
Lut_Carry:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01

	/*
	 * Lookup table for bitwise complement (1's complement)
	 */
Lut_BitNot:
	.byte 0xff, 0xfe, 0xfd, 0xfc, 0xfb, 0xfa, 0xf9, 0xf8, 0xf7, 0xf6, 0xf5, 0xf4, 0xf3, 0xf2, 0xf1, 0xf0
	.byte 0xef, 0xee, 0xed, 0xec, 0xeb, 0xea, 0xe9, 0xe8, 0xe7, 0xe6, 0xe5, 0xe4, 0xe3, 0xe2, 0xe1, 0xe0
	.byte 0xdf, 0xde, 0xdd, 0xdc, 0xdb, 0xda, 0xd9, 0xd8, 0xd7, 0xd6, 0xd5, 0xd4, 0xd3, 0xd2, 0xd1, 0xd0
	.byte 0xcf, 0xce, 0xcd, 0xcc, 0xcb, 0xca, 0xc9, 0xc8, 0xc7, 0xc6, 0xc5, 0xc4, 0xc3, 0xc2, 0xc1, 0xc0
	.byte 0xbf, 0xbe, 0xbd, 0xbc, 0xbb, 0xba, 0xb9, 0xb8, 0xb7, 0xb6, 0xb5, 0xb4, 0xb3, 0xb2, 0xb1, 0xb0
	.byte 0xaf, 0xae, 0xad, 0xac, 0xab, 0xaa, 0xa9, 0xa8, 0xa7, 0xa6, 0xa5, 0xa4, 0xa3, 0xa2, 0xa1, 0xa0
	.byte 0x9f, 0x9e, 0x9d, 0x9c, 0x9b, 0x9a, 0x99, 0x98, 0x97, 0x96, 0x95, 0x94, 0x93, 0x92, 0x91, 0x90
	.byte 0x8f, 0x8e, 0x8d, 0x8c, 0x8b, 0x8a, 0x89, 0x88, 0x87, 0x86, 0x85, 0x84, 0x83, 0x82, 0x81, 0x80
	.byte 0x7f, 0x7e, 0x7d, 0x7c, 0x7b, 0x7a, 0x79, 0x78, 0x77, 0x76, 0x75, 0x74, 0x73, 0x72, 0x71, 0x70
	.byte 0x6f, 0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x69, 0x68, 0x67, 0x66, 0x65, 0x64, 0x63, 0x62, 0x61, 0x60
	.byte 0x5f, 0x5e, 0x5d, 0x5c, 0x5b, 0x5a, 0x59, 0x58, 0x57, 0x56, 0x55, 0x54, 0x53, 0x52, 0x51, 0x50
	.byte 0x4f, 0x4e, 0x4d, 0x4c, 0x4b, 0x4a, 0x49, 0x48, 0x47, 0x46, 0x45, 0x44, 0x43, 0x42, 0x41, 0x40
	.byte 0x3f, 0x3e, 0x3d, 0x3c, 0x3b, 0x3a, 0x39, 0x38, 0x37, 0x36, 0x35, 0x34, 0x33, 0x32, 0x31, 0x30
	.byte 0x2f, 0x2e, 0x2d, 0x2c, 0x2b, 0x2a, 0x29, 0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x20
	.byte 0x1f, 0x1e, 0x1d, 0x1c, 0x1b, 0x1a, 0x19, 0x18, 0x17, 0x16, 0x15, 0x14, 0x13, 0x12, 0x11, 0x10
	.byte 0x0f, 0x0e, 0x0d, 0x0c, 0x0b, 0x0a, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x00

	/*
	 * Switch-table address generator for up to 64 entries
	 */
	.align 8
Lut_TableSwitch64:
	.byte 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C, 0x20, 0x24, 0x28, 0x2C, 0x30, 0x34, 0x38, 0x3C
	.byte 0x40, 0x44, 0x48, 0x4C, 0x50, 0x54, 0x58, 0x5C, 0x60, 0x64, 0x68, 0x6C, 0x70, 0x74, 0x78, 0x7C
	.byte 0x80, 0x84, 0x88, 0x8C, 0x90, 0x94, 0x98, 0x9C, 0xA0, 0xA4, 0xA8, 0xAC, 0xB0, 0xB4, 0xB8, 0xBC
	.byte 0xC0, 0xC4, 0xC8, 0xCC, 0xD0, 0xD4, 0xD8, 0xDC, 0xE0, 0xE4, 0xE8, 0xEC, 0xF0, 0xF4, 0xF8, 0xFC

	/* RFU space */
Lit_5A: .byte 0x5A
Lit_A5: .byte 0xA5

	/*
	 * Instruction set decode table
	 */
	.align 8
Lut_InstructionTable:
	.long Cpu_OpNop       // 0x00 - NOP                                             (No-operation)
	.long Cpu_OpMovImm    // 0x01 - MOV rZ, #imm8                                   (Move from 8-bit immediate to register pair)
	.long Cpu_OpMov2Imm   // 0x02 - MOV rZ+1:rZ, #imm16                             (Move from 16-bit immediate to register pair)
	.long Cpu_OpMov2Reg   // 0x03 - MOV rZ+1:rZ, rB:rA                              (Move from register pair to register pair)
	.long Cpu_OpAddImm8   // 0x04 - ADD rZ, rB, #imm8                               (Add 8-bit immediate)
	.long Cpu_OpAcyImm8   // 0x05 - ACY rZ, rB, #imm8                               (Generate carry from add with 8-bit immediate)
	.long Cpu_OpAddReg    // 0x06 - ADD rZ, rB, rA                                  (Add 8-bit registers)
	.long Cpu_OpAcyReg    // 0x07 - ACY rZ, rB, rA                                  (Generate carry from add with 8-bit registers)
	.long Cpu_OpUndef     // 0x08 - (RFU) JMP #imm24                                (Jump absolute)
	.long Cpu_OpUndef     // 0x09 - (RFU) JMP rB:rA+1:rA                            (Jump register indirect)
	.long Cpu_OpUndef     // 0x0A - (RFU) SNE rZ, rB                                (Skip if not equal)
	.long Cpu_OpUndef     // 0x0B - (RFU) SEQ rZ, rB                                (Skip if equal)
	.long Cpu_OpUndef     // 0x0C - (RFU) SNE rZ, #imm8                             (Skip if not equal immediate)
	.long Cpu_OpUndef     // 0x0D - (RFU) SEQ rZ, #imm8                             (Skip if equal immediate)
	.long Cpu_OpBitNot    // 0x0E - NOT rZ, rB                                      (Bitwise NOT)
	.long Cpu_OpUndef     // 0x0F - (RFU) AND rZ, rB, rA                            (Bitwise AND)
	.long Cpu_OpUndef     // 0x10 - (RFU) OR  rZ, rB, rA                            (Bitwise OR)
	.long Cpu_OpUndef     // 0x11 - (RFU) EOR rZ, rB, rA                            (Bitwise Exclusive-OR)
	.long Cpu_OpUndef     // 0x12 - (RFU) ROR rZ, zB, #1                            (Rotate-Right by 1)
	.long Cpu_OpUndef     // 0x13 - (RFU) ROL rZ, zB, #1                            (Rotate-Left by 1)
	.long Cpu_OpUndef     // 0x14 - Undefined
	.long Cpu_OpUndef     // 0x15 - Undefined
	.long Cpu_OpUndef     // 0x16 - Undefined
	.long Cpu_OpUndef     // 0x17 - Undefined
	.long Cpu_OpUndef     // 0x18 - Undefined
	.long Cpu_OpLoadByte  // 0x19 - LDB rZ, [rB+1:rB:rA+1:rA]                 (Load byte indirect)
	.long Cpu_OpStoreByte // 0x1A - STB rZ, [rB+1:rB:rA+1:rA]                 (Store byte indirect)
	.long Cpu_OpLoadHalf  // 0x1B - LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Load half-word indirect)
	.long Cpu_OpStoreHalf // 0x1C - STH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Store half-word indirect)
	.long Cpu_OpLoadWord  // 0x1D - LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Load word indirect)
	.long Cpu_OpStoreWord // 0x1E - STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Store word indirect)
	.long Cpu_OpUndef     // 0x1F - UND #imm24

	/**********************************************************************************************
	 *
	 * DMACU CPU Fetch/Decode/Execute/Writeback Stages
	 *
	 **********************************************************************************************/
	.section ".data", "aw", "progbits"

	/**********************************************************************************************
	 *
	 * DMACU CPU Fetch Stage
	 *
	 **********************************************************************************************/
Cpu_Fetch.1:
	// FE.1: Setup source address for instruction fetch
	Dma_ByteCopy (Cpu_Fetch.2 + 0), Cpu_PC, 4, Cpu_Fetch.2

	// FE.2: Fetch current instruction into opcode buffer
Cpu_Fetch.2:
	Dma_ByteCopy Cpu_CurrentOPC, 0, 4, Cpu_Fetch.3

	// FE.3: Generate lower 16 bit of next program counter
Cpu_Fetch.3:
	Dma_Add16Imm Cpu_NextPC, Cpu_PC, 4, Cpu_Fetch.4

	// FE.4: Copy upper 16 bit of program counter then link to decode stage
Cpu_Fetch.4:
	Dma_ByteCopy (Cpu_NextPC + 2), (Cpu_PC + 2), 2, Cpu_Decode.1

	/**********************************************************************************************
	 *
	 * DMACU CPU Decode Stage
	 *
	 **********************************************************************************************/
Cpu_Decode.1:
	// DE.1: Generate the LLI address to the opcode (via tableswitch on opcode)
	//  Major opcode is in CurrentOPC[31:24]
	//
	Dma_TableSwitch64 (Cpu_Decode.8 + 8), (Cpu_CurrentOPC + 3), Lut_InstructionTable, Cpu_Decode.2

	// DE.2: Clear the current A and B operand values (use start of Lut_Carry as zero source)
Cpu_Decode.2:
	Dma_ByteCopy (Cpu_CurrentA + 0), Lut_Carry, 6, Cpu_Decode.3

	// DE.3: Prepare loading the A operand from Regfile[CurrentOPC[15:8]] (rA)
Cpu_Decode.3:
	Dma_PatchSrcLo8 Cpu_Decode.4, (Cpu_CurrentOPC + 0), Cpu_Decode.4

	// DE.4: Load the A operand from Regfile[CurrentOPC[15:8]] (rA)
	//
	// NOTE: We always load rA+1:rA
Cpu_Decode.4:
	Dma_ByteCopy Cpu_CurrentA, Cpu_Regfile, 2, Cpu_Decode.5

	// DE.5: Prepare loading the B operand from Regfile[CurrentOPC[ 7:0]] (rB)
Cpu_Decode.5:
	Dma_PatchSrcLo8 Cpu_Decode.6, (Cpu_CurrentOPC + 1), Cpu_Decode.6

	// DE.6: Load the B operand from Regfile[CurrentOPC[ 7:0]] (rB)
	//
	// NOTE: We always load rB+1:rB
Cpu_Decode.6:
	Dma_ByteCopy Cpu_CurrentB, Cpu_Regfile, 2, Cpu_Decode.7

	// DE.7: Prepare loading the Z operand from Regfile[CurrentOPC[23:16]] (rZ)
Cpu_Decode.7:
	Dma_PatchSrcLo8 Cpu_Decode.8, (Cpu_CurrentOPC + 2), Cpu_Decode.8

	// DE.8: Load the Z operand from Regfile[CurrentOPC[23:16]] (rB)
	//   Then dispatch to the execute stage (LLI patched by Cpu_Decode.1)
	//
	// NOTE: We always load rZ+3:rZ+2:rZ+1:rZ+0
Cpu_Decode.8:
	Dma_ByteCopy Cpu_CurrentZ, Cpu_Regfile, 4, Cpu_OpUndef


	/**********************************************************************************************
	 *
	 * DMACU CPU Writeback Stage
	 *
	 **********************************************************************************************/

Cpu_Writeback.FourRegs:
	// WB.FOUR.1: Setup copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
	Dma_PatchDstLo8 Cpu_Writeback.FourRegs.Commit, (Cpu_CurrentOPC + 2), Cpu_Writeback.FourRegs.Commit

Cpu_Writeback.FourRegs.Commit:
	// WB.FOUR.2: Do copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 4, Cpu_Writeback.PC


Cpu_Writeback.TwoRegs:
	// WB.TWO.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
	Dma_PatchDstLo8 Cpu_Writeback.TwoRegs.Commit, (Cpu_CurrentOPC + 2), Cpu_Writeback.TwoRegs.Commit

Cpu_Writeback.TwoRegs.Commit:
	// WB.TWO.2: Do copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 2, Cpu_Writeback.PC

Cpu_Writeback.OneReg:
	// WB.ONE.1: Setup copy from CurrentZ[7:0] to Regfile[rZ]
	Dma_PatchDstLo8 Cpu_Writeback.OneReg.Commit, (Cpu_CurrentOPC + 2), Cpu_Writeback.OneReg.Commit

Cpu_Writeback.OneReg.Commit:
	// WB.ONE.2: Do copy from CurrentZ[7:0] to Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 1, Cpu_Writeback.PC

Cpu_Writeback.PC:
	// WB.PC: Copy NextPC to PC, link to fetch stage
	Dma_ByteCopy Cpu_PC, Cpu_NextPC, 4, Cpu_Fetch.1

	/**********************************************************************************************
	 *
	 * DMACU CPU Opcodes (Execute Stage)
	 *
	 **********************************************************************************************/

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
	.set Cpu_OpNop, Cpu_Writeback.PC

	/*
	 * MOV rZ, #imm8 - Move to register from 8-bit immediate
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x01 | (0)  | (0)  | imm8 |
	 * +------+------+------+------+
	 */
Cpu_OpMovImm:
	// Copy from CurrentOPC[7:0] to CurrentZ, then link to one register writeback
	Dma_ByteCopy Cpu_CurrentZ, (Cpu_CurrentOPC + 0), 1, Cpu_Writeback.OneReg

	/*
	 * MOV rZ+1:rZ, #imm16 - Move to register pair from 16-bit immediate
	 *
	 *  31  24     16             0
	 * +------+------+-------------+
	 * | 0x02 | rZ   |       imm16 |
	 * +------+------+-------------+
	 */
Cpu_OpMov2Imm:
	// Copy from CurrentOPC[15:0] to CurrentZ, then link to one register writeback
	Dma_ByteCopy Cpu_CurrentZ, (Cpu_CurrentOPC + 0), 2, Cpu_Writeback.TwoRegs

	/*
	 * MOV2 rZ+1:rZ, rB:rA - Move from register pair to register pair
	 * MOV  rZ, rA         - (Pseudo-Instruction) Move from register to register (if rB=rZ+1)
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x03 |  rZ  | rB   |  rA  |
	 * +------+------+------+------+
	 */
Cpu_OpMov2Reg:
	// Copy from CurrentA to CurrentZ{7:0]
	Dma_ByteCopy (Cpu_CurrentZ + 0), Cpu_CurrentA, 1, Cpu_OpMov2Reg.WriteSecondReg

	// Copy from CurrentB to CurrentZ[15:8]
Cpu_OpMov2Reg.WriteSecondReg:
	Dma_ByteCopy (Cpu_CurrentZ + 1), Cpu_CurrentB, 1, Cpu_Writeback.TwoRegs

	/*
	 * ADD rZ, rB, #imm8               - Add register and 8-bit immediate
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x04 |  rZ  | rB   | imm8 |
	 * +------+------+------+------+
	 */
Cpu_OpAddImm8:
	// Add the 8-bit immediate (from instruction word [7:0]) to rB, store result in rZ
	Dma_Add8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentOPC + 0), Cpu_Writeback.OneReg

	/*
	 * ACY rZ, rB, #imm8               - Generate carry from add with 8-bit immediate
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x05 |  rZ  | rB   | imm8 |
	 * +------+------+------+------+
	 */
Cpu_OpAcyImm8:
	// Generate the carry from rB+imm8, store in rZ
	Dma_CarryFromAdd8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentOPC + 0), Cpu_Writeback.OneReg

	/*
	 * ADD rZ, rB, rA                  - Add two registers
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x06 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpAddReg:
	// Add  rA and rB, store result in rZ
	Dma_Add8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentA + 0), Cpu_Writeback.OneReg

	/*
	 * ACY rZ, rB, rA                 - Generate carry from add with 8-bit registers
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x07 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpAcyReg:
	// Generate the carry from rA+rB, store in rZ
	Dma_CarryFromAdd8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentA + 0), Cpu_Writeback.OneReg

	/*
	 * NOT rZ, rB                      - Bitwise NOT
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x0E |  rZ  | rB   | (0)  |
	 * +------+------+------+------+
	*/
Cpu_OpBitNot:
	// Lookup via bitwise NOT table
	Dma_Sbox8 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), Lut_BitNot, Cpu_Writeback.OneReg

	/*
	 * LDB rZ, [rB+1:rB:rA+1:rA]        - Load byte indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x19 |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpLoadByte:
	Dma_PatchSrcLo16 (Cpu_OpLoadByte.Load), (Cpu_CurrentA + 0), Cpu_OpLoadByte.AdrHi
Cpu_OpLoadByte.AdrHi:
	Dma_PatchSrcHi16 (Cpu_OpLoadByte.Load), (Cpu_CurrentB + 0), Cpu_OpLoadByte.Load
Cpu_OpLoadByte.Load:
	Dma_ByteCopy     (Cpu_CurrentZ + 0), 0, 1, Cpu_Writeback.OneReg

	/*
	 * LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load half-word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1B |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpLoadHalf:
	Dma_PatchSrcLo16 (Cpu_OpLoadHalf.Load), (Cpu_CurrentA + 0), Cpu_OpLoadHalf.AdrHi
Cpu_OpLoadHalf.AdrHi:
	Dma_PatchSrcHi16 (Cpu_OpLoadHalf.Load), (Cpu_CurrentB + 0), Cpu_OpLoadHalf.Load
Cpu_OpLoadHalf.Load:
	Dma_ByteCopy     (Cpu_CurrentZ + 0), 0, 2, Cpu_Writeback.TwoRegs

	/*
	 * LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1D |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpLoadWord:
	Dma_PatchSrcLo16 (Cpu_OpLoadWord.Load), (Cpu_CurrentA + 0), Cpu_OpLoadWord.AdrHi
Cpu_OpLoadWord.AdrHi:
	Dma_PatchSrcHi16 (Cpu_OpLoadWord.Load), (Cpu_CurrentB + 0), Cpu_OpLoadWord.Load
Cpu_OpLoadWord.Load:
	Dma_ByteCopy     (Cpu_CurrentZ + 0), 0, 4, Cpu_Writeback.FourRegs

	/*
	 * STB rZ, [rB+1:rB:rA+1:rA]        - Store byte indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1A |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpStoreByte:
	Dma_PatchDstLo16 (Cpu_OpStoreByte.Store), (Cpu_CurrentA + 0), Cpu_OpStoreByte.AdrHi
Cpu_OpStoreByte.AdrHi:
	Dma_PatchDstHi16 (Cpu_OpStoreByte.Store), (Cpu_CurrentB + 0), Cpu_OpStoreByte.Store
Cpu_OpStoreByte.Store:
	Dma_ByteCopy     0, (Cpu_CurrentZ + 0), 1, Cpu_Writeback.PC

	/*
	 * STH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store half-word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1C |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpStoreHalf:
	Dma_PatchDstLo16 (Cpu_OpStoreHalf.Store), (Cpu_CurrentA + 0), Cpu_OpStoreHalf.AdrHi
Cpu_OpStoreHalf.AdrHi:
	Dma_PatchDstHi16 (Cpu_OpStoreHalf.Store), (Cpu_CurrentB + 0), Cpu_OpStoreHalf.Store
Cpu_OpStoreHalf.Store:
	Dma_ByteCopy     0, (Cpu_CurrentZ + 0), 2, Cpu_Writeback.PC

	/*
	 * STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store word indirect
	 *
	 *  31  24     16      8      0
	 * +------+------+------+------+
	 * | 0x1E |  rZ  | rB   | rA   |
	 * +------+------+------+------+
	 */
Cpu_OpStoreWord:
	Dma_PatchDstLo16 (Cpu_OpStoreWord.Store), (Cpu_CurrentA + 0), Cpu_OpStoreWord.AdrHi
Cpu_OpStoreWord.AdrHi:
	Dma_PatchDstHi16 (Cpu_OpStoreWord.Store), (Cpu_CurrentB + 0), Cpu_OpStoreWord.Store
Cpu_OpStoreWord.Store:
	Dma_ByteCopy     0, (Cpu_CurrentZ + 0), 4, Cpu_Writeback.PC

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
Cpu_OpUndef:
	// Copy the 0xDEADC0DE value to Cpu_NextPC, then halt via LLI=0
	Dma_ByteCopy Cpu_NextPC, Cpu_OpUndef.Lit_DEADCODE, 4, 0x00000000

Cpu_OpUndef.Lit_DEADCODE:
	.long 0xDEADC0DE

	/*
	 * Export the CPU entrypoint
	 *
	 * CPU processing starts at the FE.1 stage.
	 */
	.global Dma_UCode_CPU
	.set Dma_UCode_CPU, Cpu_Fetch.1
