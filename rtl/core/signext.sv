//------------------------------------------------------------------------------
// File Name  : signext.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module generates sign-extended or zero-extended immediate values
// based on instruction format encoding. It supports multiple immediate
// types used across arithmetic, memory, and control-flow instructions.
//
// Key Features:
// - Supports I, S, B, U, and J immediate formats
// - Proper sign-extension for signed immediates
// - Combinational immediate generation
//
// Assumptions & Notes:
// - Immediate field is pre-extracted from instruction bits [31:7]
// - Immediate selection is controlled by Imm_SrcD
//------------------------------------------------------------------------------


module sign_ext ( 
    input  [2:0]  Imm_SrcD,    // Immediate format select
    input  [24:0] Imm,         // Raw immediate field from instruction
    output reg [63:0] ExtImmD  // Sign-extended immediate output
);

  // --------------------------------------------------
  // Immediate generation logic
  // --------------------------------------------------
  // Generates extended immediate values based on the
  // instruction format encoding.
  always @(*) begin
    case (Imm_SrcD)

      // ---------------- I-type ----------------
      // 12-bit signed immediate
      3'b000: ExtImmD = {{52{Imm[24]}}, Imm[24:13]};

      // ---------------- S-type ----------------
      // 12-bit signed immediate (split encoding)
      3'b001: ExtImmD = {{52{Imm[24]}}, Imm[24:18], Imm[4:0]};

      // ---------------- B-type ----------------
      // 13-bit signed immediate, LSB is always zero
      3'b010: ExtImmD = {{51{Imm[24]}}, Imm[0], Imm[23:18], Imm[4:1], 1'b0};

      // ---------------- U-type ----------------
      // Upper immediate, zero-extended
      3'b011: ExtImmD = {Imm[24:5], 44'b0};

      // ---------------- J-type ----------------
      // 21-bit signed immediate, LSB is always zero
      3'b100: ExtImmD = {{43{Imm[24]}}, Imm[12:5], Imm[13], Imm[23:14], 1'b0};

      // Unsupported immediate type
      default: ExtImmD = 64'bx;

    endcase
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This immediate generation unit decodes and extends instruction immediates
// for use in arithmetic operations, memory addressing, and control-flow
// target calculations, enabling flexible instruction encoding support.
//------------------------------------------------------------------------------
