/**
 * Assembler macro bindings for DMACU microcode
 *
 * Copyright (c) 2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/* Enable .altmacro mode (needed for e.g. dmacu_declare_regs) */
.altmacro

/*-------------------------------------------------------------------------------------------------
 * Encoding helpers for generic DMACU instructions (and programs)
 *-----------------------------------------------------------------------------------------------*/

/* Starts the definition of a DMACU program */
.macro DMACU.PROGRAM.BEGIN progname
	.pushsection ".microcode.program", "a", "progbits"
	.p2align 16
	.global __dmacu_program_\progname
__dmacu_program_\progname:
.LDMACU_Code:
.endm

/* Ends the definition of a DMACU program */
.macro DMACU.PROGRAM.END progname
	.type __dmacu_program_\progname, "object"
	.size __dmacu_program_\progname, . - __dmacu_program_\progname
	.popsection
.endm

/* Starts the definition of a DMACU data memory */
.macro DMACU.DATA.BEGIN progname
	.pushsection ".microcode.data", "aw", "progbits"
	.p2align 16
	.global __dmacu_data_\progname
__dmacu_data_\progname:
.LDMACU_Data:
.endm

/* Ends the definition of a DMACU data memory */
.macro DMACU.DATA.END progname
	.type __dmacu_data_\progname, "object"
	.size __dmacu_data_\progname, . - __dmacu_data_\progname
	.popsection
.endm

/* Emits a generic DMACU instruction */
.macro DMACU.INST op, rz, rb, ra
	.byte (\ra), (\rb), (\rz), (\op)
.endm

/* Emits a DMACU instruction with 16 bit immediate */
.macro DMACU.OP1.IMM16 op, rz, imm16
	DMACU.INST (\op), (\rz), ((\imm16) >> 8) & 0xFF, (\imm16) & 0xFF
.endm

/* Emit an absolute (program base relative) branch instrcution */
.macro DMACU.INST.JMP.ABS op, rz, tgt
	DMACU.OP1.IMM16 (\op), (\rz), ((\tgt) - .LDMACU_Code)
.endm

/* Emit a relative branch instrcution */
.macro DMACU.INST.BRANCH.REL op, rz, rb, tgt
.LDMACU_JmpRel_Anchor\@:
	DMACU.INST (\op), (\rz), (\rb), ((\tgt) - .LDMACU_JmpRel_Anchor\@)
.endm

/*-------------------------------------------------------------------------------------------------
 * Define standard register aliases
 *-----------------------------------------------------------------------------------------------*/

.macro dmacu_declare_one_reg val
	.set r\val, \val
.endm

.macro dmacu_declare_regs
	i=0
	.rept 256
		dmacu_declare_one_reg %(i)
		i=i+1
	.endr
.endm

dmacu_declare_regs


/*-------------------------------------------------------------------------------------------------
 * Natively implemented DMACU instructions
 *-----------------------------------------------------------------------------------------------*/
/*
 * NOP       - No Operation
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x00 | (0)  | (0)  | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.NOP
DMACU.INST 0x00, 0, 0, 0
.endm

/*
 * MOV rZ, #imm8 - Move to register from 8-bit immediate
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x01 | rZ   | (0)  | imm8 |
 * +------+------+------+------+
 */
.macro DMACU.MOV.IMM8 rZ, imm8
DMACU.INST 0x01, (\rZ), 0, (\imm8)
.endm

/*
 * MOV rZ+1:rZ, #imm16 - Move to register pair from 16-bit immediate
 *
 *  31  24     16             0
 * +------+------+-------------+
 * | 0x02 | rZ   |       imm16 |
 * +------+------+-------------+
 */
.macro DMACU.MOV.IMM16 rZ, imm16
DMACU.OP1.IMM16 0x02, (\rZ), (\imm16)
.endm

/*
 * MOV2 rZ+1:rZ, rB:rA - Move from register pair to register pair
 * MOV  rZ, rA         - (Pseudo-Instruction) Move from register to register (if rB=rZ+1)
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x03 |  rZ  | rB   |  rA  |
 * +------+------+------+------+
 */
