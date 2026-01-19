module execute (
    input  logic [63:0] rs1_data,
    input  logic [63:0] rs2_data,
    input  logic [63:0] imm_i,
    input  logic [63:0] imm_s,
    input  logic [63:0] imm_b,

    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,

    output logic [63:0] alu_result,
    output logic [63:0] store_data,
    output logic        mem_we,
    output logic        mem_to_reg,
    output logic        rd_we,

    output logic        branch_taken,
    output logic [63:0] branch_offset
);

    logic [63:0] zba_result;
    logic        is_zba;

    assign store_data    = rs2_data;
    assign branch_offset = imm_b;

    assign is_zba = (opcode == 7'b0110011) &&
                    (funct7 == 7'b0000100);

    zba_unit zba (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .funct3(funct3),
        .result(zba_result)
    );

    always_comb begin
        // ---------------------
        // defaults (CRITICAL)
        // ---------------------
        alu_result   = 64'b0;
        mem_we       = 1'b0;
        mem_to_reg   = 1'b0;
        rd_we        = 1'b0;
        branch_taken = 1'b0;

        case (opcode)

            // =====================
            // R-TYPE
            // =====================
            7'b0110011: begin
                rd_we = 1'b1;
                if (is_zba)
                    alu_result = zba_result;
                else begin
                    case (funct3)
                        3'b000: alu_result =
                            (funct7 == 7'b0100000)
                            ? rs1_data - rs2_data
                            : rs1_data + rs2_data;
                        3'b111: alu_result = rs1_data & rs2_data;
                        3'b110: alu_result = rs1_data | rs2_data;
                        default: alu_result = 64'b0;
                    endcase
                end
            end

            // =====================
            // ADDI
            // =====================
            7'b0010011: begin
                if (funct3 == 3'b000) begin
                    alu_result = rs1_data + imm_i;
                    rd_we      = 1'b1;
                end
            end

            // =====================
            // LOAD (LD)
            // =====================
            7'b0000011: begin
                alu_result = rs1_data + imm_i;
                mem_to_reg = 1'b1;
                rd_we      = 1'b1;
            end

            // =====================
            // STORE (SD)
            // =====================
            7'b0100011: begin
                alu_result = rs1_data + imm_s;
                mem_we     = 1'b1;
            end

            // =====================
            // BRANCH (BEQ / BNE)
            // =====================
            7'b1100011: begin
                case (funct3)
                    3'b000: branch_taken = (rs1_data == rs2_data); // BEQ
                    3'b001: branch_taken = (rs1_data != rs2_data); // BNE
                    default: branch_taken = 1'b0;
                endcase
            end

            default: ;
        endcase
    end

endmodule
