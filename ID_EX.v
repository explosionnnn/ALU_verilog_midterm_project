`timescale 1ns/1ns
module ID_EX( clk, reset, Flush, Hold,
              RegWrite_in, MemtoReg_in, MemRead_in, MemWrite_in, ALUSrc_in, Signal_in,
              rs_data_in, rt_data_in, signext_in, shamt_in, write_reg_in,
              RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out, ALUSrc_out, Signal_out,
              rs_data_out, rt_data_out, signext_out, shamt_out, write_reg_out );

input clk, reset, Flush, Hold ;
input RegWrite_in, MemtoReg_in, MemRead_in, MemWrite_in, ALUSrc_in ;
input [5:0]  Signal_in ;
input [31:0] rs_data_in, rt_data_in, signext_in ;
input [4:0]  shamt_in, write_reg_in ;

output RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out, ALUSrc_out ;
output [5:0]  Signal_out ;
output [31:0] rs_data_out, rt_data_out, signext_out ;
output [4:0]  shamt_out, write_reg_out ;

reg RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out, ALUSrc_out ;
reg [5:0]  Signal_out ;
reg [31:0] rs_data_out, rt_data_out, signext_out ;
reg [4:0]  shamt_out, write_reg_out ;

always@( posedge clk )
begin
  if ( reset )
  begin
    RegWrite_out <= 1'b0 ; MemtoReg_out <= 1'b0 ; MemRead_out <= 1'b0 ;
    MemWrite_out <= 1'b0 ; ALUSrc_out   <= 1'b0 ; Signal_out  <= 6'b0 ;
    rs_data_out  <= 32'b0 ; rt_data_out <= 32'b0 ; signext_out <= 32'b0 ;
    shamt_out    <= 5'b0 ; write_reg_out <= 5'b0 ;
  end
  else if ( Hold )
  begin
    RegWrite_out <= RegWrite_out ;
  end
  else if ( Flush )
  begin
    RegWrite_out <= 1'b0 ; MemtoReg_out <= 1'b0 ; MemRead_out <= 1'b0 ;
    MemWrite_out <= 1'b0 ; ALUSrc_out   <= 1'b0 ; Signal_out  <= 6'b0 ;
    rs_data_out  <= 32'b0 ; rt_data_out <= 32'b0 ; signext_out <= 32'b0 ;
    shamt_out    <= 5'b0 ; write_reg_out <= 5'b0 ;
  end
  else
  begin
    RegWrite_out <= RegWrite_in ; MemtoReg_out <= MemtoReg_in ; MemRead_out <= MemRead_in ;
    MemWrite_out <= MemWrite_in ; ALUSrc_out   <= ALUSrc_in   ; Signal_out  <= Signal_in ;
    rs_data_out  <= rs_data_in ; rt_data_out <= rt_data_in ; signext_out <= signext_in ;
    shamt_out    <= shamt_in ; write_reg_out <= write_reg_in ;
  end
end

endmodule
