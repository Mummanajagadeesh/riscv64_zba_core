module writeback (
    input  logic [63:0] alu_result,
    input  logic [63:0] mem_data,
    input  logic        mem_to_reg,

    output logic [63:0] rd_data
);

    assign rd_data = mem_to_reg ? mem_data : alu_result;

endmodule
