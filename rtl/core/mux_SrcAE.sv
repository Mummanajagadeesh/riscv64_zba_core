//------------------------------------------------------------------------------
// File Name  : mux_SrcAE.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the forwarding multiplexer for the ALU source A input
// in the execute stage. It selects the appropriate operand value based on
// forwarding control signals to resolve data hazards in a pipelined processor.
//
// The mux supports forwarding from the MEM and WB stages and includes explicit
// handling for load-result forwarding from the data memory.
//
// Key Features:
// - Selects ALU operand A for the execute stage
// - Supports forwarding from MEM and WB stages
// - Enables load-data forwarding for branch comparisons
// - Purely combinational implementation
//
// Assumptions & Notes:
// - ForwardAE encoding determines priority between WB and MEM forwarding
// - Load data forwarding is enabled when MemToRegM is asserted
// - Register file values are used when no hazard is detected
//------------------------------------------------------------------------------


module mux_SrcAE (
    input  [63:0] RD1E,          // Register file read data (EX stage)
    input  [63:0] ResultW,        // Writeback stage result
    input  [63:0] ALUResultM,     // ALU result from MEM stage
    input  [63:0] ReadDataM,      // Load data from data memory (MEM stage)
    input  [1:0]  ForwardAE,      // Forwarding control for source A
    input         MemToRegM,      // Indicates load instruction in MEM stage
    output [63:0] SrcAE           // Selected ALU source A operand
);

  // --------------------------------------------------
  // ALU source A selection logic
  // --------------------------------------------------
  // Selects the appropriate operand for the ALU based
  // on forwarding requirements:
  //   00 : Use register file value
  //   01 : Forward from WB stage
  //   10 : Forward from MEM stage (ALU or load data)
  //
  // When forwarding from MEM stage, load data is selected
  // if MemToRegM is asserted; otherwise ALUResultM is used.
  assign SrcAE =
      (ForwardAE == 2'b00) ? RD1E      :  // No forwarding
      (ForwardAE == 2'b01) ? ResultW   :  // Forward from WB stage
      (MemToRegM)          ? ReadDataM // Forward load data from MEM
                             : ALUResultM; // Forward ALU result from MEM

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This forwarding multiplexer ensures that the execute stage receives the most
// up-to-date operand value for source A by bypassing results from later pipeline
// stages when required. It plays a critical role in resolving data hazards and
// enables correct branch evaluation when dependent on recently loaded data.
//------------------------------------------------------------------------------
