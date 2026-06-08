# MIPS Single-Cycle and Pipelined CPU (Verilog Midterm Project)

An evolved MIPS CPU implemented in Verilog, progressing from a 32-bit ALU to a Single-Cycle CPU, and finally to a 5-Stage Pipelined CPU with hazard detection.

## Features

- **5-Stage Pipelined Architecture**: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Write Back (WB) stages.
- **Hazard Detection Unit**: Automatically stalls the pipeline to resolve data and control hazards.
- **Single-Cycle CPU**: Complete single-cycle implementation alternative included.
- **32-bit ALU**: Built from 1-bit ALU slices with support for Ripple-carry ADD/SUB, AND/OR, SLT, logical right shift (SRL) via barrel shifter, and 32-cycle unsigned multiplication (MULTU) with Hi/Lo registers.
- **Supported Instructions**:
  - **R-Type**: `ADD`, `SUB`, `AND`, `OR`, `SLT`, `SRL`, `MULTU`, `JR`
  - **I-Type**: `LW`, `SW`, `BEQ`, `SLTI`
  - **J-Type**: `J`
- **Memory & Registers**: Instruction memory, Data memory, and a 32x32-bit Register File.
- **Comprehensive Testbenches**: File-driven testbenches for the ALU (`input.txt`/`ans.txt`), Single-Cycle CPU, and Pipelined CPU (`instr_mem.txt`, `data_mem.txt`, `reg.txt`).

---

## Module Hierarchy (Pipelined CPU)

```
pipeline_cpu      ← Top-level pipelined CPU
├── PC            ← Program Counter
├── memory        ← Instruction Memory (InstrMem) and Data Memory (DatMem)
├── IF_ID         ← IF/ID Pipeline Register
├── control_single← Main Control Unit (Decodes opcode/funct)
├── reg_file      ← 32x32-bit Register File
├── sign_extend   ← 16-bit to 32-bit sign extension
├── alu_ctl       ← ALU Control Unit
├── hazard_unit   ← Pipeline Hazard Detection Unit (Stalls)
├── ID_EX         ← ID/EX Pipeline Register
├── TotalALU      ← Execution Unit (ALU + Multiplier + Shifter + HiLo)
├── EX_MEM        ← EX/MEM Pipeline Register
└── MEM_WB        ← MEM/WB Pipeline Register
```

### Standalone Modules

| File | Description |
|------|-------------|
| `pipeline_cpu.v` | Top-level 5-stage pipelined CPU module |
| `control_unit.v` | Decodes instructions and generates control signals |
| `hazard_unit.v` | Detects data hazards and stalls the pipeline |
| `IF_ID.v`, `ID_EX.v`, `EX_MEM.v`, `MEM_WB.v` | Pipeline stage registers |
| `PC.v`, `PC_mux.v` | Program Counter and Next-PC selection |
| `memory.v` | Instruction and Data Memory |
| `register_file.v` | 32x32-bit Register File |
| `TotalALU.v` | Top-level ALU wrapper (ALU, Multiplier, Shifter, HiLo) |
| `tb_Pipeline.v` | File-driven testbench for the Pipelined CPU |
| `tb_SingleCycle.v`| File-driven testbench for the Single-Cycle CPU |

---

## Supported Operations & Signal Encoding (ALU)

The `Signal` input selects the ALU operation inside the Execute stage:

