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
    // Data memory (MODEL)
    // =====================
    logic [63:0] data_mem [0:255];

    // =====================
    // DUT interface
    // =====================
    logic [63:0] instr_addr;
    logic [31:0] instr_data;

    logic [63:0] data_mem_addr;
    logic [63:0] data_mem_wdata;
    logic        data_mem_we;
    logic [63:0] data_mem_rdata;

    // =====================
    // Clock generation
    // =====================
    always #5 clk = ~clk;

    // =====================
    // Instruction fetch
    // =====================
    assign instr_data = instr_mem[instr_addr >> 2];

    // =====================
    // Data memory model
    // =====================
    assign data_mem_rdata = data_mem[data_mem_addr >> 3];

    always @(posedge clk) begin
        if (data_mem_we) begin
            data_mem[data_mem_addr >> 3] <= data_mem_wdata;
            $display("MEM WRITE: addr=0x%0h data=0x%0h",
                     data_mem_addr, data_mem_wdata);
        end
    end

    // =====================
    // DUT
    // =====================
    top dut (
        .clk(clk),
        .rst(rst),
        .instr_mem_rdata(instr_data),
        .instr_mem_addr(instr_addr),
        .data_mem_rdata(data_mem_rdata),
        .data_mem_addr(data_mem_addr),
        .data_mem_wdata(data_mem_wdata),
        .data_mem_we(data_mem_we)
    );

    integer i;

    initial begin
        // ---------------------
        // Waveform
        // ---------------------
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_processor);

        // ---------------------
        // Init memories
        // ---------------------
        for (i = 0; i < 256; i = i + 1) begin
            instr_mem[i] = 32'h00000013; // NOP
            data_mem[i]  = 64'h0;
        end

        // ---------------------
        // Load program
        // ---------------------
        $readmemh("program.hex", instr_mem, 0, 255);

        // ---------------------
        // Reset
        // ---------------------
        rst = 1;
        #20;
        rst = 0;

        // ---------------------
        // Run
        // ---------------------
        #300;

        // ---------------------
        // CHECK RESULTS
        // ---------------------
        if (dut.core.rf.regs[4] !== 64'd5) begin
            $fatal(1,
                "BEQ FAILED: x4 = 0x%0h",
                dut.core.rf.regs[4]);
        end else begin
            $display("BEQ PASSED: x4 = %0d",
                    dut.core.rf.regs[4]);
        end

        $display("=================================");
        $display("TEST PASSED");
        $display("=================================");
        $finish;
    end

endmodule
