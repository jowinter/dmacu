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

COMMON_C_SOURCES := ./vcpu/dmacu.c
COMMON_C_SOURCES += ./vcpu/rt.c
COMMON_C_SOURCES += ./vcpu/utils.c

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

CROSS_CPUFLAGS := -mcpu=arm926ej-s
CROSS_CPPFLAGS := -I./vcpu/

CROSS_CFLAGS   := $(CROSS_CPUFLAGS) $(CROSS_CPPFLAGS) -Wall -std=c99 -pedantic -g -O1 -ffunction-sections -fdata-sections
CROSS_LDFLAGS  := $(CROSS_CPUFLAGS) --specs=nano.specs --specs=rdimon.specs
CROSS_LIBS     :=

C_SOURCES      := $(COMMON_C_SOURCES)
C_SOURCES      += ./ports/qemu/versatile.c

EXECUTABLE     := dmacu.elf
OBJECTS        := $(C_SOURCES:%.c=%.o)

#--------------------------------------------------------------------------------------------------
# Compilation on the host (via clang)
#

# Build as 32 bit binary (PL080 emulation does currently not work on 64-bit)
HOST_CC        := clang
HOST_CPUFLAGS  := -m32
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
$(HOST_EXECUTABLE): $(HOST_C_SOURCES)
	$(HOST_CC) -o $@ $(HOST_CFLAGS) $(HOST_C_SOURCES)
