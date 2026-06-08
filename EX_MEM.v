`timescale 1ns/1ns
module EX_MEM( clk, reset,
               RegWrite_in, MemtoReg_in, MemRead_in, MemWrite_in,
               alu_result_in, rt_data_in, write_reg_in,
               RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out,
               alu_result_out, rt_data_out, write_reg_out );

input clk, reset ;
input RegWrite_in, MemtoReg_in, MemRead_in, MemWrite_in ;
input [31:0] alu_result_in, rt_data_in ;
input [4:0]  write_reg_in ;

output RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out ;
output [31:0] alu_result_out, rt_data_out ;
output [4:0]  write_reg_out ;

reg RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out ;
reg [31:0] alu_result_out, rt_data_out ;
reg [4:0]  write_reg_out ;

always@( posedge clk )
begin
  if ( reset )
  begin
    RegWrite_out <= 1'b0 ; MemtoReg_out <= 1'b0 ; MemRead_out <= 1'b0 ; MemWrite_out <= 1'b0 ;
    alu_result_out <= 32'b0 ; rt_data_out <= 32'b0 ; write_reg_out <= 5'b0 ;
  end
  else
  begin
    RegWrite_out <= RegWrite_in ; MemtoReg_out <= MemtoReg_in ;
    MemRead_out  <= MemRead_in  ; MemWrite_out <= MemWrite_in ;
    alu_result_out <= alu_result_in ; rt_data_out <= rt_data_in ; write_reg_out <= write_reg_in ;
  end
end

endmodule