| Operation | Signal (decimal) | Signal (binary) | Notes |
|-----------|-----------------|-----------------|-------|
| AND  | 36 | `100100` | Bitwise AND |
| OR   | 37 | `100101` | Bitwise OR |
| ADD  | 32 | `100000` | 32-bit addition |
| SUB  | 34 | `100010` | 32-bit subtraction (two's complement) |
| SLT  | 42 | `101010` | Set-on-less-than; output is 0 or 1 |
| SRL  | 2  | `000010` | Logical right shift (barrel shifter, 5-bit shift amount) |
| MULTU| 25 | `011001` | Unsigned multiplication (32 cycles); 64-bit result in Hi/Lo |

---

## Program Flow & Running the Testbenches

### 1. Pipelined / Single-Cycle CPU
The CPU testbenches simulate the execution of MIPS machine code from file inputs.

1. **Prepare Memory Files**:
   - `instr_mem.txt`: Machine code instructions (hex format, 1 byte per line).
   - `data_mem.txt`: Initial data memory state (hex format, 1 byte per line).
   - `reg.txt`: Initial register file state (hex format, 32-bit words per line).
2. **Simulate** using a Verilog simulator (e.g., Icarus Verilog):
   ```bash
   # For Pipeline CPU
   iverilog -o sim_pipe tb_Pipeline.v pipeline_cpu.v control_unit.v hazard_unit.v PC.v PC_mux.v memory.v register_file.v sign_extend.v add32.v IF_ID.v ID_EX.v EX_MEM.v MEM_WB.v TotalALU.v alu_ctl.v ALU.v Multiplier.v Shifter.v HiLo.v MUX.v bit_ALU.v fullAdder.v four_to_one_mux.v two_to_one_mux.v
   vvp sim_pipe
   ```
3. The testbench runs for a fixed number of cycles and dumps the final Register File and Data Memory states to the console.

### 2. Standalone ALU
1. Provide `input.txt` (test vectors) and `ans.txt` (expected results).
2. Compile and run `tb_ALU.v` along with the core ALU files. The testbench automatically checks each result.

---

## Changelog

### [2026-06-08] — Merge pull request #6 from explosionnnn/kitakaaki (`54fc7f0`)

### [2026-06-08] — update project (`07c864e`)
- **Evolved project to a 5-Stage Pipelined CPU**.
- Added Pipeline Registers (`IF_ID.v`, `ID_EX.v`, `EX_MEM.v`, `MEM_WB.v`).
- Added Instruction Fetch components (`PC.v`, `PC_mux.v`).
- Added Hazard Detection Unit (`hazard_unit.v`) to handle stalls.
- Added Control Unit (`control_unit.v`) and Register File (`register_file.v`).
- Added CPU Testbenches (`tb_Pipeline.v`, `tb_SingleCycle.v`) using `.txt` memory initialization.

### [2026-05-06] — Merge pull request #5 from explosionnnn/copilot/update-readme-newest-features (`35e59bd`)

### [2026-05-06] — 5/6 23:20 update (`6668906`)

- **Replaced unsigned divider (DIVU) with unsigned multiplier (MULTU)**
  - `Divider.v` removed; `Multiplier.v` added — shift-and-add algorithm, 32 clock cycles
  - Signal encoding changed: DIVU (`011011` / 27) → MULTU (`011001` / 25)
  - Hi/Lo registers now hold the upper and lower 32 bits of the 64-bit product
- **Barrel shifter (Shifter.v)** — reimplemented as a 5-stage mux-tree using `two_to_one_mux` primitives; supports right-shift by 0–31 bits
- `two_to_one_mux.v` added as a new primitive module
- `ALUControl.v` removed/replaced by `alu_ctl.v` and top-level logic.
- Testbench (`tb_ALU.v`) updated: MULTU wait extended to 330 ns (33 cycles)

### [2026-05-05] — 5/5 16:31 remove (`fde27c4`)

### [2026-05-05] — Delete unnecessary file (`4c47cac`)

### [2026-05-05] — Merge branch 'main' of https://github.com/explosionnnn/ALU_verilog_midterm_project (`7218566`)

### [2026-05-05] — Merge branch 'main' of https://github.com/explosionnnn/ALU_verilog_midterm_project (`bba8da6`)

### [2026-05-05] — Add files via upload (`cd7d559`)

### [2026-05-04] — Add files via upload (`c224c06`)

### [2026-05-04] — Merge pull request #4 from explosionnnn/copilot/modify-readme-with-commits (`3f5a47e`)

### [2026-05-04] — Initial commit (`5e64e8b`)

- Added all core RTL source files for the 32-bit ALU.
