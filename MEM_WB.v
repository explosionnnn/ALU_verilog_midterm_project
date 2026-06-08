`timescale 1ns/1ns
module MEM_WB( clk, reset,
               RegWrite_in, MemtoReg_in,
               mem_data_in, alu_result_in, write_reg_in,
               RegWrite_out, MemtoReg_out,
               mem_data_out, alu_result_out, write_reg_out );

input clk, reset ;
input RegWrite_in, MemtoReg_in ;
input [31:0] mem_data_in, alu_result_in ;
input [4:0]  write_reg_in ;

output RegWrite_out, MemtoReg_out ;
output [31:0] mem_data_out, alu_result_out ;
output [4:0]  write_reg_out ;

reg RegWrite_out, MemtoReg_out ;
reg [31:0] mem_data_out, alu_result_out ;
reg [4:0]  write_reg_out ;

always@( posedge clk )
begin
  if ( reset )
  begin
    RegWrite_out <= 1'b0 ; MemtoReg_out <= 1'b0 ;
    mem_data_out <= 32'b0 ; alu_result_out <= 32'b0 ; write_reg_out <= 5'b0 ;
  end
  else
  begin
    RegWrite_out <= RegWrite_in ; MemtoReg_out <= MemtoReg_in ;
    mem_data_out <= mem_data_in ; alu_result_out <= alu_result_in ;
    write_reg_out <= write_reg_in ;
  end
end

endmodule
