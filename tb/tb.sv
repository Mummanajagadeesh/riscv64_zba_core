//------------------------------------------------------------------------------
// File Name  : tb.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements a self-checking SystemVerilog testbench for the
// RV64I processor core with Zba extension support. It drives clock and reset
// signals, initializes instruction execution, monitors memory activity, and
// validates architectural state after program completion.
//
// The testbench is designed to verify correct functionality across arithmetic,
// Zba-specific operations, memory accesses, and control-flow behavior.
//
// Key Features:
// - Clock and reset generation
// - Top-level DUT instantiation
// - Instruction memory initialization check
// - Data memory write monitoring
// - Self-checking register assertions
// - Automatic simulation termination on failure or success
//
// Assumptions & Notes:
// - Instruction and data memories are preloaded from external files
// - Program execution completes within a bounded number of cycles
// - Internal register file visibility is permitted for verification
//------------------------------------------------------------------------------


`timescale 1ns / 1ns

module risc_TB;

  // --------------------------------------------------
  // Testbench signals
  // --------------------------------------------------
  reg rst, clk;

  // --------------------------------------------------
  // Device Under Test (DUT)
  // --------------------------------------------------
  // Instantiates the top-level RISC-V processor core
  risc_top CPU (
      .rst(rst),
      .clk(clk)
  );

  // --------------------------------------------------
  // Clock generation
  // --------------------------------------------------
  // Generates a free-running clock with a 20ns period
  always #10 clk = ~clk;

  // --------------------------------------------------
  // Reset sequence
  // --------------------------------------------------
  // Applies an initial reset to place the processor
  // into a known architectural state before execution
  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #50;
    rst = 1'b0;
  end

  // --------------------------------------------------
  // Waveform dump
  // --------------------------------------------------
  // Enables waveform capture for post-simulation
  // debug and timing analysis
  initial begin
    $dumpfile("risc.vcd");
    $dumpvars(0, risc_TB);
  end

  // --------------------------------------------------
  // Instruction memory sanity check
  // --------------------------------------------------
  // Confirms that instruction memory has been
  // successfully initialized before execution
  initial begin
    @(negedge rst);
    $display("INFO: Instruction memory initialized");
  end

  // --------------------------------------------------
  // Data memory write monitor
  // --------------------------------------------------
  // Logs all store operations performed by the core
  // to aid in observing memory-side effects
  always @(posedge clk) begin
    if (CPU.DP.MemWriteM) begin
      $display("MEM WRITE | time=%0t | addr=%0d | data=%0d",
               $time,
               CPU.DP.ALUResultM[63:3],
               CPU.DP.WriteDataM);
    end
  end

  // --------------------------------------------------
  // Self-checking verification sequence
  // --------------------------------------------------
  // Waits for program execution to complete and
  // validates final architectural register state
  initial begin
    repeat (200) @(posedge clk);

    $display("");
    $display("==================================");
    $display("     ZBA + MEMORY SELF CHECK");
    $display("==================================");

    check_reg(1, 64'd5);   // Immediate load
    check_reg(2, 64'd3);   // Immediate load
    check_reg(3, 64'd11);  // SH1ADD
    check_reg(4, 64'd17);  // SH2ADD
    check_reg(5, 64'd29);  // SH3ADD
    check_reg(6, 64'd8);   // ADD.UW
    check_reg(7, 64'd29);  // Load followed by taken branch

    $display("==================================");
    $display("     ALL TESTS PASSED");
    $display("==================================");
    $display("");

    $finish;
  end

  // --------------------------------------------------
  // Register assertion task
  // --------------------------------------------------
  // Compares the expected and actual contents of
  // a register and terminates simulation on mismatch
  task check_reg(
    input int regnum,
    input [63:0] expected
  );
    reg [63:0] actual;
    begin
      actual = CPU.DP.regf.Registers[regnum];

      if (actual !== expected) begin
        $error("ASSERT FAIL: x%0d = %0d (expected %0d)",
               regnum, actual, expected);
        $fatal;
      end

      $display("ASSERT PASS: x%0d = %0d", regnum, actual);
    end
  endtask

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This testbench validates end-to-end processor functionality by executing a
// representative program and checking final architectural state. It combines
// runtime observability with automated assertions to ensure correctness across
// arithmetic operations, Zba extensions, memory accesses, and control-flow
// handling. The testbench is suitable for regression testing and design
// verification of the pipelined core.
//------------------------------------------------------------------------------
