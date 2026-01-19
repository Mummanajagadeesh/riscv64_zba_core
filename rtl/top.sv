module top (
    input  logic clk,
    input  logic rst,

    input  logic [31:0] instr_mem_rdata,
    output logic [63:0] instr_mem_addr,

    input  logic [63:0] data_mem_rdata,
    output logic [63:0] data_mem_addr,
    output logic [63:0] data_mem_wdata,
    output logic        data_mem_we
);

    riscv_core core (
        .clk(clk),
        .rst(rst),
        .instr_mem_rdata(instr_mem_rdata),
        .instr_mem_addr(instr_mem_addr),
        .data_mem_rdata(data_mem_rdata),
        .data_mem_addr(data_mem_addr),
        .data_mem_wdata(data_mem_wdata),
        .data_mem_we(data_mem_we)
    );

endmodule
