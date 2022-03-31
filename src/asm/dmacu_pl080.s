	/**
	 * Generic DMACU Implementation for the ARM PL080 DMA Controller.
	 *
	 * Copyright (c) 2019-2020 Johannes Winter
	 *
	 * This file is licensed under the MIT License. See LICENSE in the root directory
	 * of the prohect for the license text.
	 */


	/*
	 * Enable/disable use of the Cpu_Execute_Logic dynamic sub-chain
	 *
	 * The Cpu_Execute_Logic dynamic sub-chain implements the lookup table procedure for 2-input
	 * bit-logic operations (AND/OR/EOR) as dedicated sub-chain. The table addresses are patched
	 * in dynamically.
	 *
	 * Enabling the sub-chain saves approximately 864 bytes of memory.
	 *
	 * Disabling the sub-chain causes the lookup procedure to be inlined multiple times.
	 */
#define DMACU_USE_CPU_EXECUTE_LOGIC (1)

#include "dmacu_pl080_rt.S"

	/* Emit a DMA descriptor to record the CPU state */
	.macro Dma_DbgState imm32
	 Dma_ByteCopy (Cpu_DbgState + 0), (.LDma_DbgState_Lit\@), 4, (.LDma_DbgState_Next\@)

.LDma_DbgState_Lit\@:
	.long \imm32

	.p2align 2
.LDma_DbgState_Next\@:
	.endm

	/*
	 * Add 8-bit immediate imm8 to 16-bit value (little endian) at memory operand src1 and store the result in dst1
	 *
	 * This operation uses Lut_Temporary and Cpu_Scratchpad for processing
	 */
	.macro Cpu_Add16Imm dst, src1, imm8, lli
	// Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the
	//   immediate of the upper part of the addition
	Dma_CarryFromAdd8Imm Cpu_Scratchpad, \src1, \imm8, .LCpu_Add16Imm_AddLo8\@

	// Step 2: Perform the 8-bit addition in the lower byte
.LCpu_Add16Imm_AddLo8\@:
	Dma_Add8Imm (\dst + 0), (\src1 + 0), \imm8, .LCpu_Add16Imm_AddHi8\@

	// Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value)
.LCpu_Add16Imm_AddHi8\@:
	Dma_Add8    (\dst + 1), (\src1 + 1), Cpu_Scratchpad, \lli
	.endm

	/*
	 * Adds an 8-bit value (in src2) to 16-bit value (little endian) at memory operand src1 and store the result in dst1
	 *
	 * This operation uses Lut_Temporary and Cpu_Scratchpad for processing
	 */
	.macro Cpu_Add8to16 dst, src1, src2, lli
	// Step 1: Generate the carry for the 8-bit addition in the lower byte and patch the
	//   immediate of the upper part of the addition
	Dma_CarryFromAdd8 Cpu_Scratchpad, \src1, \src2, .LCpu_Add8to16_AddLo8\@

	// Step 2: Perform the 8-bit addition in the lower byte
.LCpu_Add8to16_AddLo8\@:
	Dma_Add8    (\dst + 0), (\src1 + 0), \src2, .LCpu_Add8to16_AddHi8\@

	// Step 3: Perform the 8-bit addition in the upper byte (immediate is patched with the carry lookup value)
.LCpu_Add8to16_AddHi8\@:
	Dma_Add8    (\dst + 1), (\src1 + 1), Cpu_Scratchpad, \lli
	.endm

	/*
	 * 8-bit arbitrary logic function (AND/OR/XOR)
	 *
	 * Storing a full LUT for 8-bit inputs src1 and src2 would require 64k entries. We use a divide and conquer
	 * approach to implement 8-bit logic functions on top of 4-bit x 4-bit LUT:
	*/
	.macro Cpu_LogicSbox4 table
