module riscv_core (
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] instr_mem_rdata,
    output logic [63:0] instr_mem_addr,

    input  logic [63:0] data_mem_rdata,
    output logic [63:0] data_mem_addr,
    output logic [63:0] data_mem_wdata,
    output logic        data_mem_we
);

    // =====================
    // FETCH
    // =====================
    logic [63:0] pc, pc_next;

    // =====================
    // DECODE
    // =====================
    logic [6:0] opcode, funct7;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [63:0] imm_i, imm_s, imm_b;

    // =====================
    // REGFILE
    // =====================
    logic [63:0] rs1_data, rs2_data, rd_data;
    logic        rd_we;

    // =====================
    // EXECUTE
    // =====================
    logic [63:0] alu_result, store_data;
    logic        mem_we, mem_to_reg;
    logic        branch_taken;
    logic [63:0] branch_offset;

    // PC update
    assign pc_next = branch_taken ? (pc + branch_offset) : (pc + 4);

    fetch if_stage (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    assign instr_mem_addr = pc;

    decode id_stage (
        .instr(instr_mem_rdata),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b)
    );

    regfile rf (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rd_we(rd_we),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    execute ex_stage (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_result(alu_result),
        .store_data(store_data),
        .mem_we(mem_we),
        .mem_to_reg(mem_to_reg),
        .rd_we(rd_we),
        .branch_taken(branch_taken),
        .branch_offset(branch_offset)
    );

    mem_stage mem_stage_i (
        .alu_result(alu_result),
        .store_data(store_data),
        .mem_we(mem_we),
        .data_mem_addr(data_mem_addr),
        .data_mem_wdata(data_mem_wdata),
        .data_mem_we(data_mem_we)
    );

    writeback wb_stage (
        .alu_result(alu_result),
        .mem_data(data_mem_rdata),
        .mem_to_reg(mem_to_reg),
        .rd_data(rd_data)
    );

endmodule