.macro DMACU.MOV2 rZ, rB, rA
DMACU.INST 0x03, (\rZ), (\rB), (\rA)
.endm

.macro DMACU.MOV rZ, rA
DMACU.MOV2 (\rZ), ((\rZ)+1), (\rA)
.endm

/*
 * ADD rZ, rB, #imm8               - Add register and 8-bit immediate
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x04 |  rZ  | rB   | imm8 |
 * +------+------+------+------+
 */
.macro DMACU.ADD.IMM8 rZ, rB, imm8
DMACU.INST 0x04, (\rZ), (\rB), (\imm8)
.endm

/*
 * ACY rZ, rB, #imm8               - Generate carry from add with 8-bit immediate
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x05 |  rZ  | rB   | imm8 |
 * +------+------+------+------+
 */
.macro DMACU.ACY.IMM8 rZ, rB, imm8
DMACU.INST 0x05, (\rZ), (\rB), (\imm8)
.endm

/*
 * ADD rZ, rB, rA                  - Add two registers
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x06 |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.ADD rZ, rB, rA
DMACU.INST 0x06, (\rZ), (\rB), (\rA)
.endm

/*
 * ACY rZ, rB, rA              - Generate carry from add with 8-bit registers
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x07 |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.ACY rZ, rB, rA
	DMACU.INST 0x07, (\rZ), (\rB), (\rA)
.endm

/*
 * JMP #imm16                    - Jump absolute
 *
 *  31  24 23                 0
 * +------+------+-------------+
 * | 0x08 |  (0) | imm16       |
 * +------+------+-------------+
 */
.macro DMACU.JMP tgt
	DMACU.INST.JMP.ABS 0x08, 0x00, (\tgt)
.endm

/*
 * JMP rB:rA                    - Jump register indirect
 * RET rA                       - (Pseudo-Instruction) Return from Subroutine (if rB=rZ+1)
 *
 * +------+------+------+------+
 * | 0x09 |  (0) | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.JMP.REG rB, rA
	DMACU.INST 0x09, 0x00, (\rB), (\rA)
.endm

.macro DMACU.RET rA
	DMACU.INST 0x09, 0x00, ((\rA) + 1), (\rA)
.endm

/*
 * BNE (+off8) rZ, rB                   - Branch if not equal
 *
 * +------+------+------+------+
 * | 0x0A |  rZ  | rB   | off8 |
 * +------+------+------+------+
 */
.macro DMACU.BNE.REG tgt, rZ, rB
	DMACU.INST.BRANCH.REL 0x0A, (\rZ), (\rB), (\tgt)
.endm

/*
 * BEQ (+off8) rZ, rB                   - Branch if equal
 *
 * +------+------+------+------+
 * | 0x0B |  rZ  | rB   | off8 |
 * +------+------+------+------+
 */
.macro DMACU.BEQ.REG tgt, rZ, rB
	DMACU.INST.BRANCH.REL 0x0B, (\rZ), (\rB), (\tgt)
.endm

/*
 * BNE (+off8) rZ, #imm8                - Branch if not equal
 *
 * +------+------+------+------+
 * | 0x0C |  rZ  | imm8 | off8 |
 * +------+------+------+------+
 */
.macro DMACU.BNE tgt, rZ, imm8
DMACU.INST.BRANCH.REL 0x0C, (\rZ), (\imm8), (\tgt)
.endm

/*
 * BEQ (+off8) rZ, #imm8                - Branch if equal
 *
 * +------+------+------+------+
 * | 0x0D |  rZ  | imm8 | off8 |
 * +------+------+------+------+
 */
.macro DMACU.BEQ tgt, rZ, imm8
	DMACU.INST.BRANCH.REL 0x0D, (\rZ), (\imm8), (\tgt)
.endm

