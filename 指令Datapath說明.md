# 各指令 Datapath 說明(Single-Cycle)

對照 "mips_cpu.v"、"control_unit.v"、"alu_ctl.v"、"TotalALU.v"。

---

## 一、整體資料流

```
            +--------+      +-----------+
   PC ----->| Instr  |----->|  指令欄位  |---> opcode/rs/rt/rd/shamt/funct/imm/index
   |        |  Mem   |      |   切割     |
   |        +--------+      +-----------+
   |                              |
   |          +---------+    +----------+    +---------+
   |          | control |    | reg_file |    | alu_ctl |
   |          | _single |    | (讀 rs,rt)|    |         |
   |          +---------+    +----------+    +---------+
   |               |              |               |
   |          控制訊號群       rs_data,rt_data    Signal
   |               |              |               |
   |               v              v               v
   |          +----------------------------------------+
   |          |            TotalALU(執行)              |
   |          |   ALU / Shifter / Multiplier / HiLo    |
   |          +----------------------------------------+
   |                          |
   |                       talu_out
   |          +----------+      |
   |          | DatMem   |<-----+ (位址)
   |          +----------+
   |               |  mem_read_data
   |               v
   |          [Write-back MUX] --(MemtoReg)--> reg_write_data ---> reg_file 寫回
   |
   +----[PC_mux]<--- PC+4 / branch / jump / jr (由 PCSrc 選)
```

---

## 二、控制訊號總表

| 指令 | RegDst | ALUSrc | RegWrite | MemRead | MemWrite | Branch | Jump | JumpReg | MemtoReg | ALUOp |
|------|--------|--------|----------|---------|----------|--------|------|---------|----------|-------|
| add/sub/and/or/slt | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 10 |
| srl | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 10 |
| slti | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 11 |
| lw | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 00 |
| sw | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 00 |
| beq | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 01 |
| j | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 00 |
| jr | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 10 |
| mfhi/mflo | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 10 |
| nop | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 00 |

ALUOp → alu_ctl 輸出 Signal:00=ADD、01=SUB、11=SLT、10=傳 funct。

---

## 三、各指令 Datapath

### add / sub / and / or / slt(R-type 算術)

範例:"add $rd, $rs, $rt"

1. PC → InstrMem 取指令
2. 切出 opcode=0、rs、rt、rd、funct
3. control:funct≠0且≠8 → 一般 R-type(RegDst=1, RegWrite=1, ALUOp=10)
4. reg_file 讀 rs_data、rt_data
5. alu_ctl:ALUOp=10 → Signal=funct(例 ADD=100000)
6. talu_dataA=rs_data、talu_dataB=rt_data(ALUSrc=0)
7. TotalALU:ALU 運算 → ALUOut → MUX 選 ALUOut → talu_out
8. Write-back:MemtoReg=0 → reg_write_data=talu_out
9. reg_file:寫回 rd(RegDst=1)
10. PC_mux:PCSrc=00 → PC+4

---

### srl(邏輯右移)

範例:"srl $rd, $rt, shamt"

