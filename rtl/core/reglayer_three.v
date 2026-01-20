module reglayer_three (
    input  [63:0] WriteDataE,
    input  [63:0] ALUResult,
    input  [63:0] PCPlus4E,
    input  [4:0]  RdE,
    input         clk,
    input         rst,
    input         RegWriteE,
    input         MemWriteE,
    input  [1:0]  ResultSrcE,
    input  [63:0] ExtImmE,

    output reg [63:0] ALUResultM,
    output reg [63:0] WriteDataM,
    output reg [63:0] PCPlus4M,
    output reg [4:0]  RdM,
    output reg        RegWriteM,
    output reg        MemWriteM,
    output reg [1:0]  ResultSrcM,
    output reg [63:0] ExtImmM
);
  always @(posedge clk) begin
    if (rst) begin
      RegWriteM  <= 0;
      MemWriteM  <= 0;
      ResultSrcM <= 2'b00;
      ALUResultM <= 64'd0;
      WriteDataM <= 64'd0;
      RdM        <= 5'd0;
      PCPlus4M   <= 64'd0;
      ExtImmM    <= 64'd0;
    end else begin
      RegWriteM  <= RegWriteE;
      MemWriteM  <= MemWriteE;
      ResultSrcM <= ResultSrcE;
      ALUResultM <= ALUResult;
      WriteDataM <= WriteDataE;
      RdM        <= RdE;
      PCPlus4M   <= PCPlus4E;
      ExtImmM    <= ExtImmE;
    end
  end
endmodule
