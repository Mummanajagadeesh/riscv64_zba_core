module reglayer_four (
    input  [63:0] ALUResultM,
    input  [63:0] ReadData,
    input  [63:0] PCPlus4M,
    input  [4:0]  RdM,
    input         rst,
    input         clk,
    input         RegWriteM,
    input  [1:0]  ResultSrcM,
    input  [63:0] ExtImmM,

    output reg [63:0] ALUResultW,
    output reg [63:0] ReadDataW,
    output reg [63:0] PCPlus4W,
    output reg [4:0]  RdW,
    output reg [1:0]  ResultSrcW,
    output reg        RegWriteW,
    output reg [63:0] ExtImmW
);
  always @(posedge clk) begin
    if (rst) begin
      ALUResultW <= 64'd0;
      ReadDataW  <= 64'd0;
      PCPlus4W   <= 64'd0;
      RdW        <= 5'd0;
      ResultSrcW <= 2'd0;
      RegWriteW  <= 0;
      ExtImmW    <= 64'd0;
    end else begin
      ALUResultW <= ALUResultM;
      ReadDataW  <= ReadData;
      PCPlus4W   <= PCPlus4M;
      RdW        <= RdM;
      ResultSrcW <= ResultSrcM;
      RegWriteW  <= RegWriteM;
      ExtImmW    <= ExtImmM;
    end
  end
endmodule
