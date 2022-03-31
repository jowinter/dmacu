#
# 
#

CROSS_PREFIX := arm-none-eabi-

CROSS_CC     := $(CROSS_PREFIX)gcc
CROSS_AS     := $(CROSS_PREFIX)gcc -x assembler-with-cpp
CROSS_LD     := $(CROSS_PREFIX)gcc

CROSS_CPU     := arm926ej-s
CROSS_CFLAGS  := -mcpu=$(CROSS_CPU) -msoft-float -Wall -std=c99 -pedantic -g -O1 -ffunction-sections -fdata-sections
CROSS_ASFLAGS := -mcpu=$(CROSS_CPU) -msoft-float -D__ASSEMBLER__
CROSS_LDFLAGS := -mcpu=$(CROSS_CPU) -msoft-float --specs=nano.specs --specs=rdimon.specs
CROSS_LIBS    :=

C_SOURCES  := dmacu.c rt.c

EXECUTABLE := dmacu.elf
OBJECTS    := $(C_SOURCES:%.c=%.o)

all: $(EXECUTABLE)

clean:
	rm -f $(EXECUTABLE) $(OBJECTS)

sim: $(EXECUTABLE)
	qemu-system-arm -machine versatilepb -semihosting -nographic -kernel $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CROSS_LD) $(CROSS_LDFLAGS) -o $@ $(OBJECTS) $(CROSS_LIBS)

%.o: %.c
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -c $<
