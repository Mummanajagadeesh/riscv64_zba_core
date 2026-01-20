module mux_SrcAE (
    input  [63:0] RD1E,
    input  [63:0] ResultW,
    input  [63:0] ALUResultM,
    input  [1:0]  ForwardAE,
    output [63:0] SrcAE
);
  assign SrcAE =
      (ForwardAE == 2'b00) ? RD1E :
      (ForwardAE == 2'b01) ? ResultW :
                             ALUResultM;
endmodule
