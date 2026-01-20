`timescale 1ns / 1ns

module risc_TB;

  reg rst, clk;

  // -----------------------------
  // DUT
  // -----------------------------
  risc_top CPU (
      .rst(rst),
      .clk(clk)
  );

  // -----------------------------
  // Clock generation
  // -----------------------------
  always #10 clk = ~clk;

  // -----------------------------
  // Reset sequence
  // -----------------------------
  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #50;
    rst = 1'b0;
  end

  // -----------------------------
  // Waveform dump
  // -----------------------------
  initial begin
    $dumpfile("risc.vcd");
    $dumpvars(0, risc_TB);
  end

  // -----------------------------
  // Self-checking logic
  // -----------------------------
  initial begin
    // Let program execute fully
    repeat (200) @(posedge clk);

    $display("");
    $display("==================================");
    $display("     ZBA SELF CHECK START");
    $display("==================================");

    check_reg(1, 64'd5);   // x1 = 5
    check_reg(2, 64'd3);   // x2 = 3
    check_reg(3, 64'd11);  // sh1add
    check_reg(4, 64'd17);  // sh2add
    check_reg(5, 64'd29);  // sh3add
    check_reg(6, 64'd8);   // add.uw
    check_reg(7, 64'd0);   // sentinel

    $display("==================================");
    $display("     ALL ZBA TESTS PASSED");
    $display("==================================");
    $display("");

    $finish;
  end

  // -----------------------------
  // Register check task
  // -----------------------------
  task check_reg(
    input int regnum,
    input [63:0] expected
  );
    reg [63:0] actual;
    begin
      actual = CPU.DP.regf.Registers[regnum];
      if (actual !== expected) begin
        $display("ERROR: x%0d = %0d (expected %0d)",
                 regnum, actual, expected);
        $fatal;
      end else begin
        $display("OK: x%0d = %0d", regnum, actual);
      end
    end
  endtask

endmodule
