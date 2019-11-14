# Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)

## Overview
`dmacu` is an emulator for a simple hypothetical RISC-like processor intended to run on an ARM platform including a PL080 DMA controller.
The `dmacu` emulator itself executes on a DMA channel of the host system's PL080 DMA controller. Interaction from the host system's ARM core
is only needed to configure and start the DMA channel on which `dmacu` executes. No furhter interaction is needed from the host system's ARM
core once the DMA channel is up and running. The `dmacu` emulator remains operational while the host system's ARM core is in an active sleep
state (WFI/WFE), or while the ARM core is halted via an external debug interface.
