module result_mux (
    input  [63:0] ALUResultW,
    input  [63:0] ReadDataW,
    input  [63:0] PCPlus4W,
    input  [63:0] ExtImmW,
    input  [1:0]  ResultSrcW,
    output [63:0] ResultW
);
  assign ResultW =
      (ResultSrcW == 2'b00) ? ALUResultW :
      (ResultSrcW == 2'b01) ? ReadDataW  :
      (ResultSrcW == 2'b10) ? PCPlus4W   :
                              ExtImmW;
endmodule
