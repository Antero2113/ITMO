#!/bin/bash

qemu-system-riscv32 \
  -machine virt \
  -nographic \
  -bios default \
  -kernel kernel.elf \
  -serial mon:stdio

#   -smp 2 \