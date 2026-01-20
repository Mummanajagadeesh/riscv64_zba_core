//------------------------------------------------------------------------------
// File Name  : pc.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the program counter (PC) register logic.
// It updates the current PC value based on control-flow decisions,
// while supporting pipeline stalls and reset behavior.
//
// Key Features:
// - Synchronous PC update
// - Support for fetch-stage stalling
// - Clean reset behavior
// - Simple and deterministic PC control
//
// Assumptions & Notes:
// - PC update occurs on the rising edge of the clock
// - When stalled, the PC value is held constant
//------------------------------------------------------------------------------


module Adress_Generator (
    input         rst,        // Global reset
    input         clk,        // Clock
    input         StallF,     // Fetch stage stall
    input  [63:0] PCnext,     // Next PC value
    output reg [63:0] PCF     // Current PC value
);

  // --------------------------------------------------
  // Program Counter register
  // --------------------------------------------------
  // Updates PC on each clock edge unless stalled.
  // Reset forces PC to zero.
  always @(posedge clk) begin
    if (rst)
      PCF <= 64'd0;
    else if (StallF)
      PCF <= PCF;      // Hold PC during stall
    else
      PCF <= PCnext;   // Update PC
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This program counter module manages instruction sequencing by maintaining
// and updating the current PC value. It supports stalling for hazard handling
// and clean initialization through reset.
//------------------------------------------------------------------------------
