//------------------------------------------------------------------------------
// File Name  : instruction_fetch.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module extracts instruction fields from a 32-bit instruction word.
// It separates register indices, opcode, function codes, and immediate
// fields required by the decode and control logic.
//
// Key Features:
// - Combinational instruction field extraction
// - Decodes register indices and control fields
// - Provides immediate and function fields for downstream logic
//
// Assumptions & Notes:
// - Input instruction is already aligned and valid
// - Field extraction strictly follows instruction encoding format
//------------------------------------------------------------------------------


module Instruction_Fetch (
    input [31:0] instructionD,     // Instruction word (decode stage)
    output reg [4:0] A1,             // Source register 1 index
    output reg [4:0] A2,             // Source register 2 index
    output reg [4:0] A3,             // Destination register index
    output reg [6:0] OP,             // Opcode field
    output reg [2:0] funct3,         // funct3 field
    output reg [24:0] Imm,            // Immediate field (raw)
    output reg [6:0] funct7          // funct7 field
);

    // --------------------------------------------------
    // Instruction field extraction
    // --------------------------------------------------
    // All fields are decoded combinationally to support
    // single-cycle instruction decode behavior.
    always @(*) begin
        A1     <= instructionD[19:15];
        A2     <= instructionD[24:20];
        A3     <= instructionD[11:7];
        OP     <= instructionD[6:0];
        funct3 <= instructionD[14:12];
        Imm    <= instructionD[31:7];
        funct7 <= instructionD[31:25];
    end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This instruction fetch decode module performs field extraction on the
// instruction word, enabling the control unit, register file, and immediate
// generation logic to operate independently and efficiently.
//------------------------------------------------------------------------------
