	.file	"test.c"
	.option nopic
	.attribute arch, "rv64i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.comm	x1,8,8
	.comm	x2,8,8
	.comm	x3,8,8
	.comm	x4,8,8
	.comm	x5,8,8
	.comm	x6,8,8
	.comm	x7,8,8
	.comm	mem,32,8
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-16
	sd	s0,8(sp)
	addi	s0,sp,16
	lui	a5,%hi(x1)
	li	a4,5
	sd	a4,%lo(x1)(a5)
	lui	a5,%hi(x2)
	li	a4,3
	sd	a4,%lo(x2)(a5)
	lui	a5,%hi(x1)
	ld	a5,%lo(x1)(a5)
	lui	a4,%hi(x2)
	ld	a4,%lo(x2)(a4)
 #APP
# 9 "sw/test.c" 1
	.insn r 0x33, 0, 0x2, a4, a5, a4
# 0 "" 2
 #NO_APP
	lui	a5,%hi(x3)
	sd	a4,%lo(x3)(a5)
	lui	a5,%hi(x1)
	ld	a5,%lo(x1)(a5)
	lui	a4,%hi(x2)
	ld	a4,%lo(x2)(a4)
 #APP
# 13 "sw/test.c" 1
	.insn r 0x33, 0, 0x4, a4, a5, a4
# 0 "" 2
 #NO_APP
	lui	a5,%hi(x4)
	sd	a4,%lo(x4)(a5)
	lui	a5,%hi(x1)
	ld	a5,%lo(x1)(a5)
	lui	a4,%hi(x2)
	ld	a4,%lo(x2)(a4)
 #APP
# 17 "sw/test.c" 1
	.insn r 0x33, 0, 0x6, a4, a5, a4
# 0 "" 2
 #NO_APP
	lui	a5,%hi(x5)
	sd	a4,%lo(x5)(a5)
	lui	a5,%hi(x1)
	ld	a5,%lo(x1)(a5)
	lui	a4,%hi(x2)
	ld	a4,%lo(x2)(a4)
 #APP
# 21 "sw/test.c" 1
	.insn r 0x33, 0, 0x0, a4, a5, a4
# 0 "" 2
 #NO_APP
	lui	a5,%hi(x6)
	sd	a4,%lo(x6)(a5)
	lui	a5,%hi(x5)
	ld	a4,%lo(x5)(a5)
	lui	a5,%hi(mem)
	addi	a5,a5,%lo(mem)
	sd	a4,0(a5)
	lui	a5,%hi(mem)
	addi	a5,a5,%lo(mem)
	ld	a4,0(a5)
	lui	a5,%hi(x7)
	sd	a4,%lo(x7)(a5)
	lui	a5,%hi(x7)
	ld	a4,%lo(x7)(a5)
	lui	a5,%hi(x5)
	ld	a5,%lo(x5)(a5)
	bne	a4,a5,.L2
	lui	a5,%hi(x7)
	li	a4,1
	sd	a4,%lo(x7)(a5)
	j	.L3
.L2:
	lui	a5,%hi(x7)
	sd	zero,%lo(x7)(a5)
.L3:
	j	.L3
	.size	_start, .-_start
	.ident	"GCC: () 9.3.0"
