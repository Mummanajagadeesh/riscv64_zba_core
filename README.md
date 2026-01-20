# RISC-V RV64I + Zba Core

5-stage pipelined RISC-V 64-bit processor implementing:
- RV64I base integer ISA
- Zba address generation extension

Features:
- Separate instruction & data memory
- Fully synthesizable SystemVerilog RTL
- Self-checking testbench
- C-based test program

Pipeline:
IF → ID → EX → MEM → WB


<!-- 
```
riscv64-unknown-elf-as sw/instruction.S -o instruction.o
riscv64-unknown-elf-objdump -d instruction.o
``` -->

```
riscv64-unknown-elf-gcc -ffreestanding -nostdlib -nostartfiles -march=rv64i -mabi=lp64 -S sw/test.c -o sw/test.s
riscv64-unknown-elf-as sw/test.s -o sw/test.o
riscv64-unknown-elf-ld -T sw/linker.ld --entry=_start sw/test.o -o sw/test.elf
riscv64-unknown-elf-objdump -d sw/test.elf | awk '/^[ ]*[0-9a-f]+:/ {print $2}' | sed '$d' > instruction.mem
```

