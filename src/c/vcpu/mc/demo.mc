/**
 * Demo program for the DMACU virtual CPU
 *
 * Copyright (c) 2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

.include "dmacu.inc"

#define LABEL_AT(x)
#define UINT32_C(x) .long (x)

// Obfuscates a byte on the host (for our test-ram message)
//
// We obfuscate be rotating right by 1 bit and XOR-ing with 0x5A
.macro obf_byte x
	.byte ((((\x) >> 1) | ((\x) << 7u)) ^ 0xC3) & 0xFF
.endm

//
// Data segment for the demo program
//
DMACU.DATA.BEGIN    demo
 	// Reference test message (obfuscated)
	.irp  c,'H','e','l','o',' ','b','r','a','v','e',' ','n','e','w',' ', \
	        'P','L','0','8',' ','D','M','A',' ','w','o','r','l','d','!', \
	        0x0A,0x00
		obf_byte \c
	.endr
DMACU.DATA.END      demo

//
// Code segment for the demo program
//
DMACU.PROGRAM.BEGIN demo
	//-------------------------------------------------------------------------------------
	// Part 1: Loop around a bit
	//
	DMACU.MOV.IMM8 r0, 0x08
	DMACU.MOV.IMM8 r1, 0x00

1:	DMACU.BEQ      2f, r0, 0x00
	DMACU.ADD.IMM8 r0, r0, 0xFF
	DMACU.ADD.IMM8 r1, r1, 0x01
	DMACU.JMP      1b

2:	DMACU.BNE      3f, r1, 0x04
	DMACU.JMP      4f
3:	DMACU.ADD.IMM8 r0, r0, 0x01
	DMACU.ADD.IMM8 r1, r1, 0xFF
	DMACU.NOT      r2, r0
	DMACU.EOR      r3, r2, r1
	DMACU.JMP      2b

	//-------------------------------------------------------------------------------------
	// Part 2: Check for the 0xDE 0xAD 0xC60 0xDE pattern in r224-r227
	//
4:	DMACU.BNE      5f, r224, 0xDE
	DMACU.BNE      5f, r225, 0xAD
	DMACU.BNE      5f, r226, 0xC0
	DMACU.BEQ      6f, r227, 0xDE
5:	DMACU.UND      0xE001

	// ------------------------------------------------------------------------------------
	// Part 3: 'Decrypt' the test message in host RAM
	//

	// - Copy the lower 16-bit of the RAM base pointer r255:r254:r253:r252 to r17:r16
	//   We assume that our data-RAM lies within a single 64k segment and that we can
	//   use r255:r254:r17:r16 as source/destination pointer.
	//
6:	DMACU.MOV2     r16, r253, r252

	// - Load the XOR "key" (0xC3) in r2, load our loop increment (1) in r1
	DMACU.MOV.IMM8 r1, 0x01
	DMACU.MOV.IMM8 r2, 0xC3

	// - Load the current byte into r3
7:	DMACU.LDB      r3, r254, r16

	// - Deobfuscate (step 1) be XOR'ing with 0x5A, followed by a rotate left by 1
	DMACU.EOR      r3, r3, r2
	DMACU.ROL1     r3, r3

	// - Blink-out the byte via our LED
	DMACU.MOV      r34, r3        // --> Parameter for our subroutine
	DMACU.JAL      r32, blink_led // --> Call the blink subroutine

	// - Store the deobfuscated byte
	DMACU.STB      r3, r254, r16

	// - Stop if we have a NUL byte
	DMACU.BEQ      8f, r3, 0

	// Increment our 16-bit offset in r17:r16 and resume
	DMACU.ACY      r4,  r16, r1
	DMACU.ADD      r16, r16, r1
	DMACU.ADD      r17, r17, r4
	DMACU.JMP      7b

	//------------------------------------------------------------------------------------
	// End of line :)
	//

	// And we are done
8:  DMACU.UND      0x656E64

	//------------------------------------------------------------------------------------
	// Subroutine to "blink"-out the value in r34
	//
	// Input:
	//   r34                  - The value to be "blinked out"
	//   r33:r32              - Link register
	//   r231:r230:r229:r228  - GPIO output pin register (preserved)
	//   r235:r234:r233:r232  - GPIO output pin mask     (preserved)
	//
	// Temporary:
	//   r35                  - Output bit position (clobbered)
	//   r36                  - Tempory register    (clobbered)
	//
	//   r40:r39:r38:r37      - Used to construct the led mask
	//   r44:r43:r42:r41      - Used to construct the led mask
	//

	// - Start clocking at the LSB
blink_led:
	DMACU.MOV.IMM8 r35, 0x01

	// - Prepare the inverse LED mask in r40:r39:r38:r37
	DMACU.NOT      r37, r232
	DMACU.NOT      r38, r233
	DMACU.NOT      r39, r234
	DMACU.NOT      r40, r235

	// - Extract the current bit into r36
9:	DMACU.AND      r36, r34,  r35

	// - Load the led status into r40:r39:r38:r37
	DMACU.LDW      r41, r230, r228

	// - Set the led (if the current bit is 1)
	DMACU.BEQ      10f, r36,  0x00
	DMACU.OR       r41, r41, r232
	DMACU.OR       r42, r42, r233
	DMACU.OR       r43, r43, r234
	DMACU.OR       r44, r44, r235
	DMACU.JMP      11f

	// - Clear the led (if the current bit is 0)
10:	DMACU.AND      r41, r41, r37
	DMACU.AND      r42, r42, r38
	DMACU.AND      r43, r43, r39
	DMACU.AND      r44, r44, r40
	DMACU.JMP      11f

	// - Write the new led status
11:	DMACU.STW      r41, r230, r228

	// Inter-bit delay (for illustration)
	DMACU.MOV.IMM8 r36, 0x80

12:	DMACU.BEQ      13f, r36, 0x00
	DMACU.ADD.IMM8 r36, r36, 0xFF
	DMACU.JMP      12b

	// - Advance r35 to the next bit and loop
13:	DMACU.BEQ      14f, r35, 0x80
	DMACU.ROL1     r35, r35
	DMACU.JMP      9b

	// - Byte done, return to main
14:	DMACU.RET      r32
DMACU.PROGRAM.END   demo
