module execute (
    input  logic [63:0] rs1_data,
    input  logic [63:0] rs2_data,
    input  logic [63:0] imm_i,
    input  logic [63:0] imm_s,
    input  logic [63:0] imm_b,
    input  logic [63:0] imm_j,

    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,

    input  logic [63:0] pc,

    output logic [63:0] alu_result,
    output logic [63:0] store_data,
    output logic        mem_we,
    output logic        mem_to_reg,
    output logic        rd_we,

    output logic        branch_taken,
    output logic [63:0] branch_offset,

    output logic        jump_taken,
    output logic [63:0] jump_target
);

    logic [63:0] zba_result;
    logic        is_zba;

    assign store_data = rs2_data;

    assign is_zba = (opcode == 7'b0110011) &&
                    (funct7 == 7'b0000100);

    zba_unit zba (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .funct3(funct3),
        .result(zba_result)
    );

    always_comb begin
        alu_result   = 64'b0;
        mem_we       = 1'b0;
        mem_to_reg   = 1'b0;
        rd_we        = 1'b0;
        branch_taken = 1'b0;
        branch_offset= imm_b;
        jump_taken   = 1'b0;
        jump_target  = 64'b0;

        case (opcode)

            // R-type
            7'b0110011: begin
                rd_we = 1'b1;
                alu_result = is_zba ? zba_result :
                    (funct3 == 3'b000) ? 
                        ((funct7 == 7'b0100000) ? rs1_data - rs2_data
                                                : rs1_data + rs2_data)
                    : (funct3 == 3'b111) ? (rs1_data & rs2_data)
                    : (funct3 == 3'b110) ? (rs1_data | rs2_data)
                    : 64'b0;
            end

            // ADDI
            7'b0010011: begin
                if (funct3 == 3'b000) begin
                    alu_result = rs1_data + imm_i;
                    rd_we      = 1'b1;
                end
            end

            // LOAD
            7'b0000011: begin
                alu_result = rs1_data + imm_i;
                mem_to_reg = 1'b1;
                rd_we      = 1'b1;
            end

            // STORE
            7'b0100011: begin
                alu_result = rs1_data + imm_s;
                mem_we     = 1'b1;
            end

            // BRANCH
            7'b1100011: begin
                case (funct3)
                    3'b000: branch_taken = (rs1_data == rs2_data);
                    3'b001: branch_taken = (rs1_data != rs2_data);
                endcase
            end

            // JAL
            7'b1101111: begin
                jump_taken  = 1'b1;
                jump_target = pc + imm_j;
                alu_result  = pc + 4;
                rd_we       = 1'b1;
            end

            // JALR
            7'b1100111: begin
                jump_taken  = 1'b1;
                jump_target = (rs1_data + imm_i) & ~64'b1;
                alu_result  = pc + 4;
                rd_we       = 1'b1;
            end

            default: ;
        endcase
    end

endmodule
