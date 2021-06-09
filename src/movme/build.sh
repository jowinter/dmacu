../../external/movfuscator/build/movcc -S -O3 -Wf--no-mov-flow -Wf--no-mov-extern -Wf--no-mov-loop movme.c || exit 1
python3 movme-dma.py --input=movme.s --output=movme_dma.s || exit 1
arm-none-eabi-gcc -o movme-host.elf -Wall -O2 -g -specs=rdimon.specs -mcpu=arm926ej-s -marm movme-host.c movme_dma.s movcc-datatables.s || exit 1
arm-none-eabi-gcc -o movme-emu.elf  -Wall -O2 -g -specs=rdimon.specs -mcpu=arm926ej-s -marm movme-emu.c  movme_dma.s movcc-datatables.s || exit 1
