`timescale 1ns / 1ns

module risc_TB;

  reg rst, clk;

  risc_top CPU (
      .rst(rst),
      .clk(clk)
  );

  always #10 clk = ~clk;

  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #50;
    rst = 1'b0;
  end

  initial begin
    $dumpfile("risc.vcd");
    $dumpvars(0, risc_TB);
  end

  initial begin
    repeat (500) @(posedge clk);

    $display("==============================");
    $display("     SELF CHECK START");
    $display("==============================");

    check_reg(6,  64'd10);  // x6
    check_reg(7,  64'd10);  // x7
    check_reg(8,  64'd36);  // x8
    check_reg(9,  64'd0);   // x9
    check_reg(11, 64'd0);   // x11

    $display("==============================");
    $display("     ALL TESTS PASSED");
    $display("==============================");

    $finish;
  end

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
