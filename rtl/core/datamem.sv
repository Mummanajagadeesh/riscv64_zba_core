//------------------------------------------------------------------------------
// File Name  : datamem.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements a simple 64-bit data memory block used for load and
// store operations. The memory is word-addressable and supports synchronous
// writes with combinational reads, modeling a single-cycle load behavior.
//
// Key Features:
// - 64-bit wide memory words
// - Word-aligned addressing
// - Synchronous write operation
// - Combinational read operation
// - Memory initialization from external file
//
// Assumptions & Notes:
// - Address input is byte-based and internally converted to word index
// - No byte-enable or misaligned access support
// - Reset signal is unused for memory clearing
//------------------------------------------------------------------------------


`timescale 1ns / 1ns

module datamem (
    input  [63:0] WD,        // Write data input
    input  [63:0] A,         // Byte address
    input         clk,       // Clock
    input         WE,        // Write enable
    input         rst,        // Reset (unused)
    output reg [63:0] ReadData // Read data output
);

  // Internal 64-bit word-addressable memory array
  reg [63:0] Data_Mem [0:999];

  // --------------------------------------------------
  // Memory initialization
  // --------------------------------------------------
  // Loads initial memory contents from an external hex
  // file at the start of simulation.
  initial begin
    $readmemh("datamemory.mem", Data_Mem);
  end

  // --------------------------------------------------
  // Combinational read logic
  // --------------------------------------------------
  // Read is performed asynchronously to model a
  // single-cycle load behavior. Address is assumed
  // to be word-aligned.
  always @(*) begin
    ReadData = Data_Mem[A[63:3]];   // Equivalent to A >> 3
  end

  // --------------------------------------------------
  // Synchronous write logic
  // --------------------------------------------------
  // Writes occur on the rising edge of the clock when
  // write enable is asserted.
  always @(posedge clk) begin
    if (WE) begin
      Data_Mem[A[63:3]] <= WD;
    end
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This data memory module provides a simplified memory model suitable for
// simulation and single-cycle memory access assumptions. It supports full
// 64-bit loads and stores with word-aligned addressing and is initialized
// from an external memory file for program execution.
//------------------------------------------------------------------------------
