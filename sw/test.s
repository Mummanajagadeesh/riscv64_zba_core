	.file	"test.c"
	.option nopic
	.attribute arch, "rv64i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
 #APP
# 3 "sw/test.c" 1
	li x1, 5
li x2, 3
.insn r 0x33, 0x2, 0x04, x3, x1, x2
.insn r 0x33, 0x4, 0x04, x4, x1, x2
.insn r 0x33, 0x6, 0x04, x5, x1, x2
.insn r 0x33, 0x0, 0x04, x6, x1, x2
sd x5, 0(x0)
ld x7, 0(x0)
beq x7, x5, 1f
li x7, 0
1:
j 1b

# 0 "" 2
 #NO_APP
	nop
	.size	_start, .-_start
	.ident	"GCC: () 9.3.0"
