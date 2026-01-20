//------------------------------------------------------------------------------
// File Name  : alu.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the Arithmetic Logic Unit (ALU) for the execute stage.
// It supports 64-bit arithmetic, logical, comparison, and branch-related
// operations. The design includes standard integer ALU functions along with
// extended operations required for address-generation style instructions.
//
// Key Features:
// - 64-bit arithmetic and logical operations
// - Signed and unsigned comparisons
// - Branch condition evaluation
// - Support for shifted-add based operations
//
// Assumptions & Notes:
// - All operations are purely combinational
// - Branch comparison is enabled only when BranchE is asserted
// - Signed comparisons use two's complement representation
//------------------------------------------------------------------------------


`timescale 1ns / 1ns

module alu (
    input  [63:0] SrcAE,          // Source operand A
    input  [63:0] SrcBE,          // Source operand B
    input  [3:0]  ALUControlE,    // ALU operation select
    input  [2:0]  funct3E,        // Instruction funct3 field (branch decoding)
    input         BranchE,        // Branch enable signal
    output [63:0] ALUResult,      // ALU computation result
    output reg    ZeroE           // Branch condition evaluation result
);

  // Internal register to hold ALU computation result
  reg [63:0] ALU_Result;

  // Drive output from internal result register
  assign ALUResult = ALU_Result;

  // --------------------------------------------------
  // Branch comparison logic
  // --------------------------------------------------
  // Evaluates branch conditions based on funct3 encoding.
  // ZeroE is asserted when the branch condition is satisfied.
  // When BranchE is deasserted, ZeroE is forced low.
  always @(*) begin
    if (!BranchE) begin
      ZeroE = 1'b0;
    end else begin
      case (funct3E)
        3'b000: ZeroE = (SrcAE == SrcBE);                   // BEQ  : equal
        3'b001: ZeroE = (SrcAE != SrcBE);                   // BNE  : not equal
        3'b100: ZeroE = ($signed(SrcAE) < $signed(SrcBE));  // BLT  : signed less than
        3'b101: ZeroE = ($signed(SrcAE) >= $signed(SrcBE)); // BGE  : signed greater or equal
        default: ZeroE = 1'b0;
      endcase
    end
  end

  // --------------------------------------------------
  // ALU operations
  // --------------------------------------------------
  // Performs arithmetic, logical, comparison, and extended
  // operations based on ALUControlE encoding.
  always @(*) begin
    case (ALUControlE)

      4'b0000: ALU_Result = SrcAE + SrcBE;                   // ADD
      4'b0001: ALU_Result = SrcAE - SrcBE;                   // SUB
      4'b0010: ALU_Result = SrcAE & SrcBE;                   // AND
      4'b0011: ALU_Result = SrcAE | SrcBE;                   // OR
      4'b0100: ALU_Result = ($signed(SrcAE) < $signed(SrcBE)) 
                             ? 64'd1 : 64'd0;               // SLT (signed)
      4'b0101: ALU_Result = SrcAE ^ SrcBE;                   // XOR

      // ---------------- Zba EXTENSION ----------------
      // Shift-and-add instructions commonly used for
      // address calculations and index scaling
      4'b1000: ALU_Result = SrcAE + (SrcBE << 1);            // SH1ADD
      4'b1001: ALU_Result = SrcAE + (SrcBE << 2);            // SH2ADD
      4'b1010: ALU_Result = SrcAE + (SrcBE << 3);            // SH3ADD
      4'b1011: ALU_Result = SrcAE + {32'b0, SrcBE[31:0]};    // ADD.UW
      // ------------------------------------------------

      // Default behavior falls back to addition
      default: ALU_Result = SrcAE + SrcBE;
    endcase
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This ALU module computes arithmetic and logical results for the execute stage
// and independently evaluates branch conditions. Branch comparisons are gated
// using BranchE to avoid unintended flag assertions. The design is fully
// combinational and suitable for high-frequency pipelined implementations.
//------------------------------------------------------------------------------
