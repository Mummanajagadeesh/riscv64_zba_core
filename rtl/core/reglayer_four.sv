//------------------------------------------------------------------------------
// File Name  : reglayer_four.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the pipeline register between the Memory (MEM)
// and Write-Back (WB) stages. It latches execution results, memory data,
// and control signals required for register write-back.
//
// Key Features:
// - MEM/WB pipeline register implementation
// - Synchronous signal latching
// - Clean reset behavior
// - Pass-through of data and control signals
//
// Assumptions & Notes:
// - All inputs are valid at the rising clock edge
// - Reset initializes pipeline registers to safe values
//------------------------------------------------------------------------------


module reglayer_four (
    input  [63:0] ALUResultM,   // ALU result from MEM stage
    input  [63:0] ReadData,     // Data memory read output
    input  [63:0] PCPlus4M,     // PC + 4 from MEM stage
    input  [4:0]  RdM,          // Destination register (MEM stage)
    input         rst,           // Reset
    input         clk,           // Clock
    input         RegWriteM,     // Register write enable (MEM stage)
    input  [1:0]  ResultSrcM,   // Result source select (MEM stage)
    input  [63:0] ExtImmM,       // Immediate value (MEM stage)

    output reg [63:0] ALUResultW,// ALU result (WB stage)
    output reg [63:0] ReadDataW, // Memory read data (WB stage)
    output reg [63:0] PCPlus4W,  // PC + 4 (WB stage)
    output reg [4:0]  RdW,       // Destination register (WB stage)
    output reg [1:0]  ResultSrcW,// Result source select (WB stage)
    output reg        RegWriteW, // Register write enable (WB stage)
    output reg [63:0] ExtImmW    // Immediate value (WB stage)
);

  // --------------------------------------------------
  // MEM / WB pipeline register
  // --------------------------------------------------
  // Latches data and control signals on the rising edge
  // of the clock. Reset clears all pipeline registers.
  always @(posedge clk) begin
    if (rst) begin
      ALUResultW <= 64'd0;
      ReadDataW  <= 64'd0;
      PCPlus4W   <= 64'd0;
      RdW        <= 5'd0;
      ResultSrcW <= 2'd0;
      RegWriteW  <= 1'b0;
      ExtImmW    <= 64'd0;
    end else begin
      ALUResultW <= ALUResultM;
      ReadDataW  <= ReadData;
      PCPlus4W   <= PCPlus4M;
      RdW        <= RdM;
      ResultSrcW <= ResultSrcM;
      RegWriteW  <= RegWriteM;
      ExtImmW    <= ExtImmM;
    end
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This MEM/WB pipeline register safely transfers execution results and control
// information into the write-back stage, ensuring correct register updates
// and architectural state consistency.
//------------------------------------------------------------------------------
