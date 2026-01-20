module Controller (
    input  [6:0] OP,
    input  [6:0] funct7,
    input  [2:0] funct3,

    output reg        MemWriteD,
    output reg        ALUSrcD,
    output reg        RegWriteD,
    output reg        JumpD,
    output reg        BranchD,
    output reg [1:0]  ResultSrcD,
    output reg [3:0]  ALUControlD,   // widened for Zba
    output reg [2:0]  Imm_SrcD,
    output reg        WD3_SrcD
);

  reg [1:0] ALUOp;

  // --------------------------------------------------
  // Main decoder
  // --------------------------------------------------
  always @(*) begin
    // defaults
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

      7'b0110011: begin  // R-type (includes Zba)
        RegWriteD  = 1;
        ALUSrcD    = 0;
        ResultSrcD = 2'b00;
        ALUOp      = 2'b00;
      end

      7'b0010011: begin  // I-type ALU
        RegWriteD  = 1;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b000;
        ResultSrcD = 2'b00;
        ALUOp      = 2'b01;
      end

      7'b0000011: begin  // Load (LD)
        RegWriteD  = 1;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b000;
        ResultSrcD = 2'b01;
        ALUOp      = 2'b10;
      end

      7'b0100011: begin  // Store (SD)
        RegWriteD  = 0;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b001;
        MemWriteD  = 1;
        ALUOp      = 2'b10;
      end

      7'b1100011: begin  // Branch
        RegWriteD  = 0;
        BranchD    = 1;
        ALUSrcD    = 0;
        Imm_SrcD   = 3'b010;
        ALUOp      = 2'b10;
      end

      7'b1101111: begin  // JAL
        RegWriteD  = 1;
        JumpD      = 1;
        Imm_SrcD   = 3'b100;
        ResultSrcD = 2'b10;
        WD3_SrcD   = 1;
      end

      7'b1100111: begin  // JALR
        RegWriteD  = 1;
        JumpD      = 1;
        ALUSrcD    = 1;
        Imm_SrcD   = 3'b000;
        ResultSrcD = 2'b10;
        WD3_SrcD   = 1;
        ALUOp      = 2'b11;
      end

      7'b0110111: begin  // LUI
        RegWriteD  = 1;
        Imm_SrcD   = 3'b011;
        ResultSrcD = 2'b11;
      end

      default: begin
        // do nothing
      end
    endcase
  end

  // --------------------------------------------------
  // ALU decoder (includes Zba)
  // --------------------------------------------------
  always @(*) begin
    ALUControlD = 4'b0000; // default ADD

    case (ALUOp)

      // R-type
      2'b00: begin
        if (funct7 == 7'b0000100) begin
          // -------- Zba instructions --------
          case (funct3)
            3'b000: ALUControlD = 4'b1000; // sh1add
            3'b001: ALUControlD = 4'b1001; // sh2add
            3'b010: ALUControlD = 4'b1010; // sh3add
            default: ALUControlD = 4'b0000;
          endcase
        end else begin
          // -------- Standard R-type --------
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

      // I-type ALU
      2'b01: begin
        case (funct3)
          3'b000: ALUControlD = 4'b0000; // ADDI
          3'b110: ALUControlD = 4'b0011; // ORI
          3'b100: ALUControlD = 4'b0101; // XORI
          3'b010: ALUControlD = 4'b0100; // SLTI
          default: ALUControlD = 4'b0000;
        endcase
      end

      // Load / Store / Branch
      2'b10: begin
        ALUControlD = 4'b0000; // address add
      end

      // JALR
      2'b11: begin
        ALUControlD = 4'b0000;
      end

      default: ALUControlD = 4'b0000;
    endcase
  end

endmodule
