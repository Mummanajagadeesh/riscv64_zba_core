module reglayer_two (
    input  [63:0] PCD,
    input  [63:0] ExtImmD,
    input  [63:0] PCPlus4D,
    input  [63:0] RD1,
    input  [63:0] RD2,
    input  [4:0]  A3,
    input  [4:0]  A1,
    input  [4:0]  A2,
    input  [2:0]  funct3,
    input         rst,
    input         clk,
    input         RegWriteD,
    input         MemWriteD,
    input         JumpD,
    input         BranchD,
    input         ALUSrcD,
    input         ZeroE,
    input         FlushE,
    input  [1:0]  ResultSrcD,
    input  [3:0]  ALUControlD,
    input  [6:0]  OPD,

    output reg        RegWriteE,
    output reg        MemWriteE,
    output reg        JumpE,
    output reg        BranchE,
    output reg        ALUSrcE,
    output reg [1:0]  PCSrcE,
    output reg [1:0]  ResultSrcE,
    output reg [3:0]  ALUControlE,
    output reg [63:0] PCE,
    output reg [63:0] ExtImmE,
    output reg [63:0] PCPlus4E,
    output reg [63:0] RD1E,
    output reg [63:0] RD2E,
    output reg [2:0]  funct3E,
    output reg [4:0]  RdE,
    output reg [4:0]  Rs1E,
    output reg [4:0]  Rs2E,
    output reg [6:0]  OPE
);
  always @(posedge clk) begin
    if (rst || FlushE) begin
      RegWriteE   <= 0;
      MemWriteE   <= 0;
      JumpE       <= 0;
      BranchE     <= 0;
      PCSrcE      <= 2'b00;
      ALUSrcE     <= 0;
      ResultSrcE  <= 2'b00;
      ALUControlE <= 4'b0000;
      PCE         <= 64'd0;
      ExtImmE     <= 64'd0;
      PCPlus4E    <= 64'd0;
      RD1E        <= 64'd0;
      RD2E        <= 64'd0;
      funct3E     <= 3'd0;
      RdE         <= 5'd0;
      Rs1E        <= 5'd0;
      Rs2E        <= 5'd0;
      OPE         <= 7'd0;
    end else begin
      RegWriteE   <= RegWriteD;
      MemWriteE   <= MemWriteD;
      JumpE       <= JumpD;
      BranchE     <= BranchD;
      ALUSrcE     <= ALUSrcD;
      ResultSrcE  <= ResultSrcD;
      ALUControlE <= ALUControlD;
      PCE         <= PCD;
      ExtImmE     <= ExtImmD;
      PCPlus4E    <= PCPlus4D;
      RD1E        <= RD1;
      RD2E        <= RD2;
      funct3E     <= funct3;
      RdE         <= A3;
      Rs1E        <= A1;
      Rs2E        <= A2;
      OPE         <= OPD;
    end
  end

  always @(*) begin
    PCSrcE =
      ((ZeroE && BranchE) || (OPE == 7'b1101111)) ? 2'b01 :
      (OPE == 7'b1100111)                         ? 2'b10 :
                                                     2'b00;
  end
endmodule
