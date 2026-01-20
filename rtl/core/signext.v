module sign_ext (
    input  [2:0]  Imm_SrcD,
    input  [24:0] Imm,
    output reg [63:0] ExtImmD
);
  always @(*) begin
    case (Imm_SrcD)

      // I-type (12-bit signed)
      3'b000: ExtImmD = {{52{Imm[24]}}, Imm[24:13]};

      // S-type (12-bit signed)
      3'b001: ExtImmD = {{52{Imm[24]}}, Imm[24:18], Imm[4:0]};

      // B-type (13-bit signed, LSB = 0)
      3'b010: ExtImmD = {{51{Imm[24]}}, Imm[0], Imm[23:18], Imm[4:1], 1'b0};

      // U-type (upper immediate, zero-extended)
      3'b011: ExtImmD = {Imm[24:5], 44'b0};

      // J-type (21-bit signed, LSB = 0)
      3'b100: ExtImmD = {{43{Imm[24]}}, Imm[12:5], Imm[13], Imm[23:14], 1'b0};

      default: ExtImmD = 64'bx;

    endcase
  end
endmodule
