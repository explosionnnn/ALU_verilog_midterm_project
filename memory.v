`timescale 1ns/1ns
module memory( clk, MemRead, MemWrite, wd, addr, rd );

input clk ;
input MemRead ;
input MemWrite ;
input [31:0] wd ;
input [31:0] addr ;
output [31:0] rd ;

reg [7:0] mem_array [0:1023] ;

always@( posedge clk )
begin
  if ( MemWrite )
  begin
    mem_array[ addr ]     <= wd[7:0] ;
    mem_array[ addr + 1 ] <= wd[15:8] ;
    mem_array[ addr + 2 ] <= wd[23:16] ;
    mem_array[ addr + 3 ] <= wd[31:24] ;
  end
end

assign rd = MemRead ?
            { mem_array[addr+3], mem_array[addr+2], mem_array[addr+1], mem_array[addr] } :
            32'hxxxxxxxx ;

endmodule
