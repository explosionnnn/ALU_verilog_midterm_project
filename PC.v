`timescale 1ns/1ns
module PC( clk, reset, PCWrite, PC_in, PC_out );

input clk ;
input reset ;
input PCWrite ;
input [31:0] PC_in ;
output [31:0] PC_out ;

reg [31:0] PC_out ;

always@( posedge clk )
begin
  if ( reset )
    PC_out <= 32'b0 ;
  else if ( PCWrite )
    PC_out <= PC_in ;
end

endmodule
