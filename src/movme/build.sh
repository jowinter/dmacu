../../external/movfuscator/build/movcc -o moveme.S -S -O3 -Wf--no-mov-flow -Wf--no-mov-extern -Wf--no-mov-loop movme.c || exit 1
python3 movme-dma.py --input=movme.S --output=movme_dma.S || exit 1
arm-none-eabi-gcc -o movme-host.elf -I.. -Wall -O2 -g -specs=rdimon.specs -mcpu=arm926ej-s -marm movme-host.c movme_dma.S movcc-datatables.S || exit 1
arm-none-eabi-gcc -o movme-emu.elf  -I.. -Wall -O2 -g -specs=rdimon.specs -mcpu=arm926ej-s -marm movme-emu.c  movme_dma.S movcc-datatables.S || exit 1
