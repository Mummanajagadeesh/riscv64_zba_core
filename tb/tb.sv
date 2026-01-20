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
  // Instruction memory sanity
  // -----------------------------
  initial begin
    @(negedge rst);
    $display("INFO: Instruction memory initialized");
  end

  // -----------------------------
  // DATA MEMORY MONITOR
  // -----------------------------
  always @(posedge clk) begin
    if (CPU.DP.MemWriteM) begin
      $display("MEM WRITE | time=%0t | addr=%0d | data=%0d",
               $time,
               CPU.DP.ALUResultM[63:3],
               CPU.DP.WriteDataM);
    end
  end

  // -----------------------------
  // SELF-CHECK (ASSERT PROPERTIES)
  // -----------------------------
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

  // -----------------------------
  // REGISTER ASSERTION TASK
  // -----------------------------
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
