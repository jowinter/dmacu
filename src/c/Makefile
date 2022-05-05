#
# Minimal CPU Emulator Powered by the ARM PL080 DMA Controller (dmacu)
#
# Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
#
# This file is licensed under the MIT License. See LICENSE in the root directory
# of the prohect for the license text.
#

#--------------------------------------------------------------------------------------------------
# Common (host and target) options
#
COMMON_CPPFLAGS  := -I./vcpu/

COMMON_C_SOURCES := ./vcpu/dmacu_shared.c
COMMON_C_SOURCES += ./vcpu/dmacu_instance.c
COMMON_C_SOURCES += ./vcpu/vpl080.c
COMMON_C_SOURCES += ./vcpu/rt.c
COMMON_C_SOURCES += ./vcpu/utils.c

# Enable experimental "virtual PL080" mode (if DMACU_VIRTUAL_PL080=1 is given as make parameter)
ifeq ($(DMACU_VIRTUAL_PL080),1)
COMMON_CPPFLAGS += -DDMACU_VIRTUAL_PL080=1
endif

#--------------------------------------------------------------------------------------------------
# Compilation to an ARM target (via an arm-none-eabi toolchain)
#
# TODO: Investigate a clang setup (easy for armclang from Keil MDK; how can we deal with a
#  typical clang on, e.g. Debian, w.r.t. to the runtime lib?)
#

CROSS_PREFIX   := arm-none-eabi-

CROSS_CC       := $(CROSS_PREFIX)gcc
CROSS_AS       := $(CROSS_PREFIX)gcc -x assembler-with-cpp
CROSS_LD       := $(CROSS_PREFIX)gcc
CROSS_OBJCOPY  := $(CROSS_PREFIX)objcopy

CROSS_CPUFLAGS := -mcpu=arm926ej-s
CROSS_CPPFLAGS := -I./vcpu/

CROSS_CFLAGS   := $(CROSS_CPUFLAGS) $(CROSS_CPPFLAGS) -Wall -std=c99 -pedantic -g -O1 -ffunction-sections -fdata-sections
CROSS_LDFLAGS  := $(CROSS_CPUFLAGS) --specs=nano.specs --specs=rdimon.specs
CROSS_LIBS     :=

C_SOURCES      := $(COMMON_C_SOURCES)
C_SOURCES      += ./ports/qemu/versatile.c

EXECUTABLE     := dmacu_qemu_versatilepb.elf
OBJECTS        := $(C_SOURCES:%.c=%.o)

#--------------------------------------------------------------------------------------------------
# Compilation of microcode files
#

MC_AS           := $(CROSS_AS)
MC_ASFLAGS      := -nostartfiles -nodefaultlibs -I ./vcpu/mc/ -Ttext=0x00000000 -e 0x00000000
MC_OBJCOPY      := $(CROSS_OBJCOPY)
MC_OCFLAGS_CODE := -Obinary -j .microcode.program
MC_OCFLAGS_DATA := -Obinary -j .microcode.data

# Source files for microcode compilation
MC_SOURCES     := ./vcpu/mc/demo.mc
MC_SOURCES     += ./vcpu/mc/pl080.mc

# Raw object files resulting from microcode compilation
MC_OBJECTS     := $(MC_SOURCES:%.mc=%.o)

# Raw binaries for microcode program and data images
MC_BINARIES    := $(MC_OBJECTS:%.o=%.code.bin) # Code segment images
MC_BINARIES    += $(MC_OBJECTS:%.o=%.data.bin) # Data segment images

# Raw microcode program and data images prepared for inclusion in C initializers
MC_INCS        := $(MC_BINARIES:%.bin=%.inc)

#--------------------------------------------------------------------------------------------------
# Compilation on the host (via clang)
#

# Build as 32 bit binary (PL080 emulation does currently not work on 64-bit)
#
# FIXME: We currently force the maximum RAM alignment to 4K (instead of 64K) due to limitation
# with qemu-i386 running on WSL. This might cause bugs ...
#
HOST_CC        := clang
HOST_CPUFLAGS  := -m32 -DDMACU_RAM_ALIGNMENT=0x1000
HOST_OPTFLAGS  := -g -O1 -flto
HOST_CFLAGS    := $(HOST_CPUFLAGS) $(COMMON_CPPFLAGS) -Wall -std=c99 -pedantic $(HOST_OPTFLAGS)

HOST_C_SOURCES := $(COMMON_C_SOURCES)
HOST_C_SOURCES += ./ports/hostemu/pl080.c
HOST_C_SOURCES += ./ports/hostemu/hostemu.c

HOST_EXECUTABLE := hostemu32.elf

#--------------------------------------------------------------------------------------------------

# Build all targets
all: $(EXECUTABLE) $(HOST_EXECUTABLE)

# Cleanup
clean:
	rm -f $(HOST_EXECUTABLE) $(EXECUTABLE) $(OBJECTS)
	rm -f $(MC_INCS) $(MC_BINARIES) $(MC_OBJECTS)

# Build the target image and call-out to QEMU
sim: $(EXECUTABLE)
	qemu-system-arm -machine versatilepb -semihosting -nographic -kernel $(EXECUTABLE)

# Host-side simulation (using qemu-i386 to support 64-bit hosts such as WSL on Windows 10)
host-sim: $(HOST_EXECUTABLE)
	qemu-i386 $(HOST_EXECUTABLE)

# Link the target binary
$(EXECUTABLE): $(OBJECTS)
	$(CROSS_LD) $(CROSS_LDFLAGS) -o $@ $(OBJECTS) $(CROSS_LIBS)

# Compiler a target object file (form C sources)
%.o: %.c
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -c $<

# Compile and link the hostemu target
$(HOST_EXECUTABLE): $(HOST_C_SOURCES) $(MC_INCS)
	$(HOST_CC) -o $@ $(HOST_CFLAGS) $(HOST_C_SOURCES)

# Explicitly declare the dependecy for utils.o and vpl080.o (test program)
vcpu/utils.o: $(MC_INCS)
vcpu/vpl080.o: $(MC_INCS)

#--------------------------------------------------------------------------------------------------
# Build the microcode
#
microcode: $(MC_INCS)

# Compile a microcode program (into a binary file)
#
# We use a two step approach:
# 1. Compile+link an assembler program (at address 0)
# 2. Extract a binary image (via objcopy)
#
%.o: %.mc
	$(MC_AS) -o $@ $(MC_ASFLAGS) $<

# Extract the code segment
%.code.bin: %.o
	$(MC_OBJCOPY) $(MC_OCFLAGS_CODE) $< $@

# Extract the data segment
%.data.bin: %.o
	$(MC_OBJCOPY) $(MC_OCFLAGS_DATA) $< $@

# Prepare for inclusion in C source code
#
# We use the output of "xxd -i" bar the header/footer lines that are added by the tool
%.inc: %.bin
	xxd -i $< | head --lines=-2 | tail --lines=+2 > $@
