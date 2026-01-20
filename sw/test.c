__attribute__((naked))
void _start() {
    asm volatile(
        "li x1, 5\n"
        "li x2, 3\n"

        ".insn r 0x33, 0x2, 0x04, x3, x1, x2\n"
        ".insn r 0x33, 0x4, 0x04, x4, x1, x2\n"
        ".insn r 0x33, 0x6, 0x04, x5, x1, x2\n"
        ".insn r 0x33, 0x0, 0x04, x6, x1, x2\n"

        "1: j 1b\n"
    );
}
