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
