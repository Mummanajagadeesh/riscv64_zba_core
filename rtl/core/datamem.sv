`timescale 1ns / 1ns

module datamem (
    input  [63:0] WD,        // write data (RV64)
    input  [63:0] A,         // byte address
    input         clk,
    input         WE,
    input         rst,        
    output reg [63:0] ReadData
);

  // 64-bit word-addressable data memory
  reg [63:0] Data_Mem [0:999];

  // --------------------------------------------------
  // Memory initialization from file
  // --------------------------------------------------
  initial begin
    $readmemh("datamemory.mem", Data_Mem);
  end

  // --------------------------------------------------
  // Combinational read (single-cycle load model)
  // --------------------------------------------------
  always @(*) begin
    ReadData = Data_Mem[A[63:3]];   // word-aligned access (A >> 3)
  end

  // --------------------------------------------------
  // Synchronous write
  // --------------------------------------------------
  always @(posedge clk) begin
    if (WE) begin
      Data_Mem[A[63:3]] <= WD;
    end
  end

endmodule
