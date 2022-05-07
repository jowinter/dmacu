/**
 * Microcoded PL080 channel emulator
 *
 * Copyright (c) 2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

.include "dmacu.inc"

//-------------------------------------------------------------------------------------
// We simulate a largely simplified
//
DMACU.PROGRAM.BEGIN pl080
	//-------------------------------------------------------------------------------------
	// Virtual DMA Channel #0
	//

	// Channel #x - Source Address Register
	.equ DMACCxSrcAddr_0, r0
	.equ DMACCxSrcAddr_1, r1
	.equ DMACCxSrcAddr_2, r2
	.equ DMACCxSrcAddr_3, r3

	// Channel #x - Destination Address Register
	.equ DMACCxDstAddr_0, r4
	.equ DMACCxDstAddr_1, r5
	.equ DMACCxDstAddr_2, r6
	.equ DMACCxDstAddr_3, r7

	// Channel #x - Linked List Item register
	.equ DMACCxLLI_0,     r8
	.equ DMACCxLLI_1,     r9
	.equ DMACCxLLI_2,     r10
	.equ DMACCxLLI_3,     r11

	// Channel #x - Channel Control Register
	.equ DMACCxControl_0, r12
	.equ DMACCxControl_1, r13
	.equ DMACCxControl_2, r14
	.equ DMACCxControl_3, r15

	// Channel #x - Channel Config Register
	.equ DMACCxConfig_0, r16
	.equ DMACCxConfig_1, r17
	.equ DMACCxConfig_2, r18
	.equ DMACCxConfig_3, r19

	// Parameter registers (4x 8-bit)
	.equ rParam0,         r32
	.equ rParam1,         r33
	.equ rParam2,         r34
	.equ rParam3,         r35
	.equ rParam4,         r36

	// Scratchpad registers (4x 8-bit)
	.equ rTmp0,           r64
	.equ rTmp1,           r65
	.equ rTmp2,           r66
	.equ rTmp3,           r67

	// Data transfer register (4x 8-bit)
	.equ rDat0,           r68
	.equ rDat1,           r69
	.equ rDat2,           r70
	.equ rDat3,           r71

	// Transfer size
	.equ rSizeLo,         r100
	.equ rSizeHi,         r101

	// All channels done
	.equ rHasMoreWork,        r102

	// Temporary registers used to copy

	// Constants
	.equ kLit_0x00,       r114 // Literal value 0x00
	.equ kLit_0x01,       r115 // Literal value 0x01
	.equ kLit_0x02,       r116 // Literal value 0x02
	.equ kLit_0x04,       r117 // Literal value 0x04
	.equ kLit_0x08,       r118 // Literal value 0x08
	.equ kLit_0x0E,       r119 // Literal value 0x0E
	.equ kLit_0xF0,       r120 // Literal value 0xF0
	.equ kLit_0xFF,       r121 // Literal value 0xFF


	// Link register(s) for up to 3-levels of call hierarchy (static)
	.equ rLinkA,          r122 // Link register pair A (r123:r122)
	.equ rLinkB,          r124 // Link register pair B (r125:r124)
	.equ rLinkC,          r126 // Link register pair C (r127:r126)


	// Bootstrap descriptor (configured by the host)
	.equ gBootstrapDescriptorPtr0, r243
	.equ gBootstrapDescriptorPtr1, r244
	.equ gBootstrapDescriptorPtr2, r245
	.equ gBootstrapDescriptorPtr3, r246

	//-------------------------------------------------------------------------------------
	// Virtual PL080 "power-on reset"
	//
Virtual_PL080_Reset:
	DMACU.MOV.IMM8 kLit_0x00, 0x00
	DMACU.MOV.IMM8 kLit_0x01, 0x01
	DMACU.MOV.IMM8 kLit_0x02, 0x02
	DMACU.MOV.IMM8 kLit_0x04, 0x04
	DMACU.MOV.IMM8 kLit_0x08, 0x08
	DMACU.MOV.IMM8 kLit_0x0E, 0x0E
	DMACU.MOV.IMM8 kLit_0xF0, 0xF0
	DMACU.MOV.IMM8 kLit_0xFF, 0xFF

	// Setup the initial descriptor (via LLI) and channel (for testing)
	DMACU.MOV2     DMACCxLLI_0, gBootstrapDescriptorPtr1, gBootstrapDescriptorPtr0
	DMACU.MOV2     DMACCxLLI_2, gBootstrapDescriptorPtr3, gBootstrapDescriptorPtr2
	DMACU.MOV.IMM8 DMACCxConfig_0, 0x1

	DMACU.JAL      rLinkA, Virtual_PL080_LinkNextDescriptor

	// Branch into the main loop
	DMACU.JMP      Virtual_PL080_MainLoop

	//-------------------------------------------------------------------------------------
	// Main simulation loop of the virtual PL080
	//
Virtual_PL080_MainLoop:
	// Assume no work has been done so far
	DMACU.MOV.IMM8 rHasMoreWork, 0x00

	// Process Channel #0
	DMACU.JAL      rLinkA, Virtual_PL080_RunChannel
	DMACU.OR       rHasMoreWork, rHasMoreWork, rParam0

	// Check if we made process (stop otherwise)
	DMACU.BEQ      .LNoMoreWork, rHasMoreWork, 0x00
	DMACU.JMP      Virtual_PL080_MainLoop

.LNoMoreWork:
	DMACU.UND      0x000000

	//-------------------------------------------------------------------------------------
	// Executes a single transfer on the active DMA channel
	//
	// rParam0 indicates (on exit) whether the channel has more work to be done.
	//
	// Link register: rLinkA
	//
Virtual_PL080_RunChannel:
	// Is the channel enabled?
	//
	// NOTE: We blatantly ignore DMACCxConfiguration.{H,A,...}
	//
	DMACU.AND      rTmp0,   DMACCxConfig_0, kLit_0x01
	DMACU.BEQ      .LSetup, rTmp0,          0x01

	// No more work
	DMACU.JMP      Virtual_PL080_StopChannel

	// Channel has some work
.LSetup:
	// Execute the DMA transfer on our underlying controller and link
	//
	// NOTE: There is currently no need to sync back status changes (i.e. TransferSize going
	// to zero or similar).
	//
	DMACU.DMACPY   DMACCxDstAddr_0, DMACCxSrcAddr_0, DMACCxControl_0

	// Link the next descriptor
	DMACU.JMP      Virtual_PL080_LinkNextDescriptor

	//-------------------------------------------------------------------------------------
	// Helper to add an 8-bit value to a 32-bit value
	//
	// rParam3:rParam2:rParam1:rParam0 hold the 32-bit operand (and result)
	// rParam4                         holds the 8-bit value to be added (preserved accrsoss the call)
	// rTmp2:rTmp1:rTmp0               are clobbered (for carry propagation)
	//
	// Link register: rLinkB
	//
Virtual_PL080_Add8To32:
	DMACU.ACY    rTmp0,   rParam0, rParam4 // rTmp0    <= CarryFrom(A[ 7: 0] + B[ 7: 0])
	DMACU.ADD    rParam0, rParam0, rParam4 // Z[ 7: 0] <= A[ 7: 0] + B[ 7: 0]

	DMACU.ACY    rTmp1,   rParam1, rTmp0   // rTmp1    <= CarryFrom(A[15: 8] + rTmp0)
	DMACU.ADD    rParam1, rParam1, rTmp0   // Z[15: 8] <= A[15: 8] + rTmp0

	DMACU.ACY    rTmp2,   rParam2, rTmp1   // rTmp2    <= CarryFrom(A[23:16] + rTmp1)
	DMACU.ADD    rParam2, rParam2, rTmp1   // Z[23:16] <= A[23:16] + rTmp1

	DMACU.ADD    rParam3, rParam3, rTmp2   // Z[31:24] <= A[31:24] + rTmp2
	DMACU.RET    rLinkB


	//-------------------------------------------------------------------------------------
	// Links the next DMA descriptor
	//
	// rParam0 indicates (on exit) whether the channel has more work to be done.
	//
	// Link register: rLinkA
	//

	// Fetch the next descriptor and return
Virtual_PL080_LinkNextDescriptor:
	// Check for presence of another descriptor
	DMACU.BNE    .LChannelHasMoreWork, DMACCxLLI_0, 0x00
	DMACU.BNE    .LChannelHasMoreWork, DMACCxLLI_1, 0x00
	DMACU.BNE    .LChannelHasMoreWork, DMACCxLLI_2, 0x00
	DMACU.BNE    .LChannelHasMoreWork, DMACCxLLI_3, 0x00
	DMACU.JMP    Virtual_PL080_StopChannel

	// Channel has more descriptors pending
.LChannelHasMoreWork:
	DMACU.MOV2     rParam0, DMACCxLLI_1, DMACCxLLI_0
	DMACU.MOV2     rParam2, DMACCxLLI_3, DMACCxLLI_2
	DMACU.MOV.IMM8 rParam4, 0x04

	DMACU.LDW      DMACCxSrcAddr_0, rParam2, rParam0

	DMACU.JAL      rLinkB, Virtual_PL080_Add8To32

	DMACU.LDW      DMACCxDstAddr_0, rParam2, rParam0
	DMACU.JAL      rLinkB, Virtual_PL080_Add8To32

	DMACU.LDW      DMACCxLLI_0, rParam2, rParam0
	DMACU.JAL      rLinkB, Virtual_PL080_Add8To32

	DMACU.LDW      DMACCxControl_0, rParam2, rParam0

	DMACU.MOV.IMM8 rParam0, 0xFF
	DMACU.RET      rLinkA

	//-------------------------------------------------------------------------------------
	// Terminate activities of the current channel
	//
	// rParam0 indicates (on exit) whether the channel has more work to be done.
	//
	// Link register: rLinkA
	//
Virtual_PL080_StopChannel:
	// Channel is done (last transfer completed; no more descriptors to link)
	// we stop the channel (DMACCxConfig.E=0, DMACCxControl.TransferSize=0)
	DMACU.MOV.IMM8 DMACCxControl_0, 0x00
	DMACU.AND      DMACCxControl_1, DMACCxControl_1, kLit_0xF0
	DMACU.AND      DMACCxConfig_0,  DMACCxConfig_0,  kLit_0x0E

	DMACU.MOV.IMM8 rParam0, 0x00
	DMACU.RET      rLinkA

DMACU.PROGRAM.END   pl080
