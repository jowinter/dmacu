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
	.irp  c,'H','e','l','l','o',' ','b','r','a','v','e',' ','n','e','w', \
            ' ','P','L','0','8','0',' ','D','M','A',' ','w','o','r','l', \
	        'd','!', 0x0A,0x00
		obf_byte \c
	.endr
DMACU.DATA.END      demo

//
// Code segment for the demo program
//
DMACU.PROGRAM.BEGIN demo
	// Alias for the host marker registers
	.equ rMagic0, r224
	.equ rMagic1, r225
	.equ rMagic2, r226
	.equ rMagic3, r227

	.equ kExpectedMagic0, 0xDE
	.equ kExpectedMagic1, 0xAD
	.equ kExpectedMagic2, 0xC0
	.equ kExpectedMagic3, 0xDE

	// Global register used for the LED blink output
	.equ gLedGpioPin0,    r228
	.equ gLedGpioPin1,    r229
	.equ gLedGpioPin2,    r230
	.equ gLedGpioPin3,    r231
	.equ gLedGpioMask0,   r232
	.equ gLedGpioMask1,   r233
	.equ gLedGpioMask2,   r234
	.equ gLedGpioMask3,   r235

	// Platform ID register (r247)
	.equ rPlatformId,             r247
	.set kHostPlatform,           0x00
	.set kLpcXpresso1769Platform, 0x41
	.set kQemuPlatform,           0x51

	// Code base address
	.equ gCodeBase0,      r248
	.equ gCodeBase0,      r249
	.equ gCodeBase0,      r250
	.equ gCodeBase0,      r251

	// Ram base address
	.equ gRamBase0,       r252
	.equ gRamBase1,       r253
	.equ gRamBase2,       r254
	.equ gRamBase3,       r255

	//-------------------------------------------------------------------------------------
	// Part 0: Platform setup
	//

	// Platform check: Blink is currently supported on all platforms6
	DMACU.BEQ      .Lsetup_host,           rPlatformId, kHostPlatform
	DMACU.BEQ      .Lsetup_qemu,           rPlatformId, kQemuPlatform
	DMACU.BEQ      .Lsetup_lpcxpresso1769, rPlatformId, kLpcXpresso1769Platform
	DMACU.UND      0xEEEE

	// Host platform (or other platform that does not support the blink)
	//
	// We let the blink logic run against the the word at offset 0xFC in
	// the RAM. (We assume a 256 byte aligned RAM)
.Lsetup_host:
	DMACU.MOV.IMM8  gLedGpioPin0,  0xFC
	DMACU.MOV2      gLedGpioPin0,  gRamBase1, gLedGpioPin0
	DMACU.MOV2      gLedGpioPin2,  gRamBase3, gRamBase2
	DMACU.MOV.IMM16 gLedGpioMask0, 0x0001
	DMACU.MOV.IMM16 gLedGpioMask2, 0x0000
	DMACU.JMP       1f

.Lsetup_qemu:
	// RealView System Control Block (and its LEDs register)
	DMACU.MOV.IMM16 gLedGpioPin0,  0x0008 // PIN register @ 0x10000008
	DMACU.MOV.IMM16 gLedGpioPin2,  0x1000 // -"-
	DMACU.MOV.IMM16 gLedGpioMask0, 0x0001 // PIN mask is 0x00000001
	DMACU.MOV.IMM16 gLedGpioMask2, 0x0000 // -"-
	DMACU.JMP       1f

.Lsetup_lpcxpresso1769:
	DMACU.MOV.IMM16 gLedGpioPin0,  0xC014 // PIN register (LPC_GPIO0->FIOPIN) @ 0x2009C014
	DMACU.MOV.IMM16 gLedGpioPin2,  0x2009 // -"-
	DMACU.MOV.IMM16 gLedGpioMask0, 0x0000 // PIN mask is 0x0000040
	DMACU.MOV.IMM16 gLedGpioMask2, 0x0040 // -"-
	DMACU.JMP       1f

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
4:	DMACU.BNE      5f, rMagic0, kExpectedMagic0
	DMACU.BNE      5f, rMagic1, kExpectedMagic1
	DMACU.BNE      5f, rMagic2, kExpectedMagic2
	DMACU.BEQ      6f, rMagic3, kExpectedMagic3
5:	DMACU.UND      0xE001

	// ------------------------------------------------------------------------------------
	// Part 3: 'Decrypt' the test message in host RAM
	//

	// - Copy the lower 16-bit of the RAM base pointer r255:r254:r253:r252 to r17:r16
	//   We assume that our data-RAM lies within a single 64k segment and that we can
	//   use r255:r254:r17:r16 as source/destination pointer.
	//
6:	DMACU.MOV2     r16, gRamBase0, gRamBase1

	// - Load the XOR "key" (0xC3) in r2, load our loop increment (1) in r1
	DMACU.MOV.IMM8 r1, 0x01
	DMACU.MOV.IMM8 r2, 0xC3

	// - Load the current byte into r3
