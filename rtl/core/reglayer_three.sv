//------------------------------------------------------------------------------
// File Name  : reglayer_three.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the pipeline register between the Execute (EX)
// and Memory (MEM) stages. It latches ALU results, store data, immediate
// values, and associated control signals required for memory access and
// write-back preparation.
//
// Key Features:
// - EX/MEM pipeline register implementation
// - Synchronous latching of data and control signals
// - Clean reset behavior
// - Pass-through of execution results
//
// Assumptions & Notes:
// - Inputs are stable at the rising edge of the clock
// - Reset clears all pipeline state to safe defaults
//------------------------------------------------------------------------------


module reglayer_three (
    input  [63:0] WriteDataE,   // Store data from execute stage
    input  [63:0] ALUResult,    // ALU computation result
    input  [63:0] PCPlus4E,     // PC + 4 from execute stage
    input  [4:0]  RdE,          // Destination register (execute stage)
    input         clk,           // Clock
    input         rst,           // Reset
    input         RegWriteE,     // Register write enable (execute stage)
    input         MemWriteE,     // Memory write enable (execute stage)
    input  [1:0]  ResultSrcE,   // Result source select (execute stage)
    input  [63:0] ExtImmE,       // Immediate value (execute stage)

    output reg [63:0] ALUResultM,// ALU result (memory stage)
    output reg [63:0] WriteDataM,// Store data (memory stage)
    output reg [63:0] PCPlus4M,  // PC + 4 (memory stage)
    output reg [4:0]  RdM,       // Destination register (memory stage)
    output reg        RegWriteM, // Register write enable (memory stage)
    output reg        MemWriteM, // Memory write enable (memory stage)
    output reg [1:0]  ResultSrcM,// Result source select (memory stage)
    output reg [63:0] ExtImmM    // Immediate value (memory stage)
);

  // --------------------------------------------------
  // EX / MEM pipeline register
  // --------------------------------------------------
  // Captures execute-stage outputs and control signals
  // on the rising edge of the clock.
  always @(posedge clk) begin
    if (rst) begin
      RegWriteM  <= 1'b0;
      MemWriteM  <= 1'b0;
      ResultSrcM <= 2'b00;
      ALUResultM <= 64'd0;
      WriteDataM <= 64'd0;
      RdM        <= 5'd0;
      PCPlus4M   <= 64'd0;
      ExtImmM    <= 64'd0;
    end else begin
      RegWriteM  <= RegWriteE;
      MemWriteM  <= MemWriteE;
      ResultSrcM <= ResultSrcE;
      ALUResultM <= ALUResult;
      WriteDataM <= WriteDataE;
      RdM        <= RdE;
      PCPlus4M   <= PCPlus4E;
      ExtImmM    <= ExtImmE;
    end
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This EX/MEM pipeline register transfers execution results and control
// information into the memory stage, enabling correct memory access and
// seamless progression toward write-back.
//------------------------------------------------------------------------------
