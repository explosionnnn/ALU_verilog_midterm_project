`timescale 1ns/1ns
module MUX( ALUOut, HiOut, LoOut, Shifter, Signal, dataOut );
input [31:0] ALUOut ;
input [31:0] HiOut ;
input [31:0] LoOut ;
input [31:0] Shifter ;
input [5:0] Signal ;
output [31:0] dataOut ;


parameter AND  = 6'b100100;
parameter OR   = 6'b100101;
parameter ADD  = 6'b100000;
parameter SUB  = 6'b100010;
parameter SLT  = 6'b101010;
parameter SRL  = 6'b000010;
parameter MFHI = 6'b010000;
parameter MFLO = 6'b010010;

assign dataOut = (Signal == AND)  ? ALUOut  :
                 (Signal == OR)   ? ALUOut  :
                 (Signal == ADD)  ? ALUOut  :
                 (Signal == SUB)  ? ALUOut  :
                 (Signal == SLT)  ? ALUOut  :
                 (Signal == SRL)  ? Shifter :
                 (Signal == MFHI) ? HiOut   :
                 (Signal == MFLO) ? LoOut   : 32'b0;

endmodule