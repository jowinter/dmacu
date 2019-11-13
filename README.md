# Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)

## Overview
`dmacu` is an emulator for a simple hypothetical RISC-like processor intended to run on ARM processor including a PL080 DMA controller.
The unique property of `dmacu` is that the emulator itself is executed using a DMA channel of the PL080 DMA controller. Once the DMA
channel has been started no further interaction from the host system's ARM core is required. The `dmacu` emulator even remains operational
while its host system's ARM core is halted via an external debug interface.
 
