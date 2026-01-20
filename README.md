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