#if DMACU_USE_CPU_EXECUTE_LOGIC
	// Sub-chain implementation: Select the active sbox and link to the sub-chain
	Dma_ByteCopy Cpu_ActiveLogicSbox, .LCpu_LogixSbox4_Table\@, 4, Cpu_Execute_Logic

	// Mergeable reference to the table
	.pushsection ".rodata.dmacu.literal.active_logic_sbox", "aM", "progbits", 4
	.p2align 2
.LCpu_LogixSbox4_Table\@:
	.long (\table)
	.popsection

#else
	// In-place implementation
	Dma_LogicSbox4 (Cpu_CurrentZ + 0), (Cpu_CurrentB + 0), (Cpu_CurrentA + 0), \table, .LCpu_Writeback.OneReg
#endif
	.endm

	/**
	 * Workspace (bss-like)
	 */
	.section ".bss", "aw", "nobits"

	// Temporary LUT / scratchpad memory
	.p2align 8

	// Register file (240x 8-bit, last 16 bytes are used by Cpu_PC and Cpu_NextPC)
	.global Cpu_Regfile
Cpu_Regfile:
	.space 0x100, 0x00

	// Guard Zone (catches off by one writes, e.g. if MOV2 is made to r255)
	.long 0
	.type Cpu_Regfile, "object"
	.size Cpu_Regfile, . - Cpu_Regfile

	// Current program counter
	.global Cpu_PC
Cpu_PC:
	.long 0
	.type Cpu_PC, "object"
	.size Cpu_PC, . - Cpu_PC

	// Next program counter
	.global Cpu_NextPC
Cpu_NextPC:
	.long 0
	.type Cpu_NextPC, "object"
	.size Cpu_NextPC, . - Cpu_NextPC

	// Program base pointer (initial PC)
	.global Cpu_ProgramBase
Cpu_ProgramBase:
	.long 0
	.type Cpu_ProgramBase, "object"
	.size Cpu_ProgramBase, . - Cpu_ProgramBase

	// State tracker
	.global Cpu_DbgState
Cpu_DbgState:
	.long 0
	.type Cpu_DbgState, "object"
	.size Cpu_DbgState, . - Cpu_DbgState

	// Current instruction word
	.global Cpu_CurrentOPC
Cpu_CurrentOPC:
	.long 0
	.type Cpu_CurrentOPC, "object"
	.size Cpu_CurrentOPC, . - Cpu_CurrentOPC

	// Current A operand value
	.global Cpu_CurrentA
Cpu_CurrentA:
	.short 0
	.type Cpu_CurrentA, "object"
	.size Cpu_CurrentA, . - Cpu_CurrentA

	// Current B operand value
	.global Cpu_CurrentB
Cpu_CurrentB:
	.short 0
	.type Cpu_CurrentB, "object"
	.size Cpu_CurrentB, . - Cpu_CurrentB

	// Current Z result value
	.global Cpu_CurrentZ
Cpu_CurrentZ:
	.long 0
	.type Cpu_CurrentZ, "object"
	.size Cpu_CurrentZ, . - Cpu_CurrentZ

	// Scratchpad for temporary values
Cpu_Scratchpad:
	.long 0
	.type Cpu_Scratchpad, "object"
	.size Cpu_Scratchpad, . - Cpu_Scratchpad

#if DMACU_USE_CPU_EXECUTE_LOGIC
	// Shared logic pipeline is enabled. Cpu_ActiveLogicSbox points to the active SBOX
Cpu_ActiveLogicSbox:
	.long 0
	.type Cpu_ActiveLogicSbox, "object"
	.size Cpu_ActiveLogicSbox, . - Cpu_ActiveLogicSbox
#endif

	/**
	 * S-Boxes / Lookup-Tables
	 *
	 * TODO: Check whether we can reduce table sizes here (at cost of higher execution time) by using a
	 * double-sized temp LUT (and by doing an in-place copy in the temp lut)
	 */
	.section ".rodata", "a", "progbits"

	/* RFU space */
