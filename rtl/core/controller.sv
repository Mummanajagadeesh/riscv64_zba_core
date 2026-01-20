//------------------------------------------------------------------------------
// File Name  : controller.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the main instruction decode and control logic.
// It decodes opcode and instruction fields to generate control signals
// for the datapath, including ALU operation selection, memory access,
// register write-back, branching, and immediate format selection.
//
// Key Features:
// - Centralized decode for all instruction types
// - Separate main decoder and ALU decoder structure
// - Support for arithmetic, memory, control-flow instructions
// - Extended ALU decode support for shifted-add style operations
//
// Assumptions & Notes:
// - Control outputs are purely combinational
// - Illegal or unsupported instructions safely decode to no-op behavior
// - ALUOp is used as an intermediate encoding between main and ALU decoder
//------------------------------------------------------------------------------


module Controller (
    input  [6:0] OP,             // Opcode field
    input  [6:0] funct7,          // funct7 field for ALU decode
    input  [2:0] funct3,          // funct3 field for ALU / branch decode

    output reg        MemWriteD,   // Data memory write enable
    output reg        ALUSrcD,     // ALU operand B source select
    output reg        RegWriteD,   // Register file write enable
    output reg        JumpD,       // Jump instruction indicator
    output reg        BranchD,     // Branch instruction indicator
    output reg [1:0]  ResultSrcD,  // Write-back result select
    output reg [3:0]  ALUControlD,// Encoded ALU operation
    output reg [2:0]  Imm_SrcD,    // Immediate format select
    output reg        WD3_SrcD     // Write-back data source select
);

  // Intermediate ALU operation class encoding
  reg [1:0] ALUOp;

  // --------------------------------------------------
  // Main decoder
  // --------------------------------------------------
  // Decodes opcode to generate high-level control signals
  // and ALU operation class (ALUOp).
  always @(*) begin
    // Default safe values (no-op)
    RegWriteD  = 0;
    MemWriteD  = 0;
    BranchD    = 0;
    JumpD      = 0;
    ALUSrcD    = 0;
    ResultSrcD = 2'b00;
    Imm_SrcD   = 3'b000;
    WD3_SrcD   = 0;
    ALUOp      = 2'b00;

    case (OP)

      // ---------------- R-type ----------------
      7'b0110011: begin
        RegWriteD  = 1;
        ALUSrcD    = 0;
        ResultSrcD = 2'b00;
        ALUOp      = 2'b00;
      end

      // ---------------- I-type ALU ----------------
      7'b0010011: begin
        RegWriteD  = 1;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b000;
        ResultSrcD = 2'b00;
        ALUOp      = 2'b01;
      end

      // ---------------- Load ----------------
      7'b0000011: begin
        RegWriteD  = 1;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b000;
        ResultSrcD = 2'b01;
        ALUOp      = 2'b10;
      end

      // ---------------- Store ----------------
      7'b0100011: begin
        RegWriteD  = 0;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b001;
        MemWriteD  = 1;
        ALUOp      = 2'b10;
      end

      // ---------------- Branch ----------------
      7'b1100011: begin
        RegWriteD  = 0;
        BranchD    = 1;
        ALUSrcD    = 0;
        Imm_SrcD   = 3'b010;
        ALUOp      = 2'b10;
      end

      // ---------------- JAL ----------------
      7'b1101111: begin
        RegWriteD  = 1;
        JumpD      = 1;
        Imm_SrcD   = 3'b100;
        ResultSrcD = 2'b10;
        WD3_SrcD   = 1;
      end

      // ---------------- JALR ----------------
      7'b1100111: begin
        RegWriteD  = 1;
        JumpD      = 1;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b000;
        ResultSrcD = 2'b10;
        WD3_SrcD   = 1;
        ALUOp      = 2'b11;
      end

      // ---------------- LUI ----------------
      7'b0110111: begin
        RegWriteD  = 1;
        Imm_SrcD   = 3'b011;
        ResultSrcD = 2'b11;
      end

      default: begin
        // Unsupported opcode -> no operation
      end
    endcase
  end

  // --------------------------------------------------
  // ALU decoder
  // --------------------------------------------------
  // Translates ALUOp and instruction fields into a
  // specific ALU control encoding.
  always @(*) begin
    ALUControlD = 4'b0000; // Default ADD

    case (ALUOp)

      // ---------------- R-type ----------------
      2'b00: begin
        if (funct7 == 7'b0000100) begin
          // -------- Shifted-add extensions --------
          case (funct3)
            3'b010: ALUControlD = 4'b1000; // SH1ADD
            3'b100: ALUControlD = 4'b1001; // SH2ADD
            3'b110: ALUControlD = 4'b1010; // SH3ADD
            3'b000: ALUControlD = 4'b1011; // ADD.UW
            default: ALUControlD = 4'b0000;
          endcase
        end else begin
          // -------- Standard R-type ALU --------
          case ({funct7, funct3})
            10'b0000000_000: ALUControlD = 4'b0000; // ADD
            10'b0100000_000: ALUControlD = 4'b0001; // SUB
            10'b0000000_111: ALUControlD = 4'b0010; // AND
            10'b0000000_110: ALUControlD = 4'b0011; // OR
            10'b0000000_010: ALUControlD = 4'b0100; // SLT
            10'b0000000_100: ALUControlD = 4'b0101; // XOR
            default:         ALUControlD = 4'b0000;
          endcase
        end
      end

      // ---------------- I-type ALU ----------------
      2'b01: begin
        case (funct3)
          3'b000: ALUControlD = 4'b0000; // ADDI
          3'b110: ALUControlD = 4'b0011; // ORI
          3'b100: ALUControlD = 4'b0101; // XORI
          3'b010: ALUControlD = 4'b0100; // SLTI
          default: ALUControlD = 4'b0000;
        endcase
      end

      // ---------------- Load / Store / Branch ----------------
      2'b10: begin
        ALUControlD = 4'b0000; // Address calculation
      end

      // ---------------- JALR ----------------
      2'b11: begin
        ALUControlD = 4'b0000; // Target address computation
      end

      default: ALUControlD = 4'b0000;
    endcase
  end

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This controller module decodes instructions and generates all necessary
// control signals for datapath operation. A two-level decode strategy is used,
// separating high-level instruction classification from detailed ALU operation
// selection. This approach improves clarity, scalability, and ease of extension.
//------------------------------------------------------------------------------
