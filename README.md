# RV64I-Zba Pipelined RISC-V Core

This repository contains a synthesizable 64-bit RISC-V processor core implementing<br>
the **RV64I base integer instruction set** along with the **Zba address generation<br>
extension**.

## Overview
- 5-stage pipelined microarchitecture (IF, ID, EX, MEM, WB)
- Separate instruction and data memories
- Supports standard RV64I arithmetic, logical, load/store, and branch instructions
- Implements Zba instructions: `sh1add`, `sh2add`, `sh3add`, and `add.uw`
- Designed and implemented in **SystemVerilog**

## Verification
- Self-checking SystemVerilog testbench
- Runtime memory monitoring and register assertions
- Waveform generation for debug and analysis

## Toolchain & Build
- Compatible with **RISC-V GNU toolchain**
- Software-to-hardware flow documented in [`build_commands.md`](build_commands.md)

## Documentation
- Design notes and architectural details available at [`docs/design_notes.md`](docs/design_notes.md)

## Status
All core features verified through simulation with passing self-checking tests.