Lit_5A:
	.byte 0x5A
	.type Lit_5A, "object"
	.size Lit_5A, . - Lit_5A

Lit_A5:
	.byte 0xA5
	.type Lit_A5, "object"
	.size Lit_A5, . - Lit_A5

Lit_00:
	.byte 0x00
	.type Lit_00, "object"
	.size Lit_00, . - Lit_00

Lit_04:
	.byte 0x04
	.type Lit_04, "object"
	.size Lit_04, . - Lit_04

	/*
	 * Instruction set decode table
	 */
	.p2align 8
Lut_InstructionTable:
	.long Cpu_OpNop       // 0x00 - NOP                                       (No-operation)
	.long Cpu_OpMovImm    // 0x01 - MOV rZ, #imm8                             (Move from 8-bit immediate to register pair)
	.long Cpu_OpMov2Imm   // 0x02 - MOV rZ+1:rZ, #imm16                       (Move from 16-bit immediate to register pair)
	.long Cpu_OpMov2Reg   // 0x03 - MOV rZ+1:rZ, rB:rA                        (Move from register pair to register pair)
	.long Cpu_OpAddImm8   // 0x04 - ADD rZ, rB, #imm8                         (Add 8-bit immediate)
	.long Cpu_OpAcyImm8   // 0x05 - ACY rZ, rB, #imm8                         (Generate carry from add with 8-bit immediate)
	.long Cpu_OpAddReg    // 0x06 - ADD rZ, rB, rA                            (Add 8-bit registers)
	.long Cpu_OpAcyReg    // 0x07 - ACY rZ, rB, rA                            (Generate carry from add with 8-bit registers)
	.long Cpu_OpJmpImm16  // 0x08 - JMP #imm16                                (Jump absolute)
	.long Cpu_OpJmpReg16  // 0x09 - JMP rB:rA                                 (Jump register indirect)
	.long Cpu_OpBrNeReg   // 0x0A - BNE (+off8) rZ, rB                        (Branch if not equal)
	.long Cpu_OpBrEqReg   // 0x0B - BEQ (+off8) rZ, rB                        (Branch if equal)
	.long Cpu_OpBrNeImm   // 0x0C - BNE (+off8) rZ, #imm8                     (Branch if not equal immediate)
	.long Cpu_OpBrEqImm   // 0x0D - BEQ (+off8) rZ, #imm8                     (Branch if equal immediate)
	.long Cpu_OpBitNot    // 0x0E - NOT rZ, rB                                (Bitwise NOT)
	.long Cpu_OpBitAnd    // 0x0F - AND rZ, rB, rA                            (Bitwise AND)
	.long Cpu_OpBitOr     // 0x10 - OR  rZ, rB, rA                            (Bitwise OR)
	.long Cpu_OpBitEor    // 0x11 - EOR rZ, rB, rA                            (Bitwise Exclusive-OR)
	.long Cpu_OpRor       // 0x12 - ROR rZ, zB, #1                            (Rotate-Right by 1)
	.long Cpu_OpRol       // 0x13 - ROL rZ, zB, #1                            (Rotate-Left by 1)
	.long Cpu_OpLo4       // 0x14 - LO4 rZ, rB                                (Extract lower 4 bits)
	.long Cpu_OpHi4       // 0x15 - HI4 rZ, rB                                (Insert upper 4 bits)
	.long Cpu_OpShl4      // 0x16 - SHL rZ, rB, #4                            (Shift left by 4 / multiply by 16)
	.long Cpu_OpJal       // 0x17 - JAL rZ+1:rZ, #imm16                       (Jump and Link)
	.long Cpu_OpLit32     // 0x18 - LIT32 (+off16) rZ+3:rZ+2:rZ+1:rZ          (Load 32-bit literal from a PC relative offset)
	.long Cpu_OpLoadByte  // 0x19 - LDB rZ, [rB+1:rB:rA+1:rA]                 (Load byte indirect)
	.long Cpu_OpStoreByte // 0x1A - STB rZ, [rB+1:rB:rA+1:rA]                 (Store byte indirect)
	.long Cpu_OpLoadHalf  // 0x1B - LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Load half-word indirect)
	.long Cpu_OpStoreHalf // 0x1C - STH rZ+1:rZ, [rB+1:rB:rA+1:rA]            (Store half-word indirect)
	.long Cpu_OpLoadWord  // 0x1D - LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Load word indirect)
	.long Cpu_OpStoreWord // 0x1E - STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]  (Store word indirect)
	.long Cpu_OpUndef     // 0x1F - UND #imm24

	.type Lut_InstructionTable, "object"
	.size Lut_InstructionTable, . - Lut_InstructionTable

	/**********************************************************************************************
	 *
	 * DMACU CPU Fetch/Decode/Execute/Writeback Stages
	 *
	**********************************************************************************************/

	// Start of CPU stage
	.macro Cpu_Stage_Begin name
	.pushsection ".data.Cpu_\name", "aw", "progbits"
	.p2align 2
