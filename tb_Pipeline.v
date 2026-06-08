`timescale 1ns/1ns
module tb_Pipeline();
	reg clk, rst;
	integer i;

	initial begin
		clk = 1;
		forever #5 clk = ~clk;
	end

	initial begin
		// 先把記憶體 / 暫存器清 0,避免未載入區域是 x
		for ( i = 0; i < 1024; i = i + 1 )
		begin
			CPU.InstrMem.mem_array[i] = 8'h00;
			CPU.DatMem.mem_array[i]   = 8'h00;
		end
		for ( i = 1; i <= 31; i = i + 1 )
			CPU.RegFile.file_array[i] = 32'h0;

		rst = 1'b1;

		// 載入測試資料(byte 陣列 little-endian / 暫存器 32-bit)
		$readmemh( "instr_mem.txt", CPU.InstrMem.mem_array );
		$readmemh( "data_mem.txt",  CPU.DatMem.mem_array );
		$readmemh( "reg.txt",       CPU.RegFile.file_array );

		#10;
		rst = 1'b0;

		// 跑足夠的 cycle(含 stall / 分支)
		#1000;

		// 印最終暫存器內容
		$display( "\n========== Register File ==========" );
		for ( i = 1; i <= 31; i = i + 1 )
			$display( "$%0d = %0d", i, CPU.RegFile.file_array[i] );

		// 印資料記憶體(每 4 byte 組成一個 word)
		$display( "\n========== Data Memory ==========" );
		for ( i = 0; i < 32; i = i + 4 )
			$display( "Mem[%0d] = %h%h%h%h", i,
			          CPU.DatMem.mem_array[i+3], CPU.DatMem.mem_array[i+2],
			          CPU.DatMem.mem_array[i+1], CPU.DatMem.mem_array[i] );

		$display( "\nSimulation End" );
		$stop;
	end

	// 每個 cycle 印 PC(除錯用)
	always@( posedge clk )
		if ( !rst )
			$display( "%0d: PC = %0d", $time/10, CPU.PC_addr );

	pipeline_cpu CPU( clk, rst );

endmodule
