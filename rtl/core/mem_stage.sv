module mem_stage (
    input  logic [63:0] alu_result,
    input  logic [63:0] rs2_data,
    input  logic        mem_we,

    output logic [63:0] data_mem_addr,
    output logic [63:0] data_mem_wdata,
    output logic        data_mem_we
);

    assign data_mem_addr  = alu_result;
    assign data_mem_wdata = rs2_data;
    assign data_mem_we    = mem_we;

endmodule
