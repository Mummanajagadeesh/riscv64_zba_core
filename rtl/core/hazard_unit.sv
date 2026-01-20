//------------------------------------------------------------------------------
// File Name  : hazard_unit.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the hazard detection and data forwarding unit for the
// pipelined processor core. It is responsible for resolving data hazards through
// forwarding and for handling control hazards and load-use hazards via pipeline
// stalls and flushes.
//
// The hazard unit operates combinationally and observes pipeline register fields
// from multiple stages to generate appropriate control actions.
//
// Key Features:
// - EX-stage data forwarding from MEM and WB stages
// - Load-use hazard detection with pipeline stalling
// - Control hazard handling via pipeline flushes
// - Support for branch and jump redirection
//
// Assumptions & Notes:
// - Load results are available only after the MEM stage
// - Branch and jump decisions are resolved in the EX stage
// - Register x0 is hardwired to zero and excluded from hazard checks
//------------------------------------------------------------------------------


`timescale 1ns / 1ns

module hazard_unit (
    input            clk,          // System clock (unused, reserved for extensibility)
    input      [4:0] Rs1E,           // Source register 1 index (EX stage)
    input      [4:0] Rs2E,           // Source register 2 index (EX stage)
    input      [4:0] RdM,            // Destination register index (MEM stage)
    input      [4:0] RdW,            // Destination register index (WB stage)
    input      [4:0] A1,             // Source register 1 index (ID stage)
    input      [4:0] A2,             // Source register 2 index (ID stage)
    input      [4:0] RdE,            // Destination register index (EX stage)
    input      [1:0] ResultSrcE,     // Result source selector (EX stage)
    input            RegWriteM,      // Register write enable (MEM stage)
    input            RegWriteW,      // Register write enable (WB stage)
    input      [1:0] PCSrcE,         // PC source select (EX stage)

    output reg       StallF,         // Stall fetch stage
    output reg       StallD,         // Stall decode stage
    output reg       FlushE,         // Flush execute stage
    output reg       FlushD,         // Flush decode stage
    output reg [1:0] ForwardAE,      // Forwarding control for ALU source A
    output reg [1:0] ForwardBE       // Forwarding control for ALU source B
);

    // Internal signal indicating a load-use hazard condition
    reg lwStall;

    // --------------------------------------------------
    // Forwarding logic (EX stage)
    // --------------------------------------------------
    // Resolves data hazards by forwarding results from later
    // pipeline stages to the execute stage ALU inputs.
    //
    // Priority:
    //   1. Forward from MEM stage if match detected
    //   2. Forward from WB stage if match detected
    //   3. Otherwise, use register file value
    always @(*) begin
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
            ForwardAE = 2'b10;   // Forward from MEM stage
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
            ForwardAE = 2'b01;   // Forward from WB stage
        else
            ForwardAE = 2'b00;   // No forwarding
    end

    always @(*) begin
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
            ForwardBE = 2'b10;   // Forward from MEM stage
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
            ForwardBE = 2'b01;   // Forward from WB stage
        else
            ForwardBE = 2'b00;   // No forwarding
    end

    // --------------------------------------------------
    // Hazard detection and pipeline control
    // --------------------------------------------------
    // Detects load-use hazards and generates stall and flush
    // signals to preserve correct program execution.
    always @(*) begin
        // Load-use hazard detection:
        // Occurs when an instruction in EX stage is a load
        // and the following instruction in ID depends on
        // the load destination register.
        lwStall = ResultSrcE[0] &&
                  ((A1 == RdE && A1 != 5'd0) ||
                   (A2 == RdE && A2 != 5'd0));

        // Stall fetch and decode stages on load-use hazard
        StallF = lwStall;
        StallD = lwStall;

        // Flush execute stage on either:
        // - load-use hazard (to insert a bubble)
        // - taken branch or jump (control hazard)
        FlushE = lwStall || (PCSrcE != 2'b00);

        // Flush decode stage on taken branch or jump
        FlushD = (PCSrcE != 2'b00);
    end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This hazard unit ensures correct pipelined execution by resolving data hazards
// through forwarding and by enforcing stalls and flushes for load-use and control
// hazards. Branch and jump redirections are handled by flushing incorrect-path
// instructions, preventing unintended state updates. The design is fully
// combinational and integrates seamlessly with a classic 5-stage pipeline.
//------------------------------------------------------------------------------
