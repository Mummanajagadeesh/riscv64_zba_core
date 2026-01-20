//------------------------------------------------------------------------------
// File Name  : mux_SrcBE1.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the forwarding multiplexer for the second ALU source
// operand path in the execute stage. It selects the appropriate value for the
// WriteDataE signal, which is used both as the ALU source B input (prior to
// immediate selection) and as store write data.
//
// The multiplexer resolves data hazards by forwarding results from later
// pipeline stages, including explicit forwarding of load data.
//
// Key Features:
// - Selects register or forwarded data for source B path
// - Supports forwarding from MEM and WB stages
// - Enables load-data forwarding for dependent instructions
// - Purely combinational logic
//
// Assumptions & Notes:
// - ForwardBE encoding determines forwarding priority
// - Load data is forwarded when MemToRegM is asserted
// - Register x0 is excluded from forwarding
//------------------------------------------------------------------------------


module mux_SrcBE1 (
    input  [63:0] RD2E,          // Register file read data (EX stage)
    input  [63:0] ResultW,        // Writeback stage result
    input  [63:0] ALUResultM,     // ALU result from MEM stage
    input  [63:0] ReadDataM,      // Load data from data memory (MEM stage)
    input  [1:0]  ForwardBE,      // Forwarding control for source B
    input         MemToRegM,      // Indicates load instruction in MEM stage
    output [63:0] WriteDataE      // Selected data for ALU B input / store data
);

  // --------------------------------------------------
  // Source B forwarding and selection logic
  // --------------------------------------------------
  // Selects the most recent value for the second source
  // operand based on forwarding requirements:
  //   00 : Use register file value
  //   01 : Forward from WB stage
  //   10 : Forward from MEM stage
  //
  // When forwarding from MEM stage, load data is selected
  // if MemToRegM is asserted; otherwise ALUResultM is used.
  assign WriteDataE =
      (ForwardBE == 2'b00) ? RD2E      :  // No forwarding
      (ForwardBE == 2'b01) ? ResultW   :  // Forward from WB stage
      (MemToRegM)          ? ReadDataM // Forward load data from MEM
                             : ALUResultM; // Forward ALU result from MEM

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This module provides forwarding support for the second ALU operand path,
// ensuring correct data usage for dependent arithmetic, branch, and store
// instructions. By incorporating load-data forwarding, it eliminates hazards
// that would otherwise require pipeline stalls, contributing to efficient
// pipelined execution.
//------------------------------------------------------------------------------
