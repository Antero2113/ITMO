typedef unsigned long uint64;

#define UART_BASE 0x10000000
#define UART_LSR  (*(volatile unsigned char *)(UART_BASE + 5))
#define UART_THR  (*(volatile unsigned char *)(UART_BASE + 0))

void uart_putc(char c)
{
    while (!(UART_LSR & 0x20));
    UART_THR = c;
}

char uart_getc()
{
    while (!(UART_LSR & 0x01));
    return UART_THR;
}

void print(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

void print_hex(uint64 v)
{
    char hex[] = "0123456789ABCDEF";
    print("0x");
    for (int i = 15; i >= 0; i--)
        uart_putc(hex[(v >> (i * 4)) & 0xF]);
}

#define SBI_EXT_BASE 0x10
#define SBI_BASE_GET_IMP_VERSION 0x2

#define SBI_EXT_HSM 0x48534D
#define SBI_HART_GET_STATUS 0x0
#define SBI_HART_STOP 0x1

#define SBI_EXT_SRST 0x53525354
#define SBI_SYSTEM_RESET 0x0

static inline uint64 sbi_call(uint64 eid, uint64 fid,
                              uint64 arg0, uint64 arg1,
                              uint64 arg2, uint64 arg3,
                              uint64 arg4, uint64 arg5)
{
    register uint64 a0 asm("a0") = arg0;
    register uint64 a1 asm("a1") = arg1;
    register uint64 a2 asm("a2") = arg2;
    register uint64 a3 asm("a3") = arg3;
    register uint64 a4 asm("a4") = arg4;
    register uint64 a5 asm("a5") = arg5;
    register uint64 a6 asm("a6") = fid;
    register uint64 a7 asm("a7") = eid;

    asm volatile("ecall"
                 : "+r"(a0), "+r"(a1)
                 : "r"(a2), "r"(a3), "r"(a4), "r"(a5),
                   "r"(a6), "r"(a7)
                 : "memory");

    return a0;
}

void get_version()
{
    uint64 r = sbi_call(SBI_EXT_BASE,
                        SBI_BASE_GET_IMP_VERSION,
                        0,0,0,0,0,0);

    print("\nSBI Implementation Version: ");
    print_hex(r);
    print("\n");
}

void hart_get_status()
{
    print("\nEnter hart id (0-9): ");

    char c = uart_getc();
    uart_putc(c);

    int hart = c - '0';

    uint64 r = sbi_call(SBI_EXT_HSM,
                        SBI_HART_GET_STATUS,
                        hart,0,0,0,0,0);

    print("\nHart status: ");
    print_hex(r);
    print("\n");
}

void hart_stop()
{
    print("\nStopping hart...\n");

    sbi_call(SBI_EXT_HSM,
             SBI_HART_STOP,
             0,0,0,0,0,0);

    print("Hart stopped.\n");
}

void system_shutdown()
{
    print("\nShutdown...\n");

    sbi_call(SBI_EXT_SRST,
             SBI_SYSTEM_RESET,
             0,0,0,0,0,0);
}

void main()
{
    while (1)
    {
        print("\n");
        print("1. Get SBI implementation version\n");
        print("2. Hart get status\n");
        print("3. Hart stop\n");
        print("4. System Shutdown\n");
        print("Choose: ");

        char c = uart_getc();
        uart_putc(c);
        print("\n");

        if (c == '1') get_version();
        else if (c == '2') hart_get_status();
        else if (c == '3') hart_stop();
        else if (c == '4') system_shutdown();
        else print("Invalid option!\n");
    }
}