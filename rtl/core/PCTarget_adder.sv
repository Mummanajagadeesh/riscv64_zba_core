//------------------------------------------------------------------------------
// File Name  : PCTarget_adder.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module computes the target program counter value for control-flow
// instructions by adding a sign-extended immediate offset to the current
// execute-stage PC.
//
// Key Features:
// - 64-bit PC target address computation
// - Combinational adder
// - Used for branch and direct jump target generation
//
// Assumptions & Notes:
// - Immediate value is already sign-extended
// - PC value corresponds to the execute-stage PC
//------------------------------------------------------------------------------


module PCTarget_adder (
    input  [63:0] PCE,           // Execute-stage PC value
    input  [63:0] ExtImmE,        // Sign-extended immediate offset
    output [63:0] PCTargetE       // Computed target PC address
);

  // --------------------------------------------------
  // Target address computation
  // --------------------------------------------------
  // Adds the immediate offset to the current PC to
  // compute branch or jump target address.
  assign PCTargetE = PCE + ExtImmE;

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This module generates target addresses for control-flow instructions by
// combining the current PC with a sign-extended immediate offset, enabling
// correct branch and jump redirection.
//------------------------------------------------------------------------------
