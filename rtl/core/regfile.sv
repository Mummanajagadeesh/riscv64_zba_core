`timescale 1ns / 1ns
module Register_File (
    input  [4:0]  A1,
    input  [4:0]  A2,
    input  [4:0]  A3,
    input  [63:0] WD3,
    input         clk,
    input         WE3,
    input         rst,
    output reg [63:0] RD1,
    output reg [63:0] RD2
);

  reg [63:0] Registers [0:31];
  integer i;

  // --------------------------------------------------
  // READ PORTS WITH WRITE-BYPASS
  // --------------------------------------------------
  always @(*) begin
    // RD1
    if (A1 == 5'd0)
      RD1 = 64'd0;
    else if (WE3 && (A3 == A1))
      RD1 = WD3;                 // write-before-read bypass
    else
      RD1 = Registers[A1];

    // RD2
    if (A2 == 5'd0)
      RD2 = 64'd0;
    else if (WE3 && (A3 == A2))
      RD2 = WD3;                 // write-before-read bypass
    else
      RD2 = Registers[A2];
  end

  // --------------------------------------------------
  // WRITE PORT
  // --------------------------------------------------
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        Registers[i] <= 64'd0;
    end
    else if (WE3 && (A3 != 5'd0)) begin
      Registers[A3] <= WD3;
    end
  end

endmodule
