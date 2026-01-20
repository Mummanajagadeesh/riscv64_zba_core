module PCTarget_adder (
    input  [63:0] PCE,
    input  [63:0] ExtImmE,
    output [63:0] PCTargetE
);
  assign PCTargetE = PCE + ExtImmE;
endmodule
