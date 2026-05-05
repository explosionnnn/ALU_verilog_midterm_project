module four_to_one_mux( i1, i2, i3, i4, sel, out );
input i1, i2, i3, i4;
input [1:0] sel;
output out;
reg out;
assign out = (sel[1]) ? ( (sel[0]) ? i3 : i4 ) : ( (sel[0]) ? i2 : i1 );
endmodule