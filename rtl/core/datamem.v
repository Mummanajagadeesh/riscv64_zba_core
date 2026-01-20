`timescale 1ns / 1ns

module datamem (
    input  [63:0] WD,        // write data (RV64)
    input  [63:0] A,         // byte address
    input         clk,
    input         WE,
    input         rst,
    output reg [63:0] ReadData
);

  reg [63:0] Data_Mem [0:999];
  integer i;

  // Initialize memory
  initial begin
    $readmemh("datamemory.mem", Data_Mem);
  end

  // Combinational read
  always @(*) begin
    ReadData = Data_Mem[A >> 3];   // divide by 8 (64-bit words)
  end

  // Synchronous write
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 1000; i = i + 1)
        Data_Mem[i] <= 64'd0;
    end
    else if (WE) begin
      Data_Mem[A >> 3] <= WD;
    end
  end

endmodule
