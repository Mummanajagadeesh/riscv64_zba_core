__attribute__((naked))
void _start() {
    asm volatile(

        "li x1, 5\n"
        "li x2, 3\n"

        ".insn r 0x33, 0x2, 0x04, x3, x1, x2\n"  // sh1add -> 11
        ".insn r 0x33, 0x4, 0x04, x4, x1, x2\n"  // sh2add -> 17
        ".insn r 0x33, 0x6, 0x04, x5, x1, x2\n"  // sh3add -> 29
        ".insn r 0x33, 0x0, 0x04, x6, x1, x2\n"  // add.uw -> 8

        "sd x5, 0(x0)\n"        // mem[0] = 29
        "ld x7, 0(x0)\n"        // x7 <- mem[0]

        "beq x7, x5, 1f\n"
        "li x7, 0\n"            // must NOT execute

        "1:\n"
        "j 1b\n"
    );
}
