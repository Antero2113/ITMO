.section .text.boot
.globl boot

boot:
    la sp, stack_top
    call main

1:
    j 1b