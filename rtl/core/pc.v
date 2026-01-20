module Adress_Generator (
    input         rst,
    input         clk,
    input         StallF,
    input  [63:0] PCnext,
    output reg [63:0] PCF
);
  always @(posedge clk) begin
    if (rst)
      PCF <= 64'd0;
    else if (StallF)
      PCF <= PCF;
    else
      PCF <= PCnext;
  end
endmodule
