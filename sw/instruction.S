.section .text
.globl _start
_start:
    li x1, 5
    li x2, 3

    .insn r 0x33, 0x2, 0x04, x3, x1, x2

    .insn r 0x33, 0x4, 0x04, x4, x1, x2

    .insn r 0x33, 0x6, 0x04, x5, x1, x2

    .insn r 0x33, 0x0, 0x04, x6, x1, x2

1:
    j 1b
