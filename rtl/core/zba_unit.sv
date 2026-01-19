module zba_unit (
    input  logic [63:0] rs1,
    input  logic [63:0] rs2,
    input  logic [2:0] funct3,
    output logic [63:0] result
);
    always_comb begin
        case (funct3)
            3'b010: result = rs1 + (rs2 << 1); // SH1ADD
            3'b100: result = rs1 + (rs2 << 2); // SH2ADD
            3'b110: result = rs1 + (rs2 << 3); // SH3ADD
            default: result = 64'b0;
        endcase
    end
endmodule
