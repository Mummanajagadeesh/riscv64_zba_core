`timescale 1ns / 1ns

module hazard_unit (
    input            clk,
    input      [4:0] Rs1E,
    input      [4:0] Rs2E,
    input      [4:0] RdM,
    input      [4:0] RdW,
    input      [4:0] A1,
    input      [4:0] A2,
    input      [4:0] RdE,
    input      [1:0] ResultSrcE,
    input            RegWriteM,
    input            RegWriteW,
    input      [1:0] PCSrcE,

    output reg       StallF,
    output reg       StallD,
    output reg       FlushE,
    output reg       FlushD,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE
);

    reg lwStall;

    // --------------------------------------------------
    // Forwarding logic (EX stage)
    // --------------------------------------------------
    always @(*) begin
        // Forward A
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
            ForwardAE = 2'b10;
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
    end

    always @(*) begin
        // Forward B
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
            ForwardBE = 2'b10;
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

    // --------------------------------------------------
    // Load-use hazard + control hazard handling
    // --------------------------------------------------
    always @(*) begin
        // Load-use hazard (ID depends on EX load)
        lwStall = ResultSrcE[0] &&
                  ((A1 == RdE && A1 != 5'd0) ||
                   (A2 == RdE && A2 != 5'd0));

        // Stall fetch and decode on load-use
        StallF = lwStall;
        StallD = lwStall;

        // Flush execute ONLY on load-use
        FlushE = lwStall;

        // Flush decode ONLY on taken branch / jump
        FlushD = (PCSrcE != 2'b00);
    end

endmodule
