`timescale 1ns/1ns
module TotalALU( clk, dataA, dataB, Signal, Output, mult_done, reset );

input reset ;
input clk ;
input [31:0] dataA ;
input [31:0] dataB ;
input [5:0] Signal ;
output [31:0] Output ;
output mult_done ;

parameter AND = 6'b100100;
parameter OR  = 6'b100101;
parameter ADD = 6'b100000;
parameter SUB = 6'b100010;
parameter SLT = 6'b101010;
parameter SRL = 6'b000010;
parameter MULTU= 6'b011001;
parameter MFHI= 6'b010000;
parameter MFLO= 6'b010010;

wire [31:0] ALUOut, HiOut, LoOut, ShifterOut ;
wire [31:0] dataOut ;
wire [63:0] Mul_Ans ;
wire done ;

ALU ALU( .dataA(dataA), .dataB(dataB), .Signal(Signal), .dataOut(ALUOut), .reset(reset) );
Multiplier Multiplier( .clk(clk), .dataA(dataA), .dataB(dataB), .Signal(Signal), .dataOut(Mul_Ans), .done(done), .reset(reset) );
Shifter Shifter( .dataA(dataA), .dataB(dataB), .Signal(Signal), .dataOut(ShifterOut), .reset(reset) );
HiLo HiLo( .clk(clk), .MulAns(Mul_Ans), .HiLoWrite(done), .HiOut(HiOut), .LoOut(LoOut), .reset(reset) );
MUX MUX( .ALUOut(ALUOut), .HiOut(HiOut), .LoOut(LoOut), .Shifter(ShifterOut), .Signal(Signal), .dataOut(dataOut) );

assign Output = dataOut ;
assign mult_done = done ;

endmodule