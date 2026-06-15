`timescale 1ns/1ns
module tb_Pipeline();
	reg clk, rst;
	integer i;
	reg [31:0] result_data;

	wire [31:0] PC_IF;
	wire [31:0] PC_ID;
	reg  [31:0] PC_EX, PC_MEM, PC_WB;

	wire [31:0] HI;
	wire [31:0] LO;

	assign PC_IF = CPU.PC_addr;
	assign PC_ID = CPU.PC4_ID - 32'd4;
	assign HI    = CPU.TALU.HiLo.HiOut;
	assign LO    = CPU.TALU.HiLo.LoOut;

	initial begin
		clk = 1;
		forever #5 clk = ~clk;
	end

	always @(posedge clk) begin
		if (rst) begin
			PC_EX  <= 32'd0;
			PC_MEM <= 32'd0;
			PC_WB  <= 32'd0;
		end else if (!CPU.AnyStall) begin
			PC_EX  <= PC_ID;
			PC_MEM <= PC_EX;
			PC_WB  <= PC_MEM;
		end
	end

	initial begin

		for ( i = 0; i < 1024; i = i + 1 )
		begin
			CPU.InstrMem.mem_array[i] = 8'h00;
			CPU.DatMem.mem_array[i]   = 8'h00;
		end
		for ( i = 1; i <= 31; i = i + 1 )
			CPU.RegFile.file_array[i] = 32'h0;

		rst = 1'b1;

		$readmemh( "instr_mem.txt", CPU.InstrMem.mem_array );
		$readmemh( "data_mem.txt",  CPU.DatMem.mem_array );
		$readmemh( "reg.txt",       CPU.RegFile.file_array );

		#10;
		rst = 1'b0;

		#2000;

		$display( "\n========== Register File ==========" );
		for ( i = 1; i <= 31; i = i + 1 )
			$display( "  $%0d = %0d", i, CPU.RegFile.file_array[i] );

		$display( "\n========== Data Memory ==========" );
		for ( i = 0; i < 32; i = i + 4 )
			$display( "  Mem[%0d] = %h%h%h%h", i,
			          CPU.DatMem.mem_array[i+3], CPU.DatMem.mem_array[i+2],
			          CPU.DatMem.mem_array[i+1], CPU.DatMem.mem_array[i] );

		$display( "\nSimulation End" );
		$stop;
	end

	always@( posedge clk )
	begin
		if ( !rst )
		begin
			$display( "============== Cycle %0d ==============", $time/10-1 );

			$display( "  IF  | PC=%-4d  instr=%h", CPU.PC_addr, CPU.instr_IF );
			if ( CPU.AnyStall )
				$display( "        [STALL - pipeline held]" );

			if ( CPU.instr_ID == 32'h0 )
				$display( "  ID  | NOP/bubble" );
			else if ( CPU.opcode == 6'd0 )
			begin
				if      ( CPU.funct == 6'd32 ) $display( "  ID  | ADD   $%0d(=%0d) + $%0d(=%0d) -> $%0d",  CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd34 ) $display( "  ID  | SUB   $%0d(=%0d) - $%0d(=%0d) -> $%0d",  CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd36 ) $display( "  ID  | AND   $%0d(=%0d) & $%0d(=%0d) -> $%0d",  CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd37 ) $display( "  ID  | OR    $%0d(=%0d) | $%0d(=%0d) -> $%0d",  CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd42 ) $display( "  ID  | SLT   $%0d(=%0d) < $%0d(=%0d)? -> $%0d", CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd2  ) $display( "  ID  | SRL   $%0d(=%0d) >> %0d -> $%0d",         CPU.rt, CPU.rt_data, CPU.shamt, CPU.rd );
				else if ( CPU.funct == 6'd25 ) $display( "  ID  | MULTU $%0d(=%0d) * $%0d(=%0d)",           CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data );
				else if ( CPU.funct == 6'd16 ) $display( "  ID  | MFHI  -> $%0d",                           CPU.rd );
				else if ( CPU.funct == 6'd18 ) $display( "  ID  | MFLO  -> $%0d",                           CPU.rd );
				else if ( CPU.funct == 6'd8  ) $display( "  ID  | JR    $%0d(=%0d)",                        CPU.rs, CPU.rs_data );
				else                           $display( "  ID  | R-type funct=%0d (unknown)",               CPU.funct );
			end
			else if ( CPU.opcode == 6'd35 ) $display( "  ID  | LW    $%0d <= Mem[$%0d(=%0d)+%0d]",             CPU.rt, CPU.rs, CPU.rs_data, $signed(CPU.imm16) );
			else if ( CPU.opcode == 6'd43 ) $display( "  ID  | SW    $%0d(=%0d) -> Mem[$%0d(=%0d)+%0d]",       CPU.rt, CPU.rt_data, CPU.rs, CPU.rs_data, $signed(CPU.imm16) );
			else if ( CPU.opcode == 6'd4  ) $display( "  ID  | BEQ   $%0d(=%0d)==$%0d(=%0d)? taken=%0d",       CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.beq_taken );
			else if ( CPU.opcode == 6'd2  ) $display( "  ID  | J     -> %0d",                                   CPU.jump_target );
			else if ( CPU.opcode == 6'd10 ) $display( "  ID  | SLTI  $%0d(=%0d) < %0d? -> $%0d",               CPU.rs, CPU.rs_data, $signed(CPU.imm16), CPU.rt );
			else                            $display( "  ID  | unknown opcode=%0d",                              CPU.opcode );

			if ( CPU.RegWrite_EX || CPU.MemWrite_EX || CPU.MemRead_EX || ( CPU.Signal_EX == 6'b011001 ) )
			begin
				if      ( CPU.Signal_EX == 6'b100000 && !CPU.MemRead_EX && !CPU.MemWrite_EX )
				                               $display( "  EX  | ADD   %0d + %0d = %0d  -> $%0d",       CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b100010 ) $display( "  EX  | SUB   %0d - %0d = %0d  -> $%0d",  CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b100100 ) $display( "  EX  | AND   %0d & %0d = %0d  -> $%0d",  CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b100101 ) $display( "  EX  | OR    %0d | %0d = %0d  -> $%0d",  CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b101010 ) $display( "  EX  | SLT   %0d < %0d = %0d  -> $%0d",  CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b000010 ) $display( "  EX  | SRL   %0d >> %0d = %0d -> $%0d",  CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b011001 ) $display( "  EX  | MULTU %0d * %0d  (done=%0d)",     CPU.talu_dataA, CPU.talu_dataB, CPU.mult_done );
				else if ( CPU.Signal_EX == 6'b010000 ) $display( "  EX  | MFHI  -> %0d  -> $%0d",           CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b010010 ) $display( "  EX  | MFLO  -> %0d  -> $%0d",           CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.MemRead_EX  )            $display( "  EX  | LW    addr=%0d  -> $%0d",          CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.MemWrite_EX )            $display( "  EX  | SW    addr=%0d  data=%0d",         CPU.talu_out, CPU.rt_data_EX );
			end
			else
				$display( "  EX  | NOP/bubble" );

			if ( CPU.MemWrite_MEM )
				$display( "  MEM | SW    Mem[%0d] <= %0d", CPU.alu_result_MEM, CPU.rt_data_MEM );
			else if ( CPU.MemRead_MEM )
				$display( "  MEM | LW    Mem[%0d] -> %0d  -> $%0d", CPU.alu_result_MEM, CPU.mem_read_data, CPU.write_reg_MEM );
			else if ( CPU.RegWrite_MEM && CPU.write_reg_MEM != 5'd0 )
				$display( "  MEM | ALU   result=%0d  -> $%0d", CPU.alu_result_MEM, CPU.write_reg_MEM );
			else
				$display( "  MEM | NOP/bubble" );

			if ( CPU.RegWrite_WB && CPU.write_reg_WB != 5'd0 )
			begin
				result_data = CPU.reg_write_data;
				$display( "  WB  | $%0d <= %0d", CPU.write_reg_WB, result_data );
			end
			else
				$display( "  WB  | NOP/bubble" );

			$display( "" );
		end
	end

	pipeline_cpu CPU( clk, rst );

endmodule
