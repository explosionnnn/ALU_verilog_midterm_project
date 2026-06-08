`timescale 1ns/1ns
module IF_ID( clk, reset, IFIDWrite, Flush, PC4_in, instr_in, PC4_out, instr_out );

input clk, reset ;
input IFIDWrite ;
input Flush ;
input [31:0] PC4_in ;
input [31:0] instr_in ;
output [31:0] PC4_out ;
output [31:0] instr_out ;

reg [31:0] PC4_out ;
reg [31:0] instr_out ;

always@( posedge clk )
begin
  if ( reset || Flush )
  begin
    PC4_out   <= 32'b0 ;
    instr_out <= 32'b0 ;
  end
  else if ( IFIDWrite )
  begin
    PC4_out   <= PC4_in ;
    instr_out <= instr_in ;
  end
end

endmodule
