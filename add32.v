`timescale 1ns/1ns
module add32( a, b, result );

input  [31:0] a ;
input  [31:0] b ;
output [31:0] result ;

wire [32:0] c ;
assign c[0] = 1'b0 ;

fullAdder fa0  ( a[0],  b[0],  c[0],  result[0],  c[1]  );
fullAdder fa1  ( a[1],  b[1],  c[1],  result[1],  c[2]  );
fullAdder fa2  ( a[2],  b[2],  c[2],  result[2],  c[3]  );
fullAdder fa3  ( a[3],  b[3],  c[3],  result[3],  c[4]  );
fullAdder fa4  ( a[4],  b[4],  c[4],  result[4],  c[5]  );
fullAdder fa5  ( a[5],  b[5],  c[5],  result[5],  c[6]  );
fullAdder fa6  ( a[6],  b[6],  c[6],  result[6],  c[7]  );
fullAdder fa7  ( a[7],  b[7],  c[7],  result[7],  c[8]  );
fullAdder fa8  ( a[8],  b[8],  c[8],  result[8],  c[9]  );
fullAdder fa9  ( a[9],  b[9],  c[9],  result[9],  c[10] );
fullAdder fa10 ( a[10], b[10], c[10], result[10], c[11] );
fullAdder fa11 ( a[11], b[11], c[11], result[11], c[12] );
fullAdder fa12 ( a[12], b[12], c[12], result[12], c[13] );
fullAdder fa13 ( a[13], b[13], c[13], result[13], c[14] );
fullAdder fa14 ( a[14], b[14], c[14], result[14], c[15] );
fullAdder fa15 ( a[15], b[15], c[15], result[15], c[16] );
fullAdder fa16 ( a[16], b[16], c[16], result[16], c[17] );
fullAdder fa17 ( a[17], b[17], c[17], result[17], c[18] );
fullAdder fa18 ( a[18], b[18], c[18], result[18], c[19] );
fullAdder fa19 ( a[19], b[19], c[19], result[19], c[20] );
fullAdder fa20 ( a[20], b[20], c[20], result[20], c[21] );
fullAdder fa21 ( a[21], b[21], c[21], result[21], c[22] );
fullAdder fa22 ( a[22], b[22], c[22], result[22], c[23] );
fullAdder fa23 ( a[23], b[23], c[23], result[23], c[24] );
fullAdder fa24 ( a[24], b[24], c[24], result[24], c[25] );
fullAdder fa25 ( a[25], b[25], c[25], result[25], c[26] );
fullAdder fa26 ( a[26], b[26], c[26], result[26], c[27] );
fullAdder fa27 ( a[27], b[27], c[27], result[27], c[28] );
fullAdder fa28 ( a[28], b[28], c[28], result[28], c[29] );
fullAdder fa29 ( a[29], b[29], c[29], result[29], c[30] );
fullAdder fa30 ( a[30], b[30], c[30], result[30], c[31] );
fullAdder fa31 ( a[31], b[31], c[31], result[31], c[32] );

endmodule
