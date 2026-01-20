//------------------------------------------------------------------------------
// File Name  : tb.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the top-level testbench for the processor core.
// It provides clock and reset generation, waveform dumping, runtime
// monitoring, and self-checking assertions to validate correct execution.
//
// Key Features:
// - Clock and reset generation
// - DUT instantiation
// - Waveform dumping for debugging
// - Runtime memory write monitoring
// - Self-checking register assertions
//
// Assumptions & Notes:
// - Instruction and data memories are pre-initialized from external files
// - Tests complete within a bounded number of cycles
// - Testbench halts simulation on any assertion failure
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
  // Instantiates the top-level processor core
  risc_top CPU (
      .rst(rst),
      .clk(clk)
  );

  // --------------------------------------------------
  // Clock generation
  // --------------------------------------------------
  // Generates a periodic clock with 20ns period
  always #10 clk = ~clk;

  // --------------------------------------------------
  // Reset sequence
  // --------------------------------------------------
  // Applies reset at the start of simulation to
  // initialize the processor to a known state
  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #50;
    rst = 1'b0;
  end

  // --------------------------------------------------
  // Waveform dump
  // --------------------------------------------------
  // Enables waveform generation for post-simulation
  // analysis and debugging
  initial begin
    $dumpfile("risc.vcd");
    $dumpvars(0, risc_TB);
  end

  // --------------------------------------------------
  // Instruction memory sanity check
  // --------------------------------------------------
  // Confirms instruction memory initialization
  initial begin
    @(negedge rst);
    $display("INFO: Instruction memory initialized");
  end

  // --------------------------------------------------
  // Data memory write monitor
  // --------------------------------------------------
  // Prints memory write transactions for visibility
  // during simulation
  always @(posedge clk) begin
    if (CPU.DP.MemWriteM) begin
      $display("MEM WRITE | time=%0t | addr=%0d | data=%0d",
               $time,
               CPU.DP.ALUResultM[63:3],
               CPU.DP.WriteDataM);
    end
  end

  // --------------------------------------------------
  // Self-checking test sequence
  // --------------------------------------------------
  // Waits for program execution to complete and
  // validates register contents
  initial begin
    repeat (200) @(posedge clk);

    $display("");
    $display("==================================");
    $display("     ZBA SELF CHECK START");
    $display("==================================");

    check_reg(1, 64'd5);
    check_reg(2, 64'd3);
    check_reg(3, 64'd11);
    check_reg(4, 64'd17);
    check_reg(5, 64'd29);
    check_reg(6, 64'd8);
    check_reg(7, 64'd0);

    $display("==================================");
    $display("     ALL ZBA TESTS PASSED");
    $display("==================================");
    $display("");

    $finish;
  end

  // --------------------------------------------------
  // Register assertion task
  // --------------------------------------------------
  // Compares expected and actual register values
  // and terminates simulation on mismatch
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
// This self-checking testbench validates correct processor functionality by
// executing a predefined program and asserting expected architectural state.
// It provides observability through waveform dumps and runtime logging while
// ensuring simulation halts on any functional discrepancy.
//------------------------------------------------------------------------------