7:	DMACU.LDB      r3, gRamBase2, r16

	// - Deobfuscate (step 1) be XOR'ing with 0x5A, followed by a rotate left by 1
	DMACU.EOR      r3, r3, r2
	DMACU.ROL1     r3, r3

	// - Send a byte to the PL011 UART	(currently only supported on QEMU)
	DMACU.MOV      r34, r3        // --> Parameter for our subroutine
	DMACU.JAL      r32, uart_putchar

	// - Blink-out the byte via our LED (on all platforms)
	DMACU.MOV      r34, r3        // --> Parameter for our subroutine
	DMACU.JAL      r32, blink_led // --> Call the blink subroutine

	// - Store the deobfuscated byte
	DMACU.STB      r3, gRamBase2, r16

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
	//
	// Temporary:
	//   r35                  - Output bit position (clobbered)
	//   r36                  - Tempory register    (clobbered)
	//
	//   r231:r230:r229:r228  - GPIO output pin register (clobbered)
	//   r235:r234:r233:r232  - GPIO output pin mask     (clobbered)
	//
	//   r40:r39:r38:r37      - Used to construct the led mask
	//   r44:r43:r42:r41      - Used to construct the led mask
	//

blink_led:
	// - Start clocking at the LSB
	DMACU.MOV.IMM8 r35, 0x01

	// - Prepare the inverse LED mask in r40:r39:r38:r37
	DMACU.NOT      r37, gLedGpioMask0
	DMACU.NOT      r38, gLedGpioMask1
	DMACU.NOT      r39, gLedGpioMask2
	DMACU.NOT      r40, gLedGpioMask3

	// - Extract the current bit into r36
9:	DMACU.AND      r36, r34,  r35

	// - Load the led status into r44:r43:r42:r41
	DMACU.LDW      r41, gLedGpioPin2, gLedGpioPin0

	// - Set the led (if the current bit is 1)
	DMACU.BEQ      10f, r36, 0x00
	DMACU.OR       r41, r41, gLedGpioMask0
	DMACU.OR       r42, r42, gLedGpioMask1
	DMACU.OR       r43, r43, gLedGpioMask2
	DMACU.OR       r44, r44, gLedGpioMask3
	DMACU.JMP      11f

	// - Clear the led (if the current bit is 0)
10:	DMACU.AND      r41, r41, r37
	DMACU.AND      r42, r42, r38
	DMACU.AND      r43, r43, r39
	DMACU.AND      r44, r44, r40
	DMACU.JMP      11f

	// - Write the new led status
11:	DMACU.STW      r41, gLedGpioPin2, gLedGpioPin0

	// Inter-bit delay (for illustration)
	DMACU.MOV.IMM8 r36, 0x40

12:	DMACU.BEQ      13f, r36, 0x00
	DMACU.ADD.IMM8 r36, r36, 0xFF
	DMACU.JMP      12b

	// - Advance r35 to the next bit and loop
13: DMACU.BEQ      14f, r35, 0x80
	DMACU.ROL1     r35, r35
	DMACU.JMP      9b

	// - Byte done, return to main
14:	DMACU.RET      r32

	//------------------------------------------------------------------------------------
	// Subroutine to print a single character (in r34) to QEMU's PL011 UART
	//
	// Input:
	//   r34                  - The byte to be sent (preserved)
	//   r33:r32              - Link register
	//
	// Temporary:
	//   r36:r35              - Peripheral base for the UART      (0x101F____)
	//   r38:r37              - Offset of the PL011 data register (0x____1000)
	//   r40:r39              - Offset of the PL011 flag register (0x____1018)
	//   r44:r43:r42:r41      - Scratchpad for PL011 register reads/writes
	//   r45                  - Mask for the UART ready flag
	//
	.equ kPeriphBase,      r35
	.equ kUartDataReg,     r37
	.equ kUartFlagReg,     r39
	.equ rUartTemp,        r41
	.equ kUartTxReadyFlag, r45

uart_putchar:
	// Platform check: Use the PL011 UART on QEMU
	DMACU.BEQ       uart_putchar_qemu, rPlatformId, kQemuPlatform

	// All other platforms: Ignore
	DMACU.RET       r32

	// Setup
uart_putchar_qemu:
	DMACU.MOV.IMM16 kPeriphBase,      0x101F
	DMACU.MOV.IMM16 kUartDataReg,     0x1000
	DMACU.MOV.IMM16 kUartFlagReg,     0x1018
	DMACU.MOV.IMM8  kUartTxReadyFlag, 0x80

	// Wait until the UART is ready to transmit
uart_putchar_qemu_wait_for_tx_ready:
    DMACU.LDW       rUartTemp, kPeriphBase, kUartFlagReg
	DMACU.AND       rUartTemp, rUartTemp,   kUartTxReadyFlag
	DMACU.BEQ       uart_putchar_qemu_wait_for_tx_ready, rUartTemp, 0x00

	// Send one byte and return
    DMACU.STB       r34, kPeriphBase, kUartDataReg
	DMACU.RET       r32
DMACU.PROGRAM.END   demo
