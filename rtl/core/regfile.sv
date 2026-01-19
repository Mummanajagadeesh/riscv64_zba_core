module regfile (
    input  logic clk,
    input  logic [4:0] rs1, rs2, rd,
    input  logic rd_we,
    input  logic [63:0] rd_data,
    output logic [63:0] rs1_data,
    output logic [63:0] rs2_data
);

    logic [63:0] regs [31:0];

    assign rs1_data = (rs1 == 0) ? 64'b0 : regs[rs1];
    assign rs2_data = (rs2 == 0) ? 64'b0 : regs[rs2];

    always_ff @(posedge clk) begin
        if (rd_we && rd != 0)
            regs[rd] <= rd_data;
    end

endmodule
