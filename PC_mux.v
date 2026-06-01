`timescale 1ns/1ns
module PC_mux( PC_plus4, Branch_addr, Jump_addr, JR_addr, PCSrc, PC_next );

input  [31:0] PC_plus4 ;
input  [31:0] Branch_addr ;
input  [31:0] Jump_addr ;
input  [31:0] JR_addr ;
input  [1:0]  PCSrc ;
output [31:0] PC_next ;

assign PC_next = ( PCSrc == 2'b00 ) ? PC_plus4    :
                 ( PCSrc == 2'b01 ) ? Branch_addr :
                 ( PCSrc == 2'b10 ) ? Jump_addr   :
                 ( PCSrc == 2'b11 ) ? JR_addr     : 32'b0 ;

endmodule
