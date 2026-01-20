//------------------------------------------------------------------------------
// File Name  : instmem.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the instruction memory used during the instruction
// fetch stage. It provides a read-only memory interface that outputs a
// 32-bit instruction based on the current program counter value.
//
// Key Features:
// - Read-only instruction memory
// - Word-aligned instruction access
// - Memory initialization from external file
// - Combinational instruction fetch behavior
//
// Assumptions & Notes:
// - Program counter is byte-addressed
// - Instructions are 32-bit and word-aligned
// - No instruction cache or access latency modeled
//------------------------------------------------------------------------------


module Instruction_Memory (
    input  [63:0] PCF,              // Program counter (byte address)
    output reg [31:0] instruction   // Fetched instruction
);

  // Internal instruction memory array
  reg [31:0] instructions_Value[0:999];

  // --------------------------------------------------
  // Memory initialization
  // --------------------------------------------------
  // Loads instruction contents from an external hex file
  // at the start of simulation.
  initial begin
    $readmemh("instruction.mem", instructions_Value);
  end

  // --------------------------------------------------
  // Combinational instruction fetch
  // --------------------------------------------------
  // Instruction address is word-aligned by discarding
  // the lower two bits of the program counter.
  always @(*) begin
    instruction = instructions_Value[PCF[31:2]]; // Equivalent to PCF >> 2
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This instruction memory module supplies instructions to the fetch stage
// using a simple combinational read model. It assumes word-aligned instruction
// access and is suitable for simulation and single-cycle fetch behavior.
//------------------------------------------------------------------------------
