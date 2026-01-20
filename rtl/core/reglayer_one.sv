//------------------------------------------------------------------------------
// File Name  : reglayer_one.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the pipeline register between the Instruction Fetch
// (IF) and Instruction Decode (ID) stages. It latches the fetched instruction
// and associated PC values while supporting stalling and flushing mechanisms.
//
// Key Features:
// - IF/ID pipeline register implementation
// - Support for decode-stage stall
// - Support for decode-stage flush
// - Synchronous reset behavior
//
// Assumptions & Notes:
// - Stall takes priority over flush
// - Reset clears all latched values
//------------------------------------------------------------------------------


module reglayer_one (
    input         rst,              // Reset
    input         clk,              // Clock
    input         StallD,            // Decode stage stall
    input         FlushD,            // Decode stage flush
    input  [31:0] instruction,      // Fetched instruction
    input  [63:0] PCF,              // Fetch-stage PC
    input  [63:0] PCPlus4F,          // PC + 4 (fetch stage)
    output reg [31:0] instructionD,  // Instruction (decode stage)
    output reg [63:0] PCD,           // PC (decode stage)
    output reg [63:0] PCPlus4D       // PC + 4 (decode stage)
);

  // --------------------------------------------------
  // IF / ID pipeline register
  // --------------------------------------------------
  // Latches instruction and PC values unless stalled
  // or flushed. Reset initializes all outputs.
  always @(posedge clk) begin
    if (rst) begin
      PCD          <= 64'd0;
      instructionD <= 32'd0;
      PCPlus4D     <= 64'd0;
    end else if (StallD) begin
      PCD          <= PCD;            // Hold state during stall
      instructionD <= instructionD;
      PCPlus4D     <= PCPlus4D;
    end else if (FlushD) begin
      PCD          <= 64'd0;
      instructionD <= 32'd0;
      PCPlus4D     <= 64'd0;
    end else begin
      instructionD <= instruction;   // Latch new instruction
      PCD          <= PCF;
      PCPlus4D     <= PCPlus4F;
    end
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This IF/ID pipeline register enables controlled progression of instructions
// into the decode stage, supporting hazard resolution through stall and flush
// mechanisms to maintain correct program execution.
//------------------------------------------------------------------------------
