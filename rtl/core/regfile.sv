module regfile (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic        rd_we,
    input  logic [63:0] rd_data,
    output logic [63:0] rs1_data,
    output logic [63:0] rs2_data
);

    logic [63:0] regs [31:0];
    integer i;

    // Read ports
    assign rs1_data = (rs1 == 0) ? 64'b0 : regs[rs1];
    assign rs2_data = (rs2 == 0) ? 64'b0 : regs[rs2];

    // Write port + reset
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 64'b0;
        end else begin
            if (rd_we && rd != 0)
                regs[rd] <= rd_data;
        end
    end

endmodule
