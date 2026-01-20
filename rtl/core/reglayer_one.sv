module reglayer_one (
    input         rst,
    input         clk,
    input         StallD,
    input         FlushD,
    input  [31:0] instruction,
    input  [63:0] PCF,
    input  [63:0] PCPlus4F,
    output reg [31:0] instructionD,
    output reg [63:0] PCD,
    output reg [63:0] PCPlus4D
);
  always @(posedge clk) begin
    if (rst) begin
      PCD          <= 64'd0;
      instructionD <= 32'd0;
      PCPlus4D     <= 64'd0;
    end else if (StallD) begin
      PCD          <= PCD;
      instructionD <= instructionD;
      PCPlus4D     <= PCPlus4D;
    end else if (FlushD) begin
      PCD          <= 64'd0;
      instructionD <= 32'd0;
      PCPlus4D     <= 64'd0;
    end else begin
      instructionD <= instruction;
      PCD          <= PCF;
      PCPlus4D     <= PCPlus4F;
    end
  end
endmodule
