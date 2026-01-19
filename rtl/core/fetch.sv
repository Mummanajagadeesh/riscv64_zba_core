module fetch (
    input  logic        clk,
    input  logic        rst,
    input  logic [63:0] pc_next,
    output logic [63:0] pc
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 64'h0;
        else
            pc <= pc_next;
    end

endmodule
