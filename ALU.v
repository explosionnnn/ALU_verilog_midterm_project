module ALU( dataA, dataB, Signal, dataOut, reset );
input  [31:0] dataA;
input  [31:0] dataB;
input  [5:0]  Signal;
input         reset;
output [31:0] dataOut;

parameter AND = 6'b100100;
parameter OR  = 6'b100101;
parameter ADD = 6'b100000;
parameter SUB = 6'b100010;
parameter SLT = 6'b101010;

wire        Binvert;
wire [1:0]  sel;
wire [32:0] c;
wire [31:0] out_w;

assign Binvert = (Signal == SUB) | (Signal == SLT);
assign sel = (Signal == AND) ? 2'b00 :
             (Signal == OR)  ? 2'b01 :
             (Signal == ADD || Signal == SUB || Signal == SLT) ? 2'b10 : 2'b11;
assign c[0] = Binvert;

bit_ALU alu0  ( dataA[0],  dataB[0],  Binvert, sel, c[0],  out_w[0],  c[1]  );
bit_ALU alu1  ( dataA[1],  dataB[1],  Binvert, sel, c[1],  out_w[1],  c[2]  );
bit_ALU alu2  ( dataA[2],  dataB[2],  Binvert, sel, c[2],  out_w[2],  c[3]  );
bit_ALU alu3  ( dataA[3],  dataB[3],  Binvert, sel, c[3],  out_w[3],  c[4]  );
bit_ALU alu4  ( dataA[4],  dataB[4],  Binvert, sel, c[4],  out_w[4],  c[5]  );
bit_ALU alu5  ( dataA[5],  dataB[5],  Binvert, sel, c[5],  out_w[5],  c[6]  );
bit_ALU alu6  ( dataA[6],  dataB[6],  Binvert, sel, c[6],  out_w[6],  c[7]  );
bit_ALU alu7  ( dataA[7],  dataB[7],  Binvert, sel, c[7],  out_w[7],  c[8]  );
bit_ALU alu8  ( dataA[8],  dataB[8],  Binvert, sel, c[8],  out_w[8],  c[9]  );
bit_ALU alu9  ( dataA[9],  dataB[9],  Binvert, sel, c[9],  out_w[9],  c[10] );
bit_ALU alu10 ( dataA[10], dataB[10], Binvert, sel, c[10], out_w[10], c[11] );
bit_ALU alu11 ( dataA[11], dataB[11], Binvert, sel, c[11], out_w[11], c[12] );
bit_ALU alu12 ( dataA[12], dataB[12], Binvert, sel, c[12], out_w[12], c[13] );
bit_ALU alu13 ( dataA[13], dataB[13], Binvert, sel, c[13], out_w[13], c[14] );
bit_ALU alu14 ( dataA[14], dataB[14], Binvert, sel, c[14], out_w[14], c[15] );
bit_ALU alu15 ( dataA[15], dataB[15], Binvert, sel, c[15], out_w[15], c[16] );
bit_ALU alu16 ( dataA[16], dataB[16], Binvert, sel, c[16], out_w[16], c[17] );
bit_ALU alu17 ( dataA[17], dataB[17], Binvert, sel, c[17], out_w[17], c[18] );
bit_ALU alu18 ( dataA[18], dataB[18], Binvert, sel, c[18], out_w[18], c[19] );
bit_ALU alu19 ( dataA[19], dataB[19], Binvert, sel, c[19], out_w[19], c[20] );
bit_ALU alu20 ( dataA[20], dataB[20], Binvert, sel, c[20], out_w[20], c[21] );
bit_ALU alu21 ( dataA[21], dataB[21], Binvert, sel, c[21], out_w[21], c[22] );
bit_ALU alu22 ( dataA[22], dataB[22], Binvert, sel, c[22], out_w[22], c[23] );
bit_ALU alu23 ( dataA[23], dataB[23], Binvert, sel, c[23], out_w[23], c[24] );
bit_ALU alu24 ( dataA[24], dataB[24], Binvert, sel, c[24], out_w[24], c[25] );
bit_ALU alu25 ( dataA[25], dataB[25], Binvert, sel, c[25], out_w[25], c[26] );
bit_ALU alu26 ( dataA[26], dataB[26], Binvert, sel, c[26], out_w[26], c[27] );
bit_ALU alu27 ( dataA[27], dataB[27], Binvert, sel, c[27], out_w[27], c[28] );
bit_ALU alu28 ( dataA[28], dataB[28], Binvert, sel, c[28], out_w[28], c[29] );
bit_ALU alu29 ( dataA[29], dataB[29], Binvert, sel, c[29], out_w[29], c[30] );
bit_ALU alu30 ( dataA[30], dataB[30], Binvert, sel, c[30], out_w[30], c[31] );
bit_ALU alu31 ( dataA[31], dataB[31], Binvert, sel, c[31], out_w[31], c[32] );


assign dataOut = reset ? 32'b0 :
                 (Signal == SLT) ? {31'b0, out_w[31]} : out_w;

endmodule
