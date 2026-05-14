CC=riscv64-unknown-elf-gcc
CFLAGS=-march=rv32imac -mabi=ilp32 -ffreestanding -nostdlib -O0
LDFLAGS=-T kernel.ld

all: kernel.elf

kernel.elf: start.S kernel.c
	$(CC) $(CFLAGS) start.S kernel.c $(LDFLAGS) -o kernel.elf

clean:
	rm -f *.elf