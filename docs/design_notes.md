# Design Notes – RV64I + Zba Pipelined Core

## Design Goals
The primary goal of this design is to implement a clean and understandable<br>
RISC-V RV64I processor core with support for the Zba address generation<br>
extension. Emphasis was placed on correctness, architectural clarity, and<br>
hardware/software co-verification rather than aggressive optimization.<br>

A classic 5-stage pipeline was chosen to balance simplicity with realistic<br>
processor behavior, making the design easy to reason about and verify.

---

## Pipeline Organization
The processor follows a conventional 5-stage pipeline:
- Instruction Fetch (IF)
- Instruction Decode / Register Fetch (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)

This structure cleanly separates concerns such as instruction sequencing,<br>
operand preparation, computation, and architectural state updates. Each stage<br>
communicates through explicit pipeline registers, which simplifies hazard<br>
handling and debugging.

---

## Instruction Fetch and Program Control
The fetch stage is responsible for maintaining the program counter and supplying<br>
instructions from instruction memory. A dedicated PC update path supports<br>
sequential execution, branch targets, and jump targets.

Branch and jump decisions are resolved in the execute stage. When a control-flow<br>
change occurs, earlier pipeline stages are flushed to prevent incorrect-path<br>
instructions from updating architectural state.

---

## Decode and Register File
Instruction decode extracts register indices, immediates, and control fields<br>
from the instruction word. A centralized controller generates all required<br>
control signals based on opcode and function fields.

The register file provides two read ports and one write port, with x0 hardwired<br>
to zero. Write-back occurs synchronously, while reads are combinational, allowing<br>
efficient operand availability in the execute stage.

---

## Immediate Generation
A dedicated sign-extension unit handles all immediate formats defined by RV64I.<br>
Separating immediate generation from decode logic keeps the datapath modular and<br>
simplifies future ISA extensions.

---

## Execute Stage and ALU
The execute stage performs arithmetic, logical, comparison, and address<br>
calculations. The ALU supports standard RV64I operations as well as Zba<br>
instructions, which are implemented as shift-and-add operations.

Zba instructions were integrated directly into the ALU rather than treated as<br>
special cases, preserving a uniform execution model and minimizing control<br>
complexity.

Branch condition evaluation is also performed in this stage, allowing branch<br>
decisions to be made with minimal latency.

---

## Memory Access
Instruction and data memories are kept strictly separate. Data memory supports<br>
synchronous writes and combinational reads, modeling a simple single-cycle memory<br>
interface suitable for simulation and verification.

Load and store address generation reuses the ALU, reinforcing the relevance of<br>
Zba instructions for efficient address computation.

---

## Write Back
The write-back stage selects between ALU results, load data, PC-relative values,<br>
and immediates depending on instruction type. A centralized result multiplexer<br>
ensures that all architectural state updates occur in a single, well-defined<br>
stage.

---

## Hazard Detection and Forwarding
To support pipelined execution, the design includes explicit hazard detection and<br>
data forwarding logic. Forwarding paths allow results from later pipeline stages<br>
to be reused without stalling whenever possible.

Load-use hazards are detected and handled via controlled stalls. Control hazards<br>
introduced by branches and jumps are handled through targeted pipeline flushes,<br>
ensuring that incorrect-path instructions do not commit results.

---

## Zba Extension Support
The Zba extension was chosen because it naturally fits into address generation<br>
and showcases how RISC-V extensions can be integrated without disrupting the<br>
base architecture.

Instructions such as `sh1add`, `sh2add`, `sh3add`, and `add.uw` are implemented<br>
using existing ALU structures, demonstrating extensibility with minimal<br>
additional hardware.

---

## Verification Strategy
Verification is performed using a self-checking SystemVerilog testbench. The<br>
testbench drives clock and reset, initializes instruction memory, monitors data<br>
memory activity, and validates final register state through assertions.<br>

A small C test program is compiled using the RISC-V GNU toolchain and executed on<br>
the core, providing end-to-end hardware/software validation.

---

## Design Philosophy
This core prioritizes clarity, correctness, and architectural soundness. Each<br>
module has a well-defined responsibility, and interactions between components<br>
are explicit and traceable. The result is a design that is easy to extend, debug,<br>
and reason about, while still reflecting realistic pipelined processor behavior.
