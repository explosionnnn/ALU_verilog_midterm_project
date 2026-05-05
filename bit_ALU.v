`timescale 1ns/ 1ns
module bit_ALU( bit_a, bit_b, Binvert, sel, carry_in, out, carry_out );

input  bit_a, bit_b, carry_in;
input  [1:0] sel;
input  Binvert;
output out, carry_out;

wire b_in, sum_fa;
assign b_in = bit_b ^ Binvert;

fullAdder fa ( bit_a, b_in, carry_in, sum_fa, carry_out );
four_to_one_mux mux ( bit_a & b_in, bit_a | b_in, sum_fa, 1'b0, sel, out );

endmodule
