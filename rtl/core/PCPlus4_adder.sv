module PCPlus4_adder (
    input  [63:0] PCF,
    output [63:0] PCPlus4F
);
  assign PCPlus4F = PCF + 64'd4;
endmodule
