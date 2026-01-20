//------------------------------------------------------------------------------
// File Name  : PCPlus4_adder.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module computes the sequential next program counter value by
// incrementing the current PC by 4 bytes, corresponding to the size
// of a single instruction.
//
// Key Features:
// - 64-bit PC increment logic
// - Combinational adder
// - Used for sequential instruction execution
//
// Assumptions & Notes:
// - Instructions are fixed-width and 32 bits
// - PC is byte-addressed
//------------------------------------------------------------------------------


module PCPlus4_adder (
    input  [63:0] PCF,          // Current program counter
    output [63:0] PCPlus4F       // PC incremented by 4
);

  // --------------------------------------------------
  // PC increment logic
  // --------------------------------------------------
  // Adds 4 bytes to the current PC to generate the
  // sequential next instruction address.
  assign PCPlus4F = PCF + 64'd4;

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This adder generates the sequential PC value used during normal instruction
// flow when no branch or jump is taken.
//------------------------------------------------------------------------------
