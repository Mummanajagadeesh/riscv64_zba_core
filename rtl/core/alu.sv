`timescale 1ns / 1ns

module alu (
    input  [63:0] SrcAE,
    input  [63:0] SrcBE,          // RV64 operands
    input  [3:0]  ALUControlE,    
    input  [2:0]  funct3E,
    input         BranchE,        
    output [63:0] ALUResult,
    output reg    ZeroE
);

  reg [63:0] ALU_Result;
  assign ALUResult = ALU_Result;

  // --------------------------------------------------
  // Branch comparison logic
  // --------------------------------------------------
  always @(*) begin
    if (!BranchE) begin
      ZeroE = 1'b0;
    end else begin
      case (funct3E)
        3'b000: ZeroE = (SrcAE == SrcBE);                   // beq
        3'b001: ZeroE = (SrcAE != SrcBE);                   // bne
        3'b100: ZeroE = ($signed(SrcAE) < $signed(SrcBE));  // blt
        3'b101: ZeroE = ($signed(SrcAE) >= $signed(SrcBE)); // bge
        default: ZeroE = 1'b0;
      endcase
    end
  end

  // --------------------------------------------------
  // ALU operations (RV64I + Zba)
  // --------------------------------------------------
  always @(*) begin
    case (ALUControlE)

      4'b0000: ALU_Result = SrcAE + SrcBE;                   // ADD
      4'b0001: ALU_Result = SrcAE - SrcBE;                   // SUB
      4'b0010: ALU_Result = SrcAE & SrcBE;                   // AND
      4'b0011: ALU_Result = SrcAE | SrcBE;                   // OR
      4'b0100: ALU_Result = ($signed(SrcAE) < $signed(SrcBE)) ? 64'd1 : 64'd0; // SLT
      4'b0101: ALU_Result = SrcAE ^ SrcBE;                   // XOR

      // ---------------- Zba EXTENSION ----------------
      4'b1000: ALU_Result = SrcAE + (SrcBE << 1);            // sh1add
      4'b1001: ALU_Result = SrcAE + (SrcBE << 2);            // sh2add
      4'b1010: ALU_Result = SrcAE + (SrcBE << 3);            // sh3add
      4'b1011: ALU_Result = SrcAE + {32'b0, SrcBE[31:0]};    // add.uw
      // ------------------------------------------------

      default: ALU_Result = SrcAE + SrcBE;
    endcase
  end

endmodule
