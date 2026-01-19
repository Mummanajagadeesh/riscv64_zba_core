module execute (
    input  logic [63:0] rs1_data,
    input  logic [63:0] rs2_data,
    input  logic [63:0] imm,

    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,

    output logic [63:0] alu_result
);

    logic [63:0] zba_result;
    logic        is_zba;

    // Zba detection (OP opcode + funct7 = 0000100)
    assign is_zba = (opcode == 7'b0110011) && (funct7 == 7'b0000100);

    zba_unit zba (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .funct3(funct3),
        .result(zba_result)
    );

    always_comb begin
        alu_result = 64'b0;

        if (is_zba) begin
            alu_result = zba_result;
        end else begin
            case (opcode)
                7'b0110011: begin // R-type
                    case (funct3)
                        3'b000: alu_result = (funct7 == 7'b0100000) ? rs1_data - rs2_data : rs1_data + rs2_data;
                        3'b111: alu_result = rs1_data & rs2_data;
                        3'b110: alu_result = rs1_data | rs2_data;
                        default: alu_result = 64'b0;
                    endcase
                end

                7'b0010011: begin // I-type
                    alu_result = rs1_data + imm;
                end

                default: alu_result = 64'b0;
            endcase
        end
    end

endmodule
