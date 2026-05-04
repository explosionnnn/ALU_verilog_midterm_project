module ALU_Adder( A, B, Binvert, Sum, Cout );
input  [31:0] A;
input  [31:0] B;
input         Binvert;
output [31:0] Sum;
output        Cout;

wire [31:0] B_in;
wire [32:0] c;

assign B_in = B ^ {32{Binvert}};
assign c[0] = Binvert;

fullAdder fa0  ( A[0],  B_in[0],  c[0],  Sum[0],  c[1]  );
fullAdder fa1  ( A[1],  B_in[1],  c[1],  Sum[1],  c[2]  );
fullAdder fa2  ( A[2],  B_in[2],  c[2],  Sum[2],  c[3]  );
fullAdder fa3  ( A[3],  B_in[3],  c[3],  Sum[3],  c[4]  );
fullAdder fa4  ( A[4],  B_in[4],  c[4],  Sum[4],  c[5]  );
fullAdder fa5  ( A[5],  B_in[5],  c[5],  Sum[5],  c[6]  );
fullAdder fa6  ( A[6],  B_in[6],  c[6],  Sum[6],  c[7]  );
fullAdder fa7  ( A[7],  B_in[7],  c[7],  Sum[7],  c[8]  );
fullAdder fa8  ( A[8],  B_in[8],  c[8],  Sum[8],  c[9]  );
fullAdder fa9  ( A[9],  B_in[9],  c[9],  Sum[9],  c[10] );
fullAdder fa10 ( A[10], B_in[10], c[10], Sum[10], c[11] );
fullAdder fa11 ( A[11], B_in[11], c[11], Sum[11], c[12] );
fullAdder fa12 ( A[12], B_in[12], c[12], Sum[12], c[13] );
fullAdder fa13 ( A[13], B_in[13], c[13], Sum[13], c[14] );
fullAdder fa14 ( A[14], B_in[14], c[14], Sum[14], c[15] );
fullAdder fa15 ( A[15], B_in[15], c[15], Sum[15], c[16] );
fullAdder fa16 ( A[16], B_in[16], c[16], Sum[16], c[17] );
fullAdder fa17 ( A[17], B_in[17], c[17], Sum[17], c[18] );
fullAdder fa18 ( A[18], B_in[18], c[18], Sum[18], c[19] );
fullAdder fa19 ( A[19], B_in[19], c[19], Sum[19], c[20] );
fullAdder fa20 ( A[20], B_in[20], c[20], Sum[20], c[21] );
fullAdder fa21 ( A[21], B_in[21], c[21], Sum[21], c[22] );
fullAdder fa22 ( A[22], B_in[22], c[22], Sum[22], c[23] );
fullAdder fa23 ( A[23], B_in[23], c[23], Sum[23], c[24] );
fullAdder fa24 ( A[24], B_in[24], c[24], Sum[24], c[25] );
fullAdder fa25 ( A[25], B_in[25], c[25], Sum[25], c[26] );
fullAdder fa26 ( A[26], B_in[26], c[26], Sum[26], c[27] );
fullAdder fa27 ( A[27], B_in[27], c[27], Sum[27], c[28] );
fullAdder fa28 ( A[28], B_in[28], c[28], Sum[28], c[29] );
fullAdder fa29 ( A[29], B_in[29], c[29], Sum[29], c[30] );
fullAdder fa30 ( A[30], B_in[30], c[30], Sum[30], c[31] );
fullAdder fa31 ( A[31], B_in[31], c[31], Sum[31], c[32] );

assign Cout = c[32];

endmodule
