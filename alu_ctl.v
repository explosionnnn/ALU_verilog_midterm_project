`timescale 1ns/1ns
module alu_ctl( ALUOp, Funct, ALUOperation );

input  [1:0] ALUOp ;
input  [5:0] Funct ;
output [5:0] ALUOperation ;

parameter ADD = 6'b100000 ;
parameter SUB = 6'b100010 ;
parameter SLT = 6'b101010 ;

assign ALUOperation = ( ALUOp == 2'b00 ) ? ADD :
                      ( ALUOp == 2'b01 ) ? SUB :
                      ( ALUOp == 2'b11 ) ? SLT :
                      Funct ;

endmodule
