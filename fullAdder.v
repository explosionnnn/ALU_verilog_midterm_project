module fullAdder ( bit_a, bit_b, carry_in, sum, carry_out);
input bit_a, bit_b, carry_in ;
output sum, carry_out ;
assign sum = bit_a ^ bit_b ^ carry_in ;
assign carry_out = ( bit_a & bit_b ) | ( bit_a & carry_in ) | ( bit_b & carry_in ) ;
endmodule
