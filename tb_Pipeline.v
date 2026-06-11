`timescale 1ns/1ns
module tb_Pipeline();
	reg clk, rst;
	integer i;
	reg [31:0] result_data;
	reg [31:0] PC_EX, PC_MEM, PC_WB;

	wire [31:0] w_PC_IF;
	wire [31:0] w_instr_IF;

	wire [31:0] w_PC4_IFID;
	wire [31:0] w_instr_IFID;

	wire [31:0] w_rsData_IDEX;
	wire [31:0] w_rtData_IDEX;
	wire [5:0]  w_Signal_IDEX;
	wire [4:0]  w_wrReg_IDEX;
	wire        w_RegWrite_IDEX;
	wire        w_MemRead_IDEX;
	wire        w_MemWrite_IDEX;

	wire [31:0] w_aluResult_EXMEM;
	wire [31:0] w_rtData_EXMEM;
	wire [4:0]  w_wrReg_EXMEM;
	wire        w_RegWrite_EXMEM;
	wire        w_MemRead_EXMEM;
	wire        w_MemWrite_EXMEM;

	wire [31:0] w_memData_MEMWB;
	wire [31:0] w_aluResult_MEMWB;
	wire [4:0]  w_wrReg_MEMWB;
	wire        w_RegWrite_MEMWB;
	wire        w_MemtoReg_MEMWB;

	wire        w_RegWrite_WB;
	wire [4:0]  w_wrReg_WB;
	wire [31:0] w_wrData_WB;

	wire        w_MemRead_MEM;
	wire        w_MemWrite_MEM;
	wire [31:0] w_mem_addr;
	wire [31:0] w_mem_wdata;
	wire [31:0] w_mem_rdata;

	wire [31:0] w_HI;
	wire [31:0] w_LO;
	wire        w_HiLoWrite;

	wire [1:0]  w_PCSrc;
	wire        w_beq_taken;
	wire        w_Branch;
	wire        w_Jump;
	wire        w_JumpReg;
	wire [31:0] w_branch_target;
	wire [31:0] w_jump_target;
	wire [31:0] w_PC_next;

	wire        w_AnyStall;
	wire        w_Stall;
	wire        w_MultStall;
	wire        w_mult_done;

	assign w_PC_IF           = CPU.PC_addr;
	assign w_instr_IF        = CPU.instr_IF;

	assign w_PC4_IFID        = CPU.PC4_ID;
	assign w_instr_IFID      = CPU.instr_ID;

	assign w_rsData_IDEX     = CPU.rs_data_EX;
	assign w_rtData_IDEX     = CPU.rt_data_EX;
	assign w_Signal_IDEX     = CPU.Signal_EX;
	assign w_wrReg_IDEX      = CPU.write_reg_EX;
	assign w_RegWrite_IDEX   = CPU.RegWrite_EX;
	assign w_MemRead_IDEX    = CPU.MemRead_EX;
	assign w_MemWrite_IDEX   = CPU.MemWrite_EX;

	assign w_aluResult_EXMEM = CPU.alu_result_MEM;
	assign w_rtData_EXMEM    = CPU.rt_data_MEM;
	assign w_wrReg_EXMEM     = CPU.write_reg_MEM;
	assign w_RegWrite_EXMEM  = CPU.RegWrite_MEM;
	assign w_MemRead_EXMEM   = CPU.MemRead_MEM;
	assign w_MemWrite_EXMEM  = CPU.MemWrite_MEM;

	assign w_memData_MEMWB   = CPU.mem_data_WB;
	assign w_aluResult_MEMWB = CPU.alu_result_WB;
	assign w_wrReg_MEMWB     = CPU.write_reg_WB;
	assign w_RegWrite_MEMWB  = CPU.RegWrite_WB;
	assign w_MemtoReg_MEMWB  = CPU.MemtoReg_WB;

	assign w_RegWrite_WB     = CPU.RegWrite_WB;
	assign w_wrReg_WB        = CPU.write_reg_WB;
	assign w_wrData_WB       = CPU.reg_write_data;

	assign w_MemRead_MEM     = CPU.MemRead_MEM;
	assign w_MemWrite_MEM    = CPU.MemWrite_MEM;
	assign w_mem_addr        = CPU.alu_result_MEM;
	assign w_mem_wdata       = CPU.rt_data_MEM;
	assign w_mem_rdata       = CPU.mem_read_data;

	assign w_HI              = CPU.TALU.HiLo.HiOut;
	assign w_LO              = CPU.TALU.HiLo.LoOut;
	assign w_HiLoWrite       = CPU.TALU.HiLo.HiLoWrite;

	assign w_PCSrc           = CPU.PCSrc;
	assign w_beq_taken       = CPU.beq_taken;
	assign w_Branch          = CPU.Branch_ID;
	assign w_Jump            = CPU.Jump_ID;
	assign w_JumpReg         = CPU.JumpReg_ID;
	assign w_branch_target   = CPU.branch_target;
	assign w_jump_target     = CPU.jump_target;
	assign w_PC_next         = CPU.PC_next;

	assign w_AnyStall        = CPU.AnyStall;
	assign w_Stall           = CPU.Stall;
	assign w_MultStall       = CPU.MultStall;
	assign w_mult_done       = CPU.mult_done;

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
			PC_EX  <= CPU.PC4_ID - 32'd4;
			PC_MEM <= PC_EX;
			PC_WB  <= PC_MEM;
		end
	end

	initial begin
		$dumpfile("pipeline.vcd");
		$dumpvars(0, tb_Pipeline);

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
				if      ( CPU.funct == 6'd32 ) $display( "  ID  | PC=%-4d  ADD   $%0d(=%0d) + $%0d(=%0d) -> $%0d",  CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd34 ) $display( "  ID  | PC=%-4d  SUB   $%0d(=%0d) - $%0d(=%0d) -> $%0d",  CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd36 ) $display( "  ID  | PC=%-4d  AND   $%0d(=%0d) & $%0d(=%0d) -> $%0d",  CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd37 ) $display( "  ID  | PC=%-4d  OR    $%0d(=%0d) | $%0d(=%0d) -> $%0d",  CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd42 ) $display( "  ID  | PC=%-4d  SLT   $%0d(=%0d) < $%0d(=%0d)? -> $%0d", CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.rd );
				else if ( CPU.funct == 6'd2  ) $display( "  ID  | PC=%-4d  SRL   $%0d(=%0d) >> %0d -> $%0d",         CPU.PC4_ID-4, CPU.rt, CPU.rt_data, CPU.shamt, CPU.rd );
				else if ( CPU.funct == 6'd25 ) $display( "  ID  | PC=%-4d  MULTU $%0d(=%0d) * $%0d(=%0d)",           CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data );
				else if ( CPU.funct == 6'd16 ) $display( "  ID  | PC=%-4d  MFHI  -> $%0d",                           CPU.PC4_ID-4, CPU.rd );
				else if ( CPU.funct == 6'd18 ) $display( "  ID  | PC=%-4d  MFLO  -> $%0d",                           CPU.PC4_ID-4, CPU.rd );
				else if ( CPU.funct == 6'd8  ) $display( "  ID  | PC=%-4d  JR    $%0d(=%0d)",                        CPU.PC4_ID-4, CPU.rs, CPU.rs_data );
				else                           $display( "  ID  | PC=%-4d  R-type funct=%0d (unknown)",               CPU.PC4_ID-4, CPU.funct );
			end
			else if ( CPU.opcode == 6'd35 ) $display( "  ID  | PC=%-4d  LW    $%0d <= Mem[$%0d(=%0d)+%0d]",             CPU.PC4_ID-4, CPU.rt, CPU.rs, CPU.rs_data, $signed(CPU.imm16) );
			else if ( CPU.opcode == 6'd43 ) $display( "  ID  | PC=%-4d  SW    $%0d(=%0d) -> Mem[$%0d(=%0d)+%0d]",       CPU.PC4_ID-4, CPU.rt, CPU.rt_data, CPU.rs, CPU.rs_data, $signed(CPU.imm16) );
			else if ( CPU.opcode == 6'd4  ) $display( "  ID  | PC=%-4d  BEQ   $%0d(=%0d)==$%0d(=%0d)? taken=%0d",       CPU.PC4_ID-4, CPU.rs, CPU.rs_data, CPU.rt, CPU.rt_data, CPU.beq_taken );
			else if ( CPU.opcode == 6'd2  ) $display( "  ID  | PC=%-4d  J     -> %0d",                                   CPU.PC4_ID-4, CPU.jump_target );
			else if ( CPU.opcode == 6'd10 ) $display( "  ID  | PC=%-4d  SLTI  $%0d(=%0d) < %0d? -> $%0d",               CPU.PC4_ID-4, CPU.rs, CPU.rs_data, $signed(CPU.imm16), CPU.rt );
			else                            $display( "  ID  | PC=%-4d  unknown opcode=%0d",                              CPU.PC4_ID-4, CPU.opcode );

			if ( CPU.RegWrite_EX || CPU.MemWrite_EX || CPU.MemRead_EX || ( CPU.Signal_EX == 6'b011001 ) )
			begin
				if      ( CPU.Signal_EX == 6'b100000 && !CPU.MemRead_EX && !CPU.MemWrite_EX )
				                               $display( "  EX  | PC=%-4d  ADD   %0d + %0d = %0d  -> $%0d",       PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b100010 ) $display( "  EX  | PC=%-4d  SUB   %0d - %0d = %0d  -> $%0d",  PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b100100 ) $display( "  EX  | PC=%-4d  AND   %0d & %0d = %0d  -> $%0d",  PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b100101 ) $display( "  EX  | PC=%-4d  OR    %0d | %0d = %0d  -> $%0d",  PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b101010 ) $display( "  EX  | PC=%-4d  SLT   %0d < %0d = %0d  -> $%0d",  PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b000010 ) $display( "  EX  | PC=%-4d  SRL   %0d >> %0d = %0d -> $%0d",  PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b011001 ) $display( "  EX  | PC=%-4d  MULTU %0d * %0d  (done=%0d)",     PC_EX, CPU.talu_dataA, CPU.talu_dataB, CPU.mult_done );
				else if ( CPU.Signal_EX == 6'b010000 ) $display( "  EX  | PC=%-4d  MFHI  -> %0d  -> $%0d",           PC_EX, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.Signal_EX == 6'b010010 ) $display( "  EX  | PC=%-4d  MFLO  -> %0d  -> $%0d",           PC_EX, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.MemRead_EX  )            $display( "  EX  | PC=%-4d  LW    addr=%0d  -> $%0d",          PC_EX, CPU.talu_out, CPU.write_reg_EX );
				else if ( CPU.MemWrite_EX )            $display( "  EX  | PC=%-4d  SW    addr=%0d  data=%0d",         PC_EX, CPU.talu_out, CPU.rt_data_EX );
			end
			else
				$display( "  EX  | NOP/bubble" );

			if ( CPU.MemWrite_MEM )
				$display( "  MEM | PC=%-4d  SW    Mem[%0d] <= %0d", PC_MEM, CPU.alu_result_MEM, CPU.rt_data_MEM );
			else if ( CPU.MemRead_MEM )
				$display( "  MEM | PC=%-4d  LW    Mem[%0d] -> %0d  -> $%0d", PC_MEM, CPU.alu_result_MEM, CPU.mem_read_data, CPU.write_reg_MEM );
			else if ( CPU.RegWrite_MEM && CPU.write_reg_MEM != 5'd0 )
				$display( "  MEM | PC=%-4d  ALU   result=%0d  -> $%0d", PC_MEM, CPU.alu_result_MEM, CPU.write_reg_MEM );
			else
				$display( "  MEM | NOP/bubble" );

			if ( CPU.RegWrite_WB && CPU.write_reg_WB != 5'd0 )
			begin
				result_data = CPU.reg_write_data;
				$display( "  WB  | PC=%-4d  $%0d <= %0d", PC_WB, CPU.write_reg_WB, result_data );
			end
			else
				$display( "  WB  | NOP/bubble" );

			$display( "  HI=%0d  LO=%0d  HiLoWr=%0d", w_HI, w_LO, w_HiLoWrite );
			$display( "  PCSrc=%0d  beq=%0d  branch_tgt=%0d  jump_tgt=%0d  PC_next=%0d",
			          w_PCSrc, w_beq_taken, w_branch_target, w_jump_target, w_PC_next );
			$display( "" );
		end
	end

	pipeline_cpu CPU( clk, rst );

endmodule
