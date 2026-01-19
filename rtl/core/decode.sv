module decode (
    input  logic [31:0] instr,

    output logic [6:0]  opcode,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,

    output logic [63:0] imm_i,
    output logic [63:0] imm_s,
    output logic [63:0] imm_b,
    output logic [63:0] imm_j
);

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // I-type
    assign imm_i = {{52{instr[31]}}, instr[31:20]};

    // S-type
    assign imm_s = {{52{instr[31]}}, instr[31:25], instr[11:7]};

    // B-type
    assign imm_b = {{51{instr[31]}},
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0};

    // J-type (JAL)
    assign imm_j = {{43{instr[31]}},
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0};

endmodule
