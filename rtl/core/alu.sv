module alu (
    input  logic [63:0] a,
    input  logic [63:0] b,
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [63:0] result
);

    always_comb begin
        result = 64'b0;
        case (opcode)
            7'b0110011: begin
                case (funct3)
                    3'b000: result = (funct7 == 7'b0100000) ? a - b : a + b;
                    3'b111: result = a & b;
                    3'b110: result = a | b;
                endcase
            end
        endcase
    end
endmodule