1~4. 取指令、切欄位、control(同 R-type)、讀 rt_data
5. alu_ctl → Signal=SRL(000010)
6. **is_srl=1** → talu_dataA=rt_data、talu_dataB={27'b0, shamt}
7. TotalALU:Shifter 把 rt_data 右移 shamt 位 → ShifterOut → MUX 選 Shifter → talu_out
8. Write-back → reg_write_data=talu_out
9. 寫回 rd
10. PC+4

重點:srl 的移位量來自 **shamt(instr[10:6])**,不是暫存器。

---

### slti(立即數比大小)

範例:"slti $rt, $rs, imm"

1. 取指令,opcode=10
2. control SLTI:RegDst=0(寫 rt)、ALUSrc=1(用立即數)、RegWrite=1、ALUOp=11
3. reg_file 讀 rs_data
4. sign_extend:imm16 → sign_ext_imm(有號擴展)
5. alu_ctl:ALUOp=11 → Signal=SLT
6. talu_dataA=rs_data、talu_dataB=sign_ext_imm(ALUSrc=1)
7. TotalALU:ALU 做 SLT(rs < imm ?)→ ALUOut(0 或 1)→ talu_out
8. Write-back → 寫回 rt(RegDst=0)
9. PC+4

---

### lw(載入)

範例:"lw $rt, offset($rs)"

1. 取指令,opcode=35
2. control LW:ALUSrc=1、RegWrite=1、MemRead=1、MemtoReg=1、ALUOp=00
3. reg_file 讀 rs_data(base)
4. sign_extend:offset → sign_ext_imm
5. alu_ctl:ALUOp=00 → Signal=ADD
6. TotalALU:rs_data + offset = 記憶體位址 → talu_out
7. DatMem:用 talu_out 當位址讀出 → mem_read_data
8. Write-back:**MemtoReg=1** → reg_write_data=mem_read_data
9. 寫回 rt(RegDst=0)
10. PC+4

---

### sw(儲存)

範例:"sw $rt, offset($rs)"

1. 取指令,opcode=43
2. control SW:ALUSrc=1、MemWrite=1、RegWrite=0、ALUOp=00
3. reg_file 讀 rs_data(base)、rt_data(要存的值)
4. sign_extend:offset → sign_ext_imm
5. alu_ctl → Signal=ADD
6. TotalALU:rs_data + offset = 位址 → talu_out
7. DatMem:用 talu_out 當位址,把 rt_data 寫進去(MemWrite=1)
8. 不寫暫存器(RegWrite=0)
9. PC+4

---

### beq(相等則分支)

範例:"beq $rs, $rt, offset"

1. 取指令,opcode=4
2. control BEQ:Branch=1、ALUOp=01、RegWrite=0
3. reg_file 讀 rs_data、rt_data
4. alu_ctl:ALUOp=01 → Signal=SUB
5. talu_dataA=rs_data、talu_dataB=rt_data(ALUSrc=0)
6. TotalALU:ALU 做 rs−rt → talu_out
7. **Zero =(talu_out==0)**,即 rs==rt
8. branch_target = PC+4 +(sign_ext_imm << 2)
9. PC_mux:若 Branch & Zero → PCSrc=01 → PC=branch_target;否則 PC+4
10. 不寫暫存器、不寫記憶體

---

### j(無條件跳躍)

範例:"j target"

1. 取指令,opcode=2
2. control J:Jump=1,其餘寫入訊號=0
3. jump_target = { PC+4[31:28], index << 2 }
4. PC_mux:PCSrc=10 → PC=jump_target
5. 不寫暫存器、不寫記憶體

---

### jr(暫存器跳躍)

範例:"jr $rs"

1. 取指令,opcode=0、funct=8
2. control:funct==8 → JumpReg=1、RegWrite=0
3. reg_file 讀 rs_data
4. PC_mux:PCSrc=11 → PC=JR_addr=rs_data
5. talu_out 被忽略(RegWrite=0)
6. 不寫暫存器、不寫記憶體

---

### mfhi / mflo(讀 Hi/Lo)

範例:"mfhi $rd" / "mflo $rd"

1. 取指令,opcode=0、funct=16(mfhi)或 18(mflo)
2. control:一般 R-type(RegDst=1, RegWrite=1, ALUOp=10)
3. alu_ctl:ALUOp=10 → Signal=funct(MFHI=010000 或 MFLO=010010)
4. TotalALU:MUX 選 HiOut(mfhi)或 LoOut(mflo)→ talu_out
5. Write-back → 寫回 rd
6. PC+4

注意:Hi/Lo 的值由 multu 產生。目前未接 multu,故讀到 0;datapath 已完整,補 multu 後即有真值。

---

### nop(空指令 / pipeline bubble)

範例:"nop"(= 0x00000000)

1. 取指令,opcode=0、funct=0
2. control:funct==0 → **所有控制訊號=0**(RegWrite=0、MemWrite=0、不跳轉)
3. 指令流過但不改變任何狀態
4. PC+4

用途:後續 pipeline 偵測到 hazard 時,把控制訊號強制清成這組全 0,即插入一個 bubble(stall)。

---

### multu(暫未實作)

32-bit 無號乘法,需循序乘法器(33 個 clk)。單周期無法一個 clk 完成,留待 pipeline 版處理。TotalALU 內已含 Multiplier,補上控制與時序即可啟用。

---

## 四、PC 更新邏輯總結

```verilog
PCSrc = JumpReg        ? 2'b11 (jr  → rs_data)
      : Jump           ? 2'b10 (j   → jump_target)
      : (Branch & Zero)? 2'b01 (beq → branch_target)
      :                  2'b00 (其餘 → PC+4)
```
