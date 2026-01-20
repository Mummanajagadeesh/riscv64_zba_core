//------------------------------------------------------------------------------
// File Name  : reglayer_two.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the pipeline register between the Instruction Decode
// (ID) and Execute (EX) stages. It latches operand values, immediate data,
// instruction fields, and all relevant control signals required for execution.
//
// Key Features:
// - ID/EX pipeline register implementation
// - Synchronous latching of data and control signals
// - Execute-stage flush support for control hazard handling
// - Clean reset behavior
//
// Assumptions & Notes:
// - FlushE takes priority along with reset to invalidate execute-stage state
// - Inputs are assumed stable at the rising edge of the clock
//------------------------------------------------------------------------------


`timescale 1ns / 1ns

module reglayer_two (
    input  [63:0] PCD,           // PC from decode stage
    input  [63:0] ExtImmD,        // Sign-extended immediate (decode stage)
    input  [63:0] PCPlus4D,       // PC + 4 (decode stage)
    input  [63:0] RD1,            // Register file read data 1
    input  [63:0] RD2,            // Register file read data 2
    input  [4:0]  A3,             // Destination register index
    input  [4:0]  A1,             // Source register 1 index
    input  [4:0]  A2,             // Source register 2 index
    input  [2:0]  funct3,         // funct3 field
    input         rst,             // Reset
    input         clk,             // Clock
    input         RegWriteD,       // Register write enable (decode stage)
    input         MemWriteD,       // Memory write enable (decode stage)
    input         JumpD,           // Jump control (decode stage)
    input         BranchD,         // Branch control (decode stage)
    input         ALUSrcD,         // ALU source select (decode stage)
    input         FlushE,          // Execute stage flush
    input  [1:0]  ResultSrcD,      // Result source select (decode stage)
    input  [3:0]  ALUControlD,     // ALU control (decode stage)
    input  [6:0]  OPD,             // Opcode field (decode stage)

    output reg        RegWriteE,   // Register write enable (execute stage)
    output reg        MemWriteE,   // Memory write enable (execute stage)
    output reg        JumpE,       // Jump control (execute stage)
    output reg        BranchE,     // Branch control (execute stage)
    output reg        ALUSrcE,     // ALU source select (execute stage)
    output reg [1:0]  ResultSrcE,  // Result source select (execute stage)
    output reg [3:0]  ALUControlE, // ALU control (execute stage)
    output reg [63:0] PCE,         // PC (execute stage)
    output reg [63:0] ExtImmE,     // Immediate value (execute stage)
    output reg [63:0] PCPlus4E,    // PC + 4 (execute stage)
    output reg [63:0] RD1E,        // Operand 1 (execute stage)
    output reg [63:0] RD2E,        // Operand 2 (execute stage)
    output reg [2:0]  funct3E,     // funct3 field (execute stage)
    output reg [4:0]  RdE,         // Destination register (execute stage)
    output reg [4:0]  Rs1E,        // Source register 1 (execute stage)
    output reg [4:0]  Rs2E,        // Source register 2 (execute stage)
    output reg [6:0]  OPE          // Opcode field (execute stage)
);

  // --------------------------------------------------
  // ID / EX pipeline register
  // --------------------------------------------------
  // Latches decode-stage outputs into the execute stage.
  // Reset or execute-stage flush clears all latched state.
  always @(posedge clk) begin
    if (rst || FlushE) begin
      RegWriteE   <= 1'b0;
      MemWriteE   <= 1'b0;
      JumpE       <= 1'b0;
      BranchE     <= 1'b0;
      ALUSrcE     <= 1'b0;
      ResultSrcE  <= 2'b00;
      ALUControlE <= 4'b0000;
      PCE         <= 64'd0;
      ExtImmE     <= 64'd0;
      PCPlus4E    <= 64'd0;
      RD1E        <= 64'd0;
      RD2E        <= 64'd0;
      funct3E     <= 3'd0;
      RdE         <= 5'd0;
      Rs1E        <= 5'd0;
      Rs2E        <= 5'd0;
      OPE         <= 7'd0;
    end else begin
      RegWriteE   <= RegWriteD;
      MemWriteE   <= MemWriteD;
      JumpE       <= JumpD;
      BranchE     <= BranchD;
      ALUSrcE     <= ALUSrcD;
      ResultSrcE  <= ResultSrcD;
      ALUControlE <= ALUControlD;
      PCE         <= PCD;
      ExtImmE     <= ExtImmD;
      PCPlus4E    <= PCPlus4D;
      RD1E        <= RD1;
      RD2E        <= RD2;
      funct3E     <= funct3;
      RdE         <= A3;
      Rs1E        <= A1;
      Rs2E        <= A2;
      OPE         <= OPD;
    end
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This ID/EX pipeline register forms the boundary between instruction decode
// and execution. It ensures all required operands, immediates, and control
// signals are correctly synchronized and supports execute-stage flushing
// to maintain precise control-flow behavior.
//------------------------------------------------------------------------------
