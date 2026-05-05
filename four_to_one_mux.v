`timescale 1ns/ 1ns
module four_to_one_mux( i1, i2, i3, i4, sel, out );

input i1, i2, i3, i4;
input [1:0] sel;
output out;

assign out = (sel[1]) ? ( (sel[0]) ? i4 : i3 ) : ( (sel[0]) ? i2 : i1 );

endmodule