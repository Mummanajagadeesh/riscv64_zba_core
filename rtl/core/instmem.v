module Instruction_Memory (
    input  [63:0] PCF,              // RV64 PC
    output reg [31:0] instruction
);
  reg [31:0] instructions_Value[0:999];

  initial begin
    $readmemh("instruction.mem", instructions_Value);
  end

  always @(*) begin
    instruction = instructions_Value[PCF[31:2]]; // divide by 4
  end
endmodule
