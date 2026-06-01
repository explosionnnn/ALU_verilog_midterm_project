`timescale 1ns/1ns
module mips_single( clk, rst );
	input clk, rst;

	// ===== 指令匯流排 =====
	wire [31:0] instr;

	// ===== 指令欄位拆解 =====
	wire [5:0]  opcode, funct;
	wire [4:0]  rs, rt, rd, shamt;
	wire [15:0] imm16;
	wire [25:0] jump_index;

	// ===== PC 相關位址 =====
	wire [31:0] PC_addr;
	wire [31:0] PC_plus4;
	wire [31:0] PC_next;
	wire [31:0] branch_target;
	wire [31:0] jump_target;
	wire [31:0] branch_offset;
	wire [27:0] jump_shifted;

	// ===== 資料路徑 =====
	wire [31:0] sign_ext_imm;
	wire [4:0]  reg_write_num;
	wire [31:0] rs_data, rt_data;
	wire [31:0] reg_write_data;
	wire [31:0] alu_in2;
	wire [31:0] talu_dataA, talu_dataB;
	wire [31:0] talu_out;
	wire [31:0] mem_read_data;
	wire        is_srl;

	// ===== 控制訊號 =====
	wire RegWrite, Branch, RegDst, MemtoReg, MemRead, MemWrite, ALUSrc, Zero, Jump, JumpReg;
	wire [1:0] ALUOp, PCSrc;
	wire [5:0] Signal;

	// ===== 指令欄位切割 =====
	assign opcode     = instr[31:26];
	assign rs         = instr[25:21];
	assign rt         = instr[20:16];
	assign rd         = instr[15:11];
	assign shamt      = instr[10:6];
	assign funct      = instr[5:0];
	assign imm16      = instr[15:0];
	assign jump_index = instr[25:0];

	// ===== 位址計算 =====
	assign branch_offset = sign_ext_imm << 2;
	assign jump_shifted  = jump_index << 2;
	assign jump_target   = { PC_plus4[31:28], jump_shifted };

	// ===== PC 選址:00=PC+4, 01=branch, 10=jump, 11=jr =====
	assign PCSrc = JumpReg ? 2'b11 :
	               Jump    ? 2'b10 :
	               ( Branch & Zero ) ? 2'b01 : 2'b00;

	// ===== 暫存器寫入編號、ALU 第二輸入 =====
	assign reg_write_num = RegDst ? rd : rt;
	assign alu_in2       = ALUSrc ? sign_ext_imm : rt_data;

	// ===== srl 用 rt_data/shamt,其餘用 rs_data/alu_in2 =====
	assign is_srl     = ( Signal == 6'b000010 );
	assign talu_dataA = is_srl ? rt_data          : rs_data;
	assign talu_dataB = is_srl ? { 27'b0, shamt } : alu_in2;

	// ===== beq 的 zero 由 TotalALU 輸出推得(beq 時 Signal=SUB) =====
	assign Zero = ( talu_out == 32'b0 );

	// ===== Write-back:lw 取記憶體,其餘取 TotalALU =====
	assign reg_write_data = MemtoReg ? mem_read_data : talu_out;

	// ===== 模組實例化 =====

	PC PC( .clk(clk), .reset(rst), .PCWrite(1'b1), .PC_in(PC_next), .PC_out(PC_addr) );

	add32 PCADD( .a(PC_addr),  .b(32'd4),         .result(PC_plus4) );

	add32 BRADD( .a(PC_plus4), .b(branch_offset), .result(branch_target) );

	sign_extend SignExt( .immed_in(imm16), .ext_immed_out(sign_ext_imm) );

	PC_mux PCMUX( .PC_plus4(PC_plus4), .Branch_addr(branch_target),
	              .Jump_addr(jump_target), .JR_addr(rs_data),
	              .PCSrc(PCSrc), .PC_next(PC_next) );

	control_single CTL( .opcode(opcode), .funct(funct), .RegDst(RegDst), .ALUSrc(ALUSrc),
	                    .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch),
	                    .Jump(Jump), .JumpReg(JumpReg), .MemtoReg(MemtoReg), .ALUOp(ALUOp) );

	alu_ctl ALUCTL( .ALUOp(ALUOp), .Funct(funct), .ALUOperation(Signal) );

	TotalALU TALU( .clk(clk), .dataA(talu_dataA), .dataB(talu_dataB), .Signal(Signal),
	               .Output(talu_out), .reset(rst) );

	reg_file RegFile( .clk(clk), .RegWrite(RegWrite), .RN1(rs), .RN2(rt), .WN(reg_write_num),
	                  .WD(reg_write_data), .RD1(rs_data), .RD2(rt_data) );

	memory InstrMem( .clk(clk), .MemRead(1'b1), .MemWrite(1'b0), .wd(32'd0),
	                 .addr(PC_addr), .rd(instr) );

	memory DatMem( .clk(clk), .MemRead(MemRead), .MemWrite(MemWrite), .wd(rt_data),
	               .addr(talu_out), .rd(mem_read_data) );

endmodule