/*
 * NOT rZ, rB                      - Bitwise NOT
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x0E |  rZ  | rB   | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.NOT rZ, rB
	DMACU.INST 0x0E, (\rZ), (\rB), 0
.endm

/*
 * AND rZ, rB, rA                  - Bitwise AND
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x0F |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.AND rZ, rB, rA
	DMACU.INST 0x0F, (\rZ), (\rB), (\rA)
.endm

/*
 * OR  rZ, rB, rA                  - Bitwise OR
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x10 |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.OR rZ, rB, rA
	DMACU.INST 0x10, (\rZ), (\rB), (\rA)
.endm

/*
 * EOR rZ, rB, rA                  - Bitwise XOR
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x11 |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.EOR rZ, rB, rA
	DMACU.INST 0x11, (\rZ), (\rB), (\rA)
.endm

/*
 * ROR rZ, rB, #1                  - Rotate-Right by 1
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x12 |  rZ  | rB   | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.ROR1 rZ, rB
	DMACU.INST 0x12, (\rZ), (\rB), 0
.endm

/*
 * ROL rZ, rB, #1                  - Rotate-Left by 1
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x13 |  rZ  | rB   | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.ROL1 rZ, rB
	DMACU.INST 0x13, (\rZ), (\rB), 0
.endm

/*
 * LO4 rZ, rB                      - Extract lower 4 bits
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x14 |  rZ  | rB   | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.LO4 rZ, rB
	DMACU.INST 0x14, (\rZ), (\rB), 0
.endm

/*
 * HI4 rZ, rB                      - Extract upper 4 bits
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x15 |  rZ  | rB   | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.HI4 rZ, rB
	DMACU.INST 0x15, (\rZ), (\rB), 0
.endm

/*
 * SHL4 rZ, rB                     - Shift left by 4 bits
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x16 |  rZ  | rB   | (0)  |
 * +------+------+------+------+
 */
.macro DMACU.SHL4 rZ, rB
	DMACU.INST 0x16, (\rZ), (\rB), 0
.endm

/*
 * JAL rZ+1:rZ, #imm16             - Jump and Link
 *
 *  31  24     16      8      0
 * +------+------+-------------+
 * | 0x17 |  rZ  | imm16       |
 * +------+------+-------------+
 */
.macro DMACU.JAL rZ, tgt
	DMACU.INST.JMP.ABS 0x17, (\rZ), (\tgt)
.endm

/*
 * LIT32 rZ+3:rZ+2:rZ+1:rZ, (off16) - Load a 32-bit literal
 *
 *  31  24     16      8      0
 * +------+------+-------------+
 * | 0x18 |  rZ  | (off16)     |
 * +------+------+-------------+
 */
.macro DMACU.LIT32 rZ, tgt
	DMACU.OP1.IMM16 0x18, (\rZ), ((\tgt) - .LDMACU_Code)
.endm

/*
 * LDB rZ, [rB+1:rB:rA+1:rA]        - Load byte indirect
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x19 |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.LDB rZ, rB, rA
	DMACU.INST 0x19, (\rZ), (\rB), (\rA)
.endm

/*
 * LDH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load half-word indirect
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x1B |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.LDH rZ, rB, rA
	DMACU.INST 0x1B, (\rZ), (\rB), (\rA)
.endm

/*
 * LDW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Load word indirect
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x1D |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.LDW rZ, rB, rA
	DMACU.INST 0x1D, (\rZ), (\rB), (\rA)
.endm

/*
 * STB rZ, [rB+1:rB:rA+1:rA]        - Store byte indirect
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x1A |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.STB rZ, rB, rA
	DMACU.INST 0x1A, (\rZ), (\rB), (\rA)
.endm

/*
 * STH rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store half-word indirect
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x1C |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.STH rZ, rB, rA
	DMACU.INST 0x1C, (\rZ), (\rB), (\rA)
.endm

/*
 * STW rZ+3:rZ+2:rZ+1:rZ, [rB+1:rB:rA+1:rA]    - Store word indirect
 *
 *  31  24     16      8      0
 * +------+------+------+------+
 * | 0x1E |  rZ  | rB   | rA   |
 * +------+------+------+------+
 */
.macro DMACU.STW rZ, rB, rA
	DMACU.INST 0x1E, (\rZ), (\rB), (\rA)
.endm

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
.macro DMACU.UND imm24=0
	DMACU.INST 0x1F, (((\imm24)>>16)&0xFF), (((\imm24)>>8)&0xFF), (((\imm24)>>0)&0xFF)
.endm
