`timescale 1ns/1ns
module two_to_one_mux( i1, i2, sel, out );

input i1, i2;
input sel;
output out;
assign out = sel ? i2 : i1 ;

endmodule