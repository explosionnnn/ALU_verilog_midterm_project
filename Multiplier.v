`timescale 1ns/ 1ns
module Multiplier( clk, dataA, dataB, Signal, dataOut, done, reset );

input clk ;
input reset ;
input [31:0] dataA ;
input [31:0] dataB ;
input [5:0] Signal ;
output [63:0] dataOut ;
output done ;

parameter MULTU = 6'b011001;

reg [63:0] product ;
reg [63:0] multiplicand_reg ;
reg [31:0] multiplier_reg ;
reg [5:0]  count ;

always@( posedge clk )
begin
    if ( reset )
    begin
        product          <= 64'b0 ;
        multiplicand_reg <= 64'b0 ;
        multiplier_reg   <= 32'b0 ;
        count            <= 6'b0 ;
    end
    else if ( Signal == MULTU )
    begin
        if ( count == 6'd0 )
        begin
            product          <= 64'b0 ;
            multiplicand_reg <= { 32'b0, dataA } ;
            multiplier_reg   <= dataB ;
            count            <= 6'd1 ;
        end
        else if ( count <= 6'd32 )
        begin
            if ( multiplier_reg[0] == 1'b1 )
                product <= product + multiplicand_reg ;
            multiplicand_reg <= multiplicand_reg << 1 ;
            multiplier_reg   <= multiplier_reg >> 1 ;
            count <= count + 1 ;
        end
    end
    else
    begin
        product          <= 64'b0 ;
        multiplicand_reg <= 64'b0 ;
        multiplier_reg   <= 32'b0 ;
        count            <= 6'b0 ;
    end
end

assign dataOut = product ;
assign done = ( count == 6'd33 ) ;

endmodule