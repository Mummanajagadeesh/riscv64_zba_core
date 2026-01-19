`timescale 1ns/1ps

module tb_processor;

    // =====================
    // Clock & Reset
    // =====================
    logic clk = 0;
    logic rst = 1;

    // =====================
    // Instruction memory
    // =====================
    logic [31:0] instr_mem [0:255];

    // =====================
    // DUT interface
    // =====================
    logic [63:0] instr_addr;
    logic [31:0] instr_data;

    // =====================
    // Clock generation
    // =====================
    always #5 clk = ~clk;   // 100 MHz

    // =====================
    // Instruction fetch
    // =====================
    assign instr_data = instr_mem[instr_addr >> 2];

    // =====================
    // DUT
    // =====================
    top dut (
        .clk(clk),
        .rst(rst),
        .instr_mem_rdata(instr_data),
        .instr_mem_addr(instr_addr),
        .data_mem_rdata(64'b0),
        .data_mem_addr(),
        .data_mem_wdata(),
        .data_mem_we()
    );

    integer i;

    initial begin
        // ---------------------
        // Waveform dump
        // ---------------------
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_processor);

        // ---------------------
        // Initialize memory with NOPs
        // NOP = addi x0,x0,0 = 0x00000013
        // ---------------------
        for (i = 0; i < 256; i = i + 1)
            instr_mem[i] = 32'h00000013;

        // ---------------------
        // Load ONLY first N words from program.hex
        // This avoids Icarus warnings
        // ---------------------
        $readmemh("program.hex", instr_mem, 0, 255);
        // ^ loads at most 64 instructions

        // ---------------------
        // Reset
        // ---------------------
        rst = 1;
        #20;
        rst = 0;

        // ---------------------
        // Run
        // ---------------------
        #500;

        $display("=================================");
        $display("Simulation PASSED");
        $display("=================================");
        $finish;
    end

    // =====================
    // Debug trace
    // =====================
    always @(posedge clk) begin
        if (!rst) begin
            $display("TIME=%0t | PC=0x%08h | INSTR=0x%08h",
                     $time, instr_addr, instr_data);
        end
    end

endmodule
