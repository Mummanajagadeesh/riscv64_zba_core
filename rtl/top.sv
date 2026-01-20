//------------------------------------------------------------------------------
// File Name  : top.sv
// Author     : Jagadeesh Mummana
// Email      : mummanajagadeesh97@gmail.com
// Repository : Mummanajagadeesh /riscv64_zba_core
//
// Description:
// This module is the top-level integration wrapper for the processor core.
// It instantiates and connects the datapath, control unit, and hazard unit,
// forming a complete pipelined processor implementation.
//
// Key Features:
// - Top-level integration of datapath and control logic
// - Clean separation of control, datapath, and hazard handling
// - Centralized wiring of pipeline control signals
// - Minimal external interface (clock and reset)
//
// Assumptions & Notes:
// - All submodules are synchronous to the same clock
// - Reset initializes the entire pipeline to a known safe state
// - Instruction and data memories are instantiated within the datapath
//------------------------------------------------------------------------------


module risc_top (
    input rst,          // Global reset
    input clk           // Global clock
);

  // --------------------------------------------------
  // Control and hazard signals
  // --------------------------------------------------
  wire        JumpD;
  wire        BranchD;
  wire        MemWriteD;
  wire        ALUSrcD;
  wire        RegWriteD;
  wire        WD3_SrcD;
  wire        StallF;
  wire        StallD;
  wire        FlushD;
  wire        FlushE;
  wire        RegWriteM;
  wire        RegWriteW;

  wire [1:0]  ResultSrcD;
  wire [1:0]  ForwardAE;
  wire [1:0]  ForwardBE;
  wire [1:0]  PCSrcE;
  wire [1:0]  ResultSrcE;

  wire [2:0]  Imm_SrcD;
  wire [3:0]  ALUControlD;  
  wire [2:0]  funct3;

  wire [6:0]  OP;
  wire [6:0]  funct7;

  wire [4:0]  A1;
  wire [4:0]  A2;
  wire [4:0]  RdE;
  wire [4:0]  RdM;
  wire [4:0]  RdW;
  wire [4:0]  Rs1E;
  wire [4:0]  Rs2E;

  // -----------------------------------------
  // Datapath
  // -----------------------------------------
  // Implements the five-stage pipelined datapath
  datapath DP (
      .rst(rst),
      .clk(clk),
      .JumpD(JumpD),
      .BranchD(BranchD),
      .MemWriteD(MemWriteD),
      .ALUSrcD(ALUSrcD),
      .RegWriteD(RegWriteD),
      .WD3_SrcD(WD3_SrcD),
      .StallF(StallF),
      .StallD(StallD),
      .FlushD(FlushD),
      .FlushE(FlushE),
      .ResultSrcD(ResultSrcD),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE),
      .Imm_SrcD(Imm_SrcD),
      .ALUControlD(ALUControlD),

      .OP(OP),
      .funct7(funct7),
      .funct3(funct3),
      .A1(A1),
      .A2(A2),
      .RdE(RdE),
      .RdM(RdM),
      .RdW(RdW),
      .Rs1E(Rs1E),
      .Rs2E(Rs2E),
      .PCSrcE(PCSrcE),
      .ResultSrcE(ResultSrcE),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW)
  );

  // -----------------------------------------
  // Controller
  // -----------------------------------------
  // Decodes instructions and generates control signals
  Controller CU (
      .OP(OP),
      .funct7(funct7),
      .funct3(funct3),
      .MemWriteD(MemWriteD),
      .ALUSrcD(ALUSrcD),
      .RegWriteD(RegWriteD),
      .JumpD(JumpD),
      .BranchD(BranchD),
      .ResultSrcD(ResultSrcD),
      .ALUControlD(ALUControlD),
      .Imm_SrcD(Imm_SrcD),
      .WD3_SrcD(WD3_SrcD)
  );

  // -----------------------------------------
  // Hazard Unit
  // -----------------------------------------
  // Handles data and control hazard resolution
  hazard_unit HU (
      .clk(clk),
      .Rs1E(Rs1E),
      .Rs2E(Rs2E),
      .RdM(RdM),
      .RdW(RdW),
      .A1(A1),
      .A2(A2),
      .RdE(RdE),
      .ResultSrcE(ResultSrcE),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .PCSrcE(PCSrcE),
      .StallF(StallF),
      .StallD(StallD),
      .FlushE(FlushE),
      .FlushD(FlushD),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE)
  );

endmodule


//------------------------------------------------------------------------------
// Functional Summary:
// This top-level module integrates the datapath, control unit, and hazard unit
// to form a complete pipelined processor core. It serves as the primary entry
// point for simulation and synthesis, exposing only clock and reset as external
// interfaces while encapsulating all internal processor functionality.
//------------------------------------------------------------------------------
