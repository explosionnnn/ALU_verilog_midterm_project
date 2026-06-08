`timescale 1ns/1ns
module pipeline_cpu( clk, rst );
	input clk, rst;

	// ===================== 所有 wire 宣告 =====================
	// IF
	wire [31:0] PC_addr, PC_plus4, PC_next, instr_IF;
	wire PCWrite, IFIDWrite, Stall, IFID_Flush, MultStall, AnyStall, mult_done;
	wire [1:0]  PCSrc;
	wire [31:0] branch_target, jump_target;

	// IF/ID
	wire [31:0] PC4_ID, instr_ID;

	// ID
	wire [5:0]  opcode, funct;
	wire [4:0]  rs, rt, rd, shamt;
	wire [15:0] imm16;
	wire [25:0] jump_index;
	wire [27:0] jump_shifted;
	wire [31:0] sign_ext_imm, branch_offset;
	wire [31:0] rs_data, rt_data;
	wire [5:0]  Signal_ID;
	wire [1:0]  ALUOp;
	wire RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID;
	wire Branch_ID, Jump_ID, JumpReg_ID, RegDst_ID, ALUSrc_ID;
	wire [4:0]  write_reg_ID;
	wire beq_taken;

	// ID/EX
	wire RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, ALUSrc_EX;
	wire [5:0]  Signal_EX;
	wire [31:0] rs_data_EX, rt_data_EX, signext_EX;
	wire [4:0]  shamt_EX, write_reg_EX;

	// EX
	wire [31:0] alu_in2, talu_dataA, talu_dataB, talu_out;
	wire is_srl;

	// EX/MEM
	wire RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM;
	wire [31:0] alu_result_MEM, rt_data_MEM;
	wire [4:0]  write_reg_MEM;

	// MEM
	wire [31:0] mem_read_data;

	// MEM/WB
	wire RegWrite_WB, MemtoReg_WB;
	wire [31:0] mem_data_WB, alu_result_WB;
	wire [4:0]  write_reg_WB;

	// WB
	wire [31:0] reg_write_data;

	// ===================== IF 階段 =====================
	assign MultStall  = ( Signal_EX == 6'b011001 ) & ~mult_done;
	assign AnyStall   = Stall | MultStall;
	assign PCWrite    = ~AnyStall;
	assign IFIDWrite  = ~AnyStall;
	assign IFID_Flush = ~AnyStall & ( PCSrc != 2'b00 );

	PC PC( .clk(clk), .reset(rst), .PCWrite(PCWrite), .PC_in(PC_next), .PC_out(PC_addr) );

	add32 PCADD( .a(PC_addr), .b(32'd4), .result(PC_plus4) );

	memory InstrMem( .clk(clk), .MemRead(1'b1), .MemWrite(1'b0), .wd(32'd0),
	                 .addr(PC_addr), .rd(instr_IF) );

	PC_mux PCMUX( .PC_plus4(PC_plus4), .Branch_addr(branch_target),
	              .Jump_addr(jump_target), .JR_addr(rs_data),
	              .PCSrc(PCSrc), .PC_next(PC_next) );

	// ===================== IF/ID =====================
	IF_ID ifid( .clk(clk), .reset(rst), .IFIDWrite(IFIDWrite), .Flush(IFID_Flush),
	            .PC4_in(PC_plus4), .instr_in(instr_IF),
	            .PC4_out(PC4_ID), .instr_out(instr_ID) );

	// ===================== ID 階段 =====================
	assign opcode     = instr_ID[31:26];
	assign rs         = instr_ID[25:21];
	assign rt         = instr_ID[20:16];
	assign rd         = instr_ID[15:11];
	assign shamt      = instr_ID[10:6];
	assign funct      = instr_ID[5:0];
	assign imm16      = instr_ID[15:0];
	assign jump_index = instr_ID[25:0];

	control_single CTL( .opcode(opcode), .funct(funct), .RegDst(RegDst_ID), .ALUSrc(ALUSrc_ID),
	                    .RegWrite(RegWrite_ID), .MemRead(MemRead_ID), .MemWrite(MemWrite_ID),
	                    .Branch(Branch_ID), .Jump(Jump_ID), .JumpReg(JumpReg_ID),
	                    .MemtoReg(MemtoReg_ID), .ALUOp(ALUOp) );

	reg_file RegFile( .clk(clk), .RegWrite(RegWrite_WB), .RN1(rs), .RN2(rt), .WN(write_reg_WB),
	                  .WD(reg_write_data), .RD1(rs_data), .RD2(rt_data) );

	sign_extend SignExt( .immed_in(imm16), .ext_immed_out(sign_ext_imm) );

	alu_ctl ALUCTL( .ALUOp(ALUOp), .Funct(funct), .ALUOperation(Signal_ID) );

	assign jump_shifted  = jump_index << 2;
	assign jump_target   = { PC4_ID[31:28], jump_shifted };
	assign branch_offset = sign_ext_imm << 2;

	add32 BRADD( .a(PC4_ID), .b(branch_offset), .result(branch_target) );

	assign write_reg_ID = RegDst_ID ? rd : rt;

	assign beq_taken = Branch_ID & ( rs_data == rt_data );
	assign PCSrc = JumpReg_ID ? 2'b11 :
	               Jump_ID    ? 2'b10 :
	               beq_taken  ? 2'b01 : 2'b00;

	hazard_unit HZD( .rs(rs), .rt(rt),
	                 .IDEX_RegWrite(RegWrite_EX), .IDEX_wreg(write_reg_EX),
	                 .EXMEM_RegWrite(RegWrite_MEM), .EXMEM_wreg(write_reg_MEM),
	                 .MEMWB_RegWrite(RegWrite_WB), .MEMWB_wreg(write_reg_WB),
	                 .Stall(Stall) );

	// ===================== ID/EX =====================
	ID_EX idex( .clk(clk), .reset(rst), .Flush(Stall), .Hold(MultStall),
	            .RegWrite_in(RegWrite_ID), .MemtoReg_in(MemtoReg_ID), .MemRead_in(MemRead_ID),
	            .MemWrite_in(MemWrite_ID), .ALUSrc_in(ALUSrc_ID), .Signal_in(Signal_ID),
	            .rs_data_in(rs_data), .rt_data_in(rt_data), .signext_in(sign_ext_imm),
	            .shamt_in(shamt), .write_reg_in(write_reg_ID),
	            .RegWrite_out(RegWrite_EX), .MemtoReg_out(MemtoReg_EX), .MemRead_out(MemRead_EX),
	            .MemWrite_out(MemWrite_EX), .ALUSrc_out(ALUSrc_EX), .Signal_out(Signal_EX),
	            .rs_data_out(rs_data_EX), .rt_data_out(rt_data_EX), .signext_out(signext_EX),
	            .shamt_out(shamt_EX), .write_reg_out(write_reg_EX) );

	// ===================== EX 階段 =====================
	assign alu_in2    = ALUSrc_EX ? signext_EX : rt_data_EX;
	assign is_srl     = ( Signal_EX == 6'b000010 );
	assign talu_dataA = is_srl ? rt_data_EX          : rs_data_EX;
	assign talu_dataB = is_srl ? { 27'b0, shamt_EX } : alu_in2;

	TotalALU TALU( .clk(clk), .dataA(talu_dataA), .dataB(talu_dataB), .Signal(Signal_EX),
	               .Output(talu_out), .mult_done(mult_done), .reset(rst) );

	// ===================== EX/MEM =====================
	EX_MEM exmem( .clk(clk), .reset(rst),
	              .RegWrite_in(RegWrite_EX), .MemtoReg_in(MemtoReg_EX), .MemRead_in(MemRead_EX),
	              .MemWrite_in(MemWrite_EX),
	              .alu_result_in(talu_out), .rt_data_in(rt_data_EX), .write_reg_in(write_reg_EX),
	              .RegWrite_out(RegWrite_MEM), .MemtoReg_out(MemtoReg_MEM), .MemRead_out(MemRead_MEM),
	              .MemWrite_out(MemWrite_MEM),
	              .alu_result_out(alu_result_MEM), .rt_data_out(rt_data_MEM), .write_reg_out(write_reg_MEM) );

	// ===================== MEM 階段 =====================
	memory DatMem( .clk(clk), .MemRead(MemRead_MEM), .MemWrite(MemWrite_MEM), .wd(rt_data_MEM),
	               .addr(alu_result_MEM), .rd(mem_read_data) );

	// ===================== MEM/WB =====================
	MEM_WB memwb( .clk(clk), .reset(rst),
	              .RegWrite_in(RegWrite_MEM), .MemtoReg_in(MemtoReg_MEM),
	              .mem_data_in(mem_read_data), .alu_result_in(alu_result_MEM), .write_reg_in(write_reg_MEM),
	              .RegWrite_out(RegWrite_WB), .MemtoReg_out(MemtoReg_WB),
	              .mem_data_out(mem_data_WB), .alu_result_out(alu_result_WB), .write_reg_out(write_reg_WB) );

	// ===================== WB 階段 =====================
	assign reg_write_data = MemtoReg_WB ? mem_data_WB : alu_result_WB;

endmodule
