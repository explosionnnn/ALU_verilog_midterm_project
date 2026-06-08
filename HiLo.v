`timescale 1ns/1ns
module HiLo( clk, MulAns, HiLoWrite, HiOut, LoOut, reset );

input clk ;
input reset ;
input HiLoWrite ;
input [63:0] MulAns ;
output [31:0] HiOut ;
output [31:0] LoOut ;
reg [63:0] HiLo ;

always@( posedge clk )
begin
  if ( reset )
    HiLo <= 64'b0 ;
  else if ( HiLoWrite )
    HiLo <= MulAns ;
end

assign HiOut = HiLo[63:32] ;
assign LoOut = HiLo[31:0] ;

endmodule