Cpu_\name:
	.endm

	// End of a CPU stage
	.macro Cpu_Stage_End name
	.type Cpu_\name, "object"
	.size Cpu_\name, . - Cpu_\name
	.popsection
	.endm

	.section ".data", "aw", "progbits"

	/**********************************************************************************************
	 *
	 * DMACU CPU Reset
	 *
	 **********************************************************************************************/
Cpu_Stage_Begin Reset
.LCpu_Reset.1:
	// RST.1: Log entry to reset state
	Dma_DbgState 0x00727374
	Dma_ByteCopy Cpu_ProgramBase, Cpu_PC, 4, .LCpu_Reset.2

.LCpu_Reset.2:
	// RST.3: Clear the register file
	Dma_ByteFill Cpu_Regfile, Lit_00, 256, .LCpu_Fetch.1
Cpu_Stage_End   Reset

	/**********************************************************************************************
	 *
	 * DMACU CPU Fetch Stage
	 *
	 **********************************************************************************************/
Cpu_Stage_Begin Fetch
.LCpu_Fetch.1:
	// FE.1: Setup source address for instruction fetch
	Dma_DbgState 0x69666574
	Dma_ByteCopy (.LCpu_Fetch.2 + 0), Cpu_PC, 4, .LCpu_Fetch.2

	// FE.2: Fetch current instruction into opcode buffer
.LCpu_Fetch.2:
	Dma_ByteCopy Cpu_CurrentOPC, 0, 4, .LCpu_Fetch.3

	// FE.3: Generate lower 16 bit of next program counter
.LCpu_Fetch.3:
	Cpu_Add16Imm Cpu_NextPC, Cpu_PC, 4, .LCpu_Fetch.4

	// FE.4: Copy upper 16 bit of program counter then link to decode stage
.LCpu_Fetch.4:
	Dma_ByteCopy (Cpu_NextPC + 2), (Cpu_PC + 2), 2, .LCpu_Decode.1
Cpu_Stage_End Fetch

	/**********************************************************************************************
	 *
	 * DMACU CPU Decode Stage
	 *
	 **********************************************************************************************/
Cpu_Stage_Begin Decode
.LCpu_Decode.1:
	// DE.1: Generate the LLI address to the opcode (via tableswitch on opcode)
	//  Major opcode is in CurrentOPC[31:24]
	//
	Dma_DbgState 0x69646563
	Dma_TableSwitch64 (.LCpu_Decode.8 + 8), (Cpu_CurrentOPC + 3), Lut_InstructionTable, .LCpu_Decode.2

	// DE.2: Clear the current A and B operand values (use start of Lut_Carry as zero source)
.LCpu_Decode.2:
	Dma_ByteCopy (Cpu_CurrentA + 0), Lut_Carry, 6, .LCpu_Decode.3

	// DE.3: Prepare loading the A operand from Regfile[CurrentOPC[15:8]] (rA)
