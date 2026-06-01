`timescale 1ns/1ns
module reg_file( clk, RegWrite, RN1, RN2, WN, WD, RD1, RD2 );

input clk ;
input RegWrite ;
input [4:0] RN1, RN2, WN ;
input [31:0] WD ;
output [31:0] RD1, RD2 ;

reg [31:0] file_array [31:1] ;

always@( posedge clk )
begin
  if ( RegWrite && ( WN != 5'd0 ) )
    file_array[WN] <= WD ;
end

assign RD1 = ( RN1 == 5'd0 ) ? 32'd0 : file_array[RN1] ;
assign RD2 = ( RN2 == 5'd0 ) ? 32'd0 : file_array[RN2] ;

endmodule
