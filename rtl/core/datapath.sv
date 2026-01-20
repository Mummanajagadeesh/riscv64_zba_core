//------------------------------------------------------------------------------
// File Name  : datapath.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module implements the complete processor datapath, integrating
// instruction fetch, decode, execute, memory access, and write-back stages.
// It coordinates pipeline registers, forwarding paths, hazard control,
// branch and jump handling, and memory interfaces.
//
// Key Features:
// - Five-stage pipelined datapath organization
// - Full support for data forwarding and stalling
// - Integrated branch and jump resolution
// - Clean separation of pipeline stages using register layers
// - Modular structure for easy extensibility and debugging
//
// Assumptions & Notes:
// - Control signals are generated externally and supplied per stage
// - Hazard detection and forwarding control logic are implemented outside
// - All pipeline registers reset to safe states on reset or flush
//------------------------------------------------------------------------------


`timescale 1ns / 1ns
module datapath (
    input         rst,            // Global reset
    input         clk,            // Clock
    input         JumpD,           // Jump control (decode stage)
    input         BranchD,         // Branch control (decode stage)
    input         MemWriteD,       // Memory write enable (decode stage)
    input         ALUSrcD,         // ALU source select (decode stage)
    input         RegWriteD,       // Register write enable (decode stage)
    input         WD3_SrcD,        // Write-back source select
    input         StallF,          // Fetch stage stall
    input         StallD,          // Decode stage stall
    input         FlushD,          // Decode stage flush
    input         FlushE,          // Execute stage flush
    input  [1:0]  ResultSrcD,      // Result source select (decode stage)
    input  [1:0]  ForwardAE,       // Forwarding select for SrcA
    input  [1:0]  ForwardBE,       // Forwarding select for SrcB
    input  [2:0]  Imm_SrcD,        // Immediate format select
    input  [3:0]  ALUControlD,     // ALU control (decode stage)

    output [6:0]  OP,              // Opcode field
    output [6:0]  funct7,          // funct7 field
    output [2:0]  funct3,          // funct3 field
    output [4:0]  A1,              // Source register 1 index
    output [4:0]  A2,              // Source register 2 index
    output [4:0]  RdE,             // Destination register (execute)
    output [4:0]  RdM,             // Destination register (memory)
    output [4:0]  RdW,             // Destination register (write-back)
    output [4:0]  Rs1E,            // Source register 1 (execute)
    output [4:0]  Rs2E,            // Source register 2 (execute)
    output [1:0]  PCSrcE,           // PC source select (execute)
    output [1:0]  ResultSrcE,       // Result source select (execute)
    output        RegWriteM,        // Register write enable (memory)
    output        RegWriteW         // Register write enable (write-back)
);

  // --------------------------------------------------
  // Internal wires
  // --------------------------------------------------
  wire [63:0] RD1, RD2, RD1E, RD2E;
  wire [63:0] SrcAE, SrcBE;
  wire [63:0] ALUResult, ALUResultM, ALUResultW;
  wire [63:0] WriteDataE, WriteDataM;
  wire [63:0] ExtImmD, ExtImmE, ExtImmM, ExtImmW;
  wire [63:0] ResultW;
  wire [63:0] PCF, PCnext, PCD, PCE;
  wire [63:0] PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
  wire [63:0] PCTargetE;
  wire [63:0] ReadData, ReadDataW;

  wire [31:0] instruction, instructionD;
  wire [24:0] Imm;

  wire        ALUSrcE;
  wire        MemWriteE;
  wire        MemWriteM;
  wire        RegWriteE;
  wire        JumpE;
  wire        BranchE;
  wire        ZeroE;

  wire [1:0]  ResultSrcM, ResultSrcW;
  wire [3:0]  ALUControlE;
  wire [2:0]  funct3E;
  wire [6:0]  OPE;
  wire [4:0]  A3;

  // --------------------------------------------------
  // PCSrcE pipeline register
  // --------------------------------------------------
  // Ensures PC source selection is stable across pipeline stages
  reg [1:0] PCSrcE_r;

  always @(posedge clk) begin
    if (rst || FlushE)
      PCSrcE_r <= 2'b00;
    else
      PCSrcE_r <= PCSrcE;
  end

  // --------------------------------------------------
  // Instruction Fetch / Decode
  // --------------------------------------------------
  Instruction_Memory instmeme (
      .PCF(PCF),
      .instruction(instruction)
  );

  reglayer_one lay1 (
      .rst(rst),
      .clk(clk),
      .StallD(StallD),
      .FlushD(FlushD),
      .instruction(instruction),
      .PCF(PCF),
      .PCPlus4F(PCPlus4F),
      .instructionD(instructionD),
      .PCD(PCD),
      .PCPlus4D(PCPlus4D)
  );

  Instruction_Fetch fetch (
      .instructionD(instructionD),
      .A1(A1),
      .A2(A2),
      .A3(A3),
      .OP(OP),
      .funct3(funct3),
      .Imm(Imm),
      .funct7(funct7)
  );

  sign_ext siext (
      .Imm_SrcD(Imm_SrcD),
      .Imm(Imm),
      .ExtImmD(ExtImmD)
  );

  Register_File regf (
      .A1(A1),
      .A2(A2),
      .A3(RdW),
      .WD3(ResultW),
      .clk(clk),
      .WE3(RegWriteW),
      .rst(rst),
      .RD1(RD1),
      .RD2(RD2)
  );

  // --------------------------------------------------
  // Program Counter logic
  // --------------------------------------------------
  Adress_Generator pcgen (
      .rst(rst),
      .clk(clk),
      .StallF(StallF),
      .PCnext(PCnext),
      .PCF(PCF)
  );

  PCPlus4_adder pc4add (
      .PCF(PCF),
      .PCPlus4F(PCPlus4F)
  );

  pc_mux muxpc (
      .PCPlus4F(PCPlus4F),
      .PCTargetE(PCTargetE),
      .ALUResultM(ALUResultM),
      .PCSrcE(PCSrcE_r),
      .PCnext(PCnext)
  );

  // --------------------------------------------------
  // ID / EX pipeline stage
  // --------------------------------------------------
  reglayer_two lay2 (
      .PCD(PCD),
      .ExtImmD(ExtImmD),
      .PCPlus4D(PCPlus4D),
      .RD1(RD1),
      .RD2(RD2),
      .A3(A3),
      .A1(A1),
      .A2(A2),
      .funct3(funct3),
      .rst(rst),
      .clk(clk),
      .RegWriteD(RegWriteD),
      .MemWriteD(MemWriteD),
      .JumpD(JumpD),
      .BranchD(BranchD),
      .ALUSrcD(ALUSrcD),
      .FlushE(FlushE),
      .ResultSrcD(ResultSrcD),
      .ALUControlD(ALUControlD),
      .OPD(OP),

      .RegWriteE(RegWriteE),
      .MemWriteE(MemWriteE),
      .JumpE(JumpE),
      .BranchE(BranchE),
      .ALUSrcE(ALUSrcE),
      .ResultSrcE(ResultSrcE),
      .ALUControlE(ALUControlE),
      .PCE(PCE),
      .ExtImmE(ExtImmE),
      .PCPlus4E(PCPlus4E),
      .RD1E(RD1E),
      .RD2E(RD2E),
      .funct3E(funct3E),
      .RdE(RdE),
      .Rs1E(Rs1E),
      .Rs2E(Rs2E),
      .OPE(OPE)
  );

  // --------------------------------------------------
  // Execute stage
  // --------------------------------------------------
    mux_SrcAE muxa (
        .RD1E(RD1E),
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .ReadDataM(ReadData),        
        .ForwardAE(ForwardAE),
        .MemToRegM(ResultSrcM[0]),  
        .SrcAE(SrcAE)
    );

    mux_SrcBE1 muxb1 (
        .RD2E(RD2E),
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .ReadDataM(ReadData),        
        .ForwardBE(ForwardBE),
        .MemToRegM(ResultSrcM[0]),  
        .WriteDataE(WriteDataE)
    );


  mux_SrcBE2 muxb2 (
      .WriteDataE(WriteDataE),
      .ExtImmE(ExtImmE),
      .ALUSrcE(ALUSrcE),
      .SrcBE(SrcBE)
  );

  alu aluuuu (
      .SrcAE(SrcAE),
      .SrcBE(SrcBE),
      .ALUControlE(ALUControlE),
      .funct3E(funct3E),
      .BranchE(BranchE),
      .ALUResult(ALUResult),
      .ZeroE(ZeroE)
  );

  // PC source selection logic
  assign PCSrcE =
      (BranchE && ZeroE) ? 2'b01 :
      (JumpE && (OPE == 7'b1101111)) ? 2'b01 :
      (JumpE && (OPE == 7'b1100111)) ? 2'b10 :
      2'b00;

  PCTarget_adder pcimmadd (
      .PCE(PCE),
      .ExtImmE(ExtImmE),
      .PCTargetE(PCTargetE)
  );

  // --------------------------------------------------
  // EX / MEM pipeline stage
  // --------------------------------------------------
  reglayer_three lay3 (
      .WriteDataE(WriteDataE),
      .ALUResult(ALUResult),
      .PCPlus4E(PCPlus4E),
      .RdE(RdE),
      .clk(clk),
      .rst(rst),
      .RegWriteE(RegWriteE),
      .MemWriteE(MemWriteE),
      .ResultSrcE(ResultSrcE),
      .ExtImmE(ExtImmE),

      .ALUResultM(ALUResultM),
      .WriteDataM(WriteDataM),
      .PCPlus4M(PCPlus4M),
      .RdM(RdM),
      .RegWriteM(RegWriteM),
      .MemWriteM(MemWriteM),
      .ResultSrcM(ResultSrcM),
      .ExtImmM(ExtImmM)
  );

  datamem datameme (
      .WD(WriteDataM),
      .A(ALUResultM),
      .clk(clk),
      .WE(MemWriteM),
      .rst(rst),
      .ReadData(ReadData)
  );

  // --------------------------------------------------
  // MEM / WB pipeline stage
  // --------------------------------------------------
  reglayer_four lay4 (
      .ALUResultM(ALUResultM),
      .ReadData(ReadData),
      .PCPlus4M(PCPlus4M),
      .RdM(RdM),
      .rst(rst),
      .clk(clk),
      .RegWriteM(RegWriteM),
      .ResultSrcM(ResultSrcM),
      .ExtImmM(ExtImmM),

      .ALUResultW(ALUResultW),
      .ReadDataW(ReadDataW),
      .PCPlus4W(PCPlus4W),
      .RdW(RdW),
      .ResultSrcW(ResultSrcW),
      .RegWriteW(RegWriteW),
      .ExtImmW(ExtImmW)
  );

  result_mux resmux (
      .ALUResultW(ALUResultW),
      .ReadDataW(ReadDataW),
      .PCPlus4W(PCPlus4W),
      .ExtImmW(ExtImmW),
      .ResultSrcW(ResultSrcW),
      .ResultW(ResultW)
  );

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This datapath module integrates all pipeline stages and supporting logic
// required for instruction execution. It provides full support for control
// flow, hazard handling, forwarding, memory access, and write-back operations,
// forming the structural backbone of the processor core.
//------------------------------------------------------------------------------
