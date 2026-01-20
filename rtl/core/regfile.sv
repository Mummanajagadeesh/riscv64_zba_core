//------------------------------------------------------------------------------
// File Name  : regfile.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements a 32-entry, 64-bit register file with two read ports
// and one write port. It supports combinational reads with write-bypass
// forwarding and synchronous writes.
//
// Key Features:
// - 32 general-purpose 64-bit registers
// - Two asynchronous read ports
// - One synchronous write port
// - Write-before-read bypass logic
// - Architectural zero register enforcement
//
// Assumptions & Notes:
// - Register x0 is hardwired to zero
// - Reads are combinational to support single-cycle decode
// - Writes occur on the rising edge of the clock
//------------------------------------------------------------------------------


`timescale 1ns / 1ns
module Register_File (
    input  [4:0]  A1,        // Read address 1
    input  [4:0]  A2,        // Read address 2
    input  [4:0]  A3,        // Write address
    input  [63:0] WD3,       // Write data
    input         clk,       // Clock
    input         WE3,       // Write enable
    input         rst,       // Reset
    output reg [63:0] RD1,   // Read data 1
    output reg [63:0] RD2    // Read data 2
);

  // Internal register storage (32 registers, 64-bit each)
  reg [63:0] Registers [0:31];
  integer i;

  // --------------------------------------------------
  // Read ports with write-bypass support
  // --------------------------------------------------
  // Provides combinational reads with immediate forwarding
  // of write-back data when reading and writing the same
  // register in a single cycle.
  always @(*) begin
    // Read port 1
    if (A1 == 5'd0)
      RD1 = 64'd0;                 // x0 is hardwired to zero
    else if (WE3 && (A3 == A1))
      RD1 = WD3;                   // Write-before-read bypass
    else
      RD1 = Registers[A1];

    // Read port 2
    if (A2 == 5'd0)
      RD2 = 64'd0;                 // x0 is hardwired to zero
    else if (WE3 && (A3 == A2))
      RD2 = WD3;                   // Write-before-read bypass
    else
      RD2 = Registers[A2];
  end

  // --------------------------------------------------
  // Write port
  // --------------------------------------------------
  // Writes occur synchronously on the rising edge of
  // the clock. Register x0 is protected from modification.
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


//------------------------------------------------------------------------------
// Functional Summary:
// This register file provides the architectural storage required for
// instruction execution. It ensures correct data availability through
// write-bypass logic while maintaining the architectural constraint that
// register x0 always reads as zero.
//------------------------------------------------------------------------------