.LCpu_Decode.3:
	Dma_PatchSrcLo8 .LCpu_Decode.4, (Cpu_CurrentOPC + 0), .LCpu_Decode.4

	// DE.4: Load the A operand from Regfile[CurrentOPC[15:8]] (rA)
	//
	// NOTE: We always load rA+1:rA
.LCpu_Decode.4:
	Dma_ByteCopy Cpu_CurrentA, Cpu_Regfile, 2, .LCpu_Decode.5

	// DE.5: Prepare loading the B operand from Regfile[CurrentOPC[ 7:0]] (rB)
.LCpu_Decode.5:
	Dma_PatchSrcLo8 .LCpu_Decode.6, (Cpu_CurrentOPC + 1), .LCpu_Decode.6

	// DE.6: Load the B operand from Regfile[CurrentOPC[ 7:0]] (rB)
	//
	// NOTE: We always load rB+1:rB
.LCpu_Decode.6:
	Dma_ByteCopy Cpu_CurrentB, Cpu_Regfile, 2, .LCpu_Decode.7

	// DE.7: Prepare loading the Z operand from Regfile[CurrentOPC[23:16]] (rZ)
.LCpu_Decode.7:
	Dma_DbgState 0x65786563
	Dma_PatchSrcLo8 .LCpu_Decode.8, (Cpu_CurrentOPC + 2), .LCpu_Decode.8

	// DE.8: Load the Z operand from Regfile[CurrentOPC[23:16]] (rB)
	//   Then dispatch to the execute stage (LLI patched by .LCpu_Decode.1)
	//
	// NOTE: We always load rZ+3:rZ+2:rZ+1:rZ+0
.LCpu_Decode.8:
	Dma_ByteCopy Cpu_CurrentZ, Cpu_Regfile, 4, Cpu_OpUndef
Cpu_Stage_End Decode

	/**********************************************************************************************
	 *
	 * DMACU CPU Writeback Stage
	 *
	**********************************************************************************************/
Cpu_Stage_Begin Writeback
.LCpu_Writeback.FourRegs:
	// WB.FOUR.1: Setup copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
	Dma_PatchDstLo8 .LCpu_Writeback.FourRegs.Commit, (Cpu_CurrentOPC + 2), .LCpu_Writeback.FourRegs.Commit

.LCpu_Writeback.FourRegs.Commit:
	// WB.FOUR.2: Do copy from CurrentZ[31:0] to Regfile[rZ+3]:...:Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 4, .LCpu_Writeback.PC


.LCpu_Writeback.TwoRegs:
	// WB.TWO.1: Setup copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
	Dma_PatchDstLo8 .LCpu_Writeback.TwoRegs.Commit, (Cpu_CurrentOPC + 2), .LCpu_Writeback.TwoRegs.Commit

.LCpu_Writeback.TwoRegs.Commit:
	// WB.TWO.2: Do copy from CurrentZ[15:0] to Regfile[rZ+1]:Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 2, .LCpu_Writeback.PC

.LCpu_Writeback.OneReg:
	// WB.ONE.1: Setup copy from CurrentZ[7:0] to Regfile[rZ]
	Dma_PatchDstLo8 .LCpu_Writeback.OneReg.Commit, (Cpu_CurrentOPC + 2), .LCpu_Writeback.OneReg.Commit

.LCpu_Writeback.OneReg.Commit:
	// WB.ONE.2: Do copy from CurrentZ[7:0] to Regfile[rZ]
	Dma_ByteCopy Cpu_Regfile, Cpu_CurrentZ, 1, .LCpu_Writeback.PC

.LCpu_Writeback.PC:
	// WB.PC: Copy NextPC to PC, link to fetch stage
	Dma_ByteCopy Cpu_PC, Cpu_NextPC, 4, .LCpu_Fetch.1
Cpu_Stage_End Writeback

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
