module pc_mux (
    input  [63:0] PCPlus4F,
    input  [63:0] PCTargetE,
    input  [63:0] ALUResultM,
    input  [1:0]  PCSrcE,
    output [63:0] PCnext
);
  assign PCnext =
      (PCSrcE == 2'b00) ? PCPlus4F  :
      (PCSrcE == 2'b01) ? PCTargetE :
                          ALUResultM;
endmodule