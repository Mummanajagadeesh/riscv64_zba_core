module mux_SrcBE2 (
    input  [63:0] WriteDataE,
    input  [63:0] ExtImmE,
    input         ALUSrcE,
    output [63:0] SrcBE
);
  assign SrcBE = ALUSrcE ? ExtImmE : WriteDataE;
endmodule
