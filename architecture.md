# TotalALU 架構圖

## 整體 Datapath

```
                         6-bit Signal
                              |
                       [ALUControl]
                    (Sequential, clk同步)
                    /      |      \     \
                   /       |       \     \
          SignaltoALU  SignaltoSHT  SignaltoDIV  SignaltoMUX
               |            |            |            |
               v            v            v            |
dataA ──┬──→ [ALU]    ──→ [Shifter] ──→ [Multiplier] |
dataB ──┼──→ (組合)   ──→ (組合)    ──→ (循序,clk)   |
        |                                |            |
        |                           [HiLo Reg]        |
        |                          (循序,clk)          |
        |                          /        \          |
        |                      HiOut       LoOut       |
        |                          \        /          |
        └──── ALUOut ─────────────→ [MUX] ←───────────┘
               ShifterOut ────────→       (Data Flow)
               HiOut ─────────────→       
               LoOut ─────────────→       
                                     |
                                  dataOut
                                     |
                                  Output
```

---

## 各模組說明

| 模組 | 類型 | 負責運算 |
|------|------|----------|
| ALUControl | 循序（clk） | 解碼 6-bit Signal，分配控制訊號給各模組 |
| ALU | 組合 | AND / OR / ADD / SUB / SLT |
| Shifter | 組合 | SRL（Barrel Shifter，160 個 Mux） |
| Multiplier | 循序（clk） | MULTU |
| HiLo | 循序（clk） | 儲存乘法結果（Hi 高32bit / Lo 低32bit） |
| MUX | 組合 | 根據 Signal 選擇最終輸出來源 |

---

## ALU 內部結構

```
dataA[31:0] ──┐
dataB[31:0] ──┤── Binvert ──→ b_in = dataB ^ Binvert
              |
              ├─ alu0 (bit 0) ──c[1]──→ alu1 ──c[2]──→ ... ──→ alu31 (bit 31)
              |    ↑                      ↑                         ↑
              |  c[0]=Binvert           carry chain (Ripple-Carry)
              |
              └─ out_w[31:0]
                    |
              (SLT) ? {31'b0, out_w[31]} : out_w
                    |
                 dataOut
```

### bit_ALU 內部

```
bit_a ──┐
b_in  ──┼──→ [fullAdder] ──→ sum_fa ──┐
carry_in┘         |                    ├──→ [4-to-1 MUX] ──→ out
                carry_out          bit_a & b_in (AND)
                  (傳到下一bit)     bit_a | b_in (OR)
                                   sum_fa        (ADD/SUB)
                                   1'b0          (default)
```

---

## Control Signal 對照表

| 操作 | Signal (dec) | Signal (bin) | Binvert | sel |
|------|-------------|--------------|---------|-----|
| AND  | 36 | 100100 | 0 | 00 |
| OR   | 37 | 100101 | 0 | 01 |
| ADD  | 32 | 100000 | 0 | 10 |
| SUB  | 34 | 100010 | 1 | 10 |
| SLT  | 42 | 101010 | 1 | 10 |
| SRL  | 02 | 000010 | - | -  |
| MULTU| 25 | 011001 | - | -  |
