//------------------------------------------------------------------------------
// File Name  : pc_mux.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the program counter (PC) selection multiplexer.
// It chooses the next PC value based on control-flow decisions such as
// sequential execution, taken branches, and jump instructions.
//
// Key Features:
// - Supports sequential PC increment
// - Handles branch target selection
// - Handles jump target selection
// - Combinational PC selection logic
//
// Assumptions & Notes:
// - PCSrcE encoding is generated in the execute stage
// - ALUResultM is used for indirect jump target computation
//------------------------------------------------------------------------------


module pc_mux (
    input  [63:0] PCPlus4F,     // PC + 4 (sequential execution)
    input  [63:0] PCTargetE,    // Branch or jump target address
    input  [63:0] ALUResultM,   // Indirect jump target address
    input  [1:0]  PCSrcE,       // PC source select control
    output [63:0] PCnext        // Next program counter value
);

  // --------------------------------------------------
  // PC selection logic
  // --------------------------------------------------
  // Selects the appropriate next PC value based on
  // control-flow resolution.
  assign PCnext =
      (PCSrcE == 2'b00) ? PCPlus4F  :  // Sequential execution
      (PCSrcE == 2'b01) ? PCTargetE :  // Branch or direct jump
                          ALUResultM; // Indirect jump (e.g., register-based)

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This PC multiplexer directs instruction flow by selecting the correct
// next program counter value after resolving control-flow decisions in
// the execute stage.
//------------------------------------------------------------------------------
