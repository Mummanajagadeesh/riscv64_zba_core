module mux_SrcBE1 (
    input  [63:0] RD2E,
    input  [63:0] ResultW,
    input  [63:0] ALUResultM,
    input  [1:0]  ForwardBE,
    output [63:0] WriteDataE
);
  assign WriteDataE =
      (ForwardBE == 2'b00) ? RD2E :
      (ForwardBE == 2'b01) ? ResultW :
                             ALUResultM;
endmodule
