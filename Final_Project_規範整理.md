## 114-2 計算機組織 Final Project: Pipelined CPU Design

### 重要時程

| 項目 | 時間 |
|------|------|
| 報告與程式碼上傳 | 2026/06/12 PM 9:00 前 |
| 機測時間表填寫 | 2026/06/12 PM 9:00 前(電學 702 門口) |
| 機測 | 2026/06/15 電學 310 |

### 專案目標

以 Midterm Project 的 ALU 與 Multiplier 為基礎,延伸設計一顆 **5-Stage Pipelined MIPS-Lite CPU**,跑出指定的 16 條 MIPS 指令。

---

### 需實現的 16 條指令

| 類別 | 指令 |
|------|------|
| Integer Arithmetic(7) | "add"、"sub"、"and"、"or"、"srl"、"slt"、"slti" |
| Integer Memory(2) | "lw"、"sw" |
| Integer Branch(3) | "beq"、"j"、"jr" |
| Multiply(1) | "multu" |
| Other(3) | "mfhi"、"mflo"、"nop" |

說明:slti 是 Midterm 沒做的(I-type),要新增立即數比較邏輯。

---

### 設計要求(每項違反該項不計分)

1. **ALU**:必須沿用 Midterm 的 ALU,負責 "add / sub / and / or / srl / slt / slti"
2. **Datapath**:5-Stage Pipelined CPU 行為(IF → ID → EX → MEM → WB)
3. **multu**:必須沿用 Midterm 的 Multiplier
4. **Testbench**:讀檔輸入測試資料,不可寫死

### 設計注意事項

1. **一個 Module 一個檔案**,檔名等於 Module 名稱
2. Datapath 跟課本有差異,要自行修改並用 PowerPoint 畫圖
3. Testbench 要參考助教給的範例改寫(i-Learning 有 Single Cycle CPU and Testbench)
4. 只能用課堂教過的 Verilog 語法,不可 Schematic

### 全域禁止事項(扣分嚴重)

| 禁止 | 例外 |
|------|------|
| 不能有 "for" / "while" 等迴圈 | Testbench 可以 |
| 不能有 "Function" / "Task" | 無 |
| 不能有 "always @(*)" | 無 |
| 不能有指令以外的電路(註解過也算) | 無,每個扣學期總成績 5% |
| 程式中**所有註解都要移除** | 無,未移除扣分 |

### AI 使用規範

- 必須使用 AI Agent 協作
- 報告需要紀錄:
  - 使用的所有 AI 工具(例如 Claude Code、ChatGPT 等)
  - 完整的 AI Agent Prompt
  - 對話紀錄(Word 電子檔,不能只給連結)

---

### Pipeline 5 階段

| 階段 | 縮寫 | 主要工作 |
|------|------|---------|
| Instruction Fetch | IF | 從 InstMem 取出指令,PC ← PC + 4 |
| Instruction Decode | ID | 解碼指令、讀 RegFile、產生控制訊號 |
| Execute | EX | ALU 運算 / Multiplier 啟動 / 分支位址計算 |
| Memory Access | MEM | "lw" 讀 DataMem / "sw" 寫 DataMem |
| Write Back | WB | 把 ALU 或 Mem 結果寫回 RegFile |

每階段之間要有 Pipeline Register: "IF/ID"、"ID/EX"、"EX/MEM"、"MEM/WB"。

---

### 需要新增的模組(Midterm 沒做的)

| 模組 | 用途 |
|------|------|
| "PC" | 程式計數器(reg) |
| "Adder_PC" | 算 PC + 4 |
| "InstructionMemory" | 存指令的 ROM(讀檔載入) |
| "RegisterFile" | 32 個 32-bit 通用暫存器 |
| "SignExtend" | 16-bit 立即數做有號擴展到 32-bit |
| "Control" | 主控制單元(看 opcode 產生控制訊號) |
| "DataMemory" | 資料記憶體(支援 read / write) |
| "IF_ID_Reg" | IF/ID Pipeline Register |
| "ID_EX_Reg" | ID/EX Pipeline Register |
| "EX_MEM_Reg" | EX/MEM Pipeline Register |
| "MEM_WB_Reg" | MEM/WB Pipeline Register |
| "ForwardingUnit" | 解決資料相依的轉送 |
| "HazardUnit" | 處理 load-use stall / 分支 stall |
| "MUX_2to1_32bit"、"MUX_4to1_32bit" 等 | 各種多工器 |

### 可以直接搬過來的 Midterm 模組

| 模組 | 用途 |
|------|------|
| "ALU.v" | 32-bit ALU |
| "bit_ALU.v"、"fullAdder.v"、"four_to_one_mux.v" | ALU 子模組 |
| "Multiplier.v" | 32-bit 乘法器 |
| "HiLo.v" | Hi / Lo 暫存器 |
| "Shifter.v"、"two_to_one_mux.v" | Barrel Shifter |
| "ALUControl.v" | 訊號分配(可能需要調整) |

要注意:Midterm 的 "TotalALU.v" 不能直接用,因為 Final 的 ALU 是要嵌進 EX 階段的,不再是頂層模組。"tb_ALU.v" 也要重寫成跑指令程式碼。

---

### 報告要求

- 至少 8 頁,依「計算機組織報告格式」撰寫
- 必須包含:
  1. 組別、學號、班別、姓名
  2. **Datapath 與詳細架構圖**(PowerPoint 繪製,未用 PPT 會扣分)
  3. 設計重點說明
  4. ModelSim 驗證結果 + Waveform
  5. 心得感想
  6. 各組員分工

### 繳交檔案

打包成 "CO_Final_班級_組員學號_組員姓名_重傳次數.7z",內含:

1. 報告 Word 電子檔
2. 架構圖 PowerPoint 電子檔
3. AI 工具使用紀錄報告 Word 電子檔
4. 所有程式檔案與執行目錄
