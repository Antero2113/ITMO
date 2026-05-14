ENTRY(boot)

SECTIONS
{
    . = 0x80200000;

    .text : {
        *(.text.boot)
        *(.text*)
    }

    .rodata : { *(.rodata*) }
    .data   : { *(.data*) }
    .bss    : { *(.bss*) *(COMMON) }

    . = ALIGN(8);
    stack_top = . + 128K;
}