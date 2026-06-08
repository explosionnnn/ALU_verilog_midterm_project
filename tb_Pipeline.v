`timescale 1ns/1ns
module tb_Pipeline();
	reg clk, rst;
	integer i;
	reg [31:0] result_data;

	initial begin
		clk = 1;
		forever #5 clk = ~clk;
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

		#1000;

		$display( "\n========== Register File ==========" );
		for ( i = 1; i <= 31; i = i + 1 )
			$display( "$%0d = %0d", i, CPU.RegFile.file_array[i] );

		$display( "\n========== Data Memory ==========" );
		for ( i = 0; i < 32; i = i + 4 )
			$display( "Mem[%0d] = %h%h%h%h", i,
			          CPU.DatMem.mem_array[i+3], CPU.DatMem.mem_array[i+2],
			          CPU.DatMem.mem_array[i+1], CPU.DatMem.mem_array[i] );

		$display( "\nSimulation End" );
		$stop;
	end

	always@( posedge clk )
	begin
		if ( !rst )
		begin
			$display( "%0d, PC: %d", $time/10-1, CPU.PC_addr );

			// ID stage: decoded operation
			if ( CPU.opcode == 6'd0 )
			begin
				if ( CPU.funct == 6'd32 ) $display( "%0d, ID: ADD", $time/10-1 );
				else if ( CPU.funct == 6'd34 ) $display( "%0d, ID: SUB", $time/10-1 );
				else if ( CPU.funct == 6'd36 ) $display( "%0d, ID: AND", $time/10-1 );
				else if ( CPU.funct == 6'd37 ) $display( "%0d, ID: OR", $time/10-1 );
				else if ( CPU.funct == 6'd42 ) $display( "%0d, ID: SLT", $time/10-1 );
				else if ( CPU.funct == 6'd8 )  $display( "%0d, ID: JR", $time/10-1 );
				else if ( CPU.funct == 6'd25 ) $display( "%0d, ID: MULTU", $time/10-1 );
				else if ( CPU.funct == 6'd0 )  $display( "%0d, ID: NOP", $time/10-1 );
				else if ( CPU.funct == 6'd2 )  $display( "%0d, ID: SRL", $time/10-1 );
				else if ( CPU.funct == 6'd16 ) $display( "%0d, ID: MFHI", $time/10-1 );
				else if ( CPU.funct == 6'd18 ) $display( "%0d, ID: MFLO", $time/10-1 );
			end
			else if ( CPU.opcode == 6'd35 ) $display( "%0d, LW", $time/10-1 );
			else if ( CPU.opcode == 6'd35 ) $display( "%0d, ID: LW", $time/10-1 );
			else if ( CPU.opcode == 6'd10 )  $display( "%0d, ID: SLTI", $time/10-1 );
			else if ( CPU.opcode == 6'd43 ) $display( "%0d, ID: SW", $time/10-1 );
			else if ( CPU.opcode == 6'd4 )  $display( "%0d, ID: BEQ", $time/10-1 );
			else if ( CPU.opcode == 6'd2 )  $display( "%0d, ID: J", $time/10-1 );

			// EX stage: when an instruction is in EX (shows ALU op and operands)
			if ( CPU.RegWrite_EX || CPU.MemWrite_EX || CPU.MemRead_EX )
			begin
				if ( CPU.Signal_EX == 6'b100000 ) $display( "%0d, EX: ADD A=%0d B=%0d -> %0d", $time/10-1, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out );
				else if ( CPU.Signal_EX == 6'b100010 ) $display( "%0d, EX: SUB A=%0d B=%0d -> %0d", $time/10-1, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out );
				else if ( CPU.Signal_EX == 6'b100100 ) $display( "%0d, EX: AND A=%0d B=%0d -> %0d", $time/10-1, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out );
				else if ( CPU.Signal_EX == 6'b100101 ) $display( "%0d, EX: OR  A=%0d B=%0d -> %0d", $time/10-1, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out );
				else if ( CPU.Signal_EX == 6'b101010 ) $display( "%0d, EX: SLT A=%0d B=%0d -> %0d", $time/10-1, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out );
				else if ( CPU.Signal_EX == 6'b000010 ) $display( "%0d, EX: SRL A=%0d shamt=%0d -> %0d", $time/10-1, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out );
				else if ( CPU.Signal_EX == 6'b011001 ) $display( "%0d, EX: MULTU A=%0d B=%0d (starting mult)", $time/10-1, CPU.talu_dataA, CPU.talu_dataB );
			end

			// MEM stage: show loads/stores
			if ( CPU.MemWrite_MEM )
			begin
				$display( "%0d, MEM: SW addr=%0d data=%0d", $time/10-1, CPU.alu_result_MEM, CPU.rt_data_MEM );
			end
			if ( CPU.MemRead_MEM )
			begin
				$display( "%0d, MEM: LW addr=%0d -> data=%0d", $time/10-1, CPU.alu_result_MEM, CPU.mem_read_data );
			end

			if ( CPU.RegWrite_WB )
			begin
				result_data = CPU.reg_write_data;
				$display( "%0d, wd: %d", $time/10-1, result_data );
				$display( "%0d, R%0d <= %d", $time/10-1, CPU.write_reg_WB, result_data );
			end
		end
	end

	pipeline_cpu CPU( clk, rst );

endmodule
