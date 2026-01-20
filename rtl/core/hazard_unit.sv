//------------------------------------------------------------------------------
// File Name  : hazard_unit.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements hazard detection and resolution logic for the
// pipelined datapath. It handles data hazards using forwarding and stalling
// mechanisms, and control hazards using pipeline flushing.
//
// Key Features:
// - EX-stage data forwarding from MEM and WB stages
// - Load-use hazard detection with pipeline stall insertion
// - Control hazard handling for taken branches and jumps
// - Clean separation of forwarding and stall/flush logic
//
// Assumptions & Notes:
// - Register x0 is hardwired to zero and is excluded from hazard checks
// - Load-use hazards are resolved by stalling fetch and decode stages
// - Branch and jump decisions are resolved in the execute stage
//------------------------------------------------------------------------------


`timescale 1ns / 1ns

module hazard_unit (
    input            clk,          // Clock (unused, combinational logic)
    input      [4:0] Rs1E,          // Source register 1 (execute stage)
    input      [4:0] Rs2E,          // Source register 2 (execute stage)
    input      [4:0] RdM,           // Destination register (memory stage)
    input      [4:0] RdW,           // Destination register (write-back stage)
    input      [4:0] A1,            // Source register 1 (decode stage)
    input      [4:0] A2,            // Source register 2 (decode stage)
    input      [4:0] RdE,           // Destination register (execute stage)
    input      [1:0] ResultSrcE,    // Execute-stage result source encoding
    input            RegWriteM,     // Register write enable (memory stage)
    input            RegWriteW,     // Register write enable (write-back stage)
    input      [1:0] PCSrcE,        // PC source select (execute stage)

    output reg       StallF,        // Stall fetch stage
    output reg       StallD,        // Stall decode stage
    output reg       FlushE,        // Flush execute stage
    output reg       FlushD,        // Flush decode stage
    output reg [1:0] ForwardAE,     // Forwarding control for ALU SrcA
    output reg [1:0] ForwardBE      // Forwarding control for ALU SrcB
);

    // Internal flag for load-use hazard detection
    reg lwStall;

    // --------------------------------------------------
    // Forwarding logic (execute stage)
    // --------------------------------------------------
    // Selects forwarded operands from MEM or WB stages
    // when data hazards are detected.
    always @(*) begin
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
            ForwardAE = 2'b10;     // Forward from MEM stage
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
            ForwardAE = 2'b01;     // Forward from WB stage
        else
            ForwardAE = 2'b00;     // No forwarding
    end

    always @(*) begin
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
            ForwardBE = 2'b10;     // Forward from MEM stage
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
            ForwardBE = 2'b01;     // Forward from WB stage
        else
            ForwardBE = 2'b00;     // No forwarding
    end

    // --------------------------------------------------
    // Load-use and control hazard handling
    // --------------------------------------------------
    // Detects load-use hazards and introduces stalls.
    // Flushes decode stage on taken branch or jump.
    always @(*) begin
        // Load-use hazard detection:
        // Execute-stage instruction is a load and its destination
        // register is required by the decode-stage instruction.
        lwStall = ResultSrcE[0] &&
                  ((A1 == RdE && A1 != 5'd0) ||
                   (A2 == RdE && A2 != 5'd0));

        // Stall fetch and decode stages on load-use hazard
        StallF = lwStall;
        StallD = lwStall;

        // Flush execute stage on load-use hazard
        FlushE = lwStall;

        // Flush decode stage on taken branch or jump
        FlushD = (PCSrcE != 2'b00);
    end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This hazard unit ensures correct program execution by resolving data and
// control hazards in a pipelined environment. Forwarding minimizes performance
// loss from data hazards, while selective stalling and flushing handle load-use
// and control-flow hazards efficiently.
//------------------------------------------------------------------------------
