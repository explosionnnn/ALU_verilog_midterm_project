# ALU Verilog Midterm Project

A 32-bit Arithmetic Logic Unit (ALU) implemented in Verilog, supporting integer arithmetic, bitwise logic, shift, and unsigned multiplication operations.

## Features

- **32-bit data path** built from individual 1-bit ALU slices
- **Ripple-carry adder** for ADD and SUB (two's complement via Binvert)
- **Bitwise AND / OR**
- **Set-on-Less-Than (SLT)**
- **Logical right shift (SRL)** — 5-stage barrel shifter built from 2-to-1 mux primitives
- **Unsigned multiplication (MULTU)** — 32-cycle shift-and-add; 64-bit result stored in Hi/Lo registers (MFHI / MFLO)
- **Synchronous reset** on all stateful components
- **File-driven testbench** — reads `input.txt` / `ans.txt` and auto-checks every result

---

## Module Hierarchy

```
TotalALU          ← top-level integration module
├── ALUControl    ← decodes 6-bit Signal and routes to each sub-unit
├── ALU           ← 32-bit logic/arithmetic (AND, OR, ADD, SUB, SLT)
│   └── bit_ALU × 32  ← 1-bit ALU slice
│       ├── fullAdder
│       └── four_to_one_mux
├── Multiplier    ← unsigned 32-bit multiplier (shift-and-add, 32 cycles)
├── Shifter       ← 5-stage barrel shifter (SRL, built from two_to_one_mux)
├── HiLo          ← Hi/Lo registers that store upper/lower 32 bits of product
└── MUX           ← output selector
```

### Standalone modules

| File | Module | Description |
|------|--------|-------------|
| `fullAdder.v` | `fullAdder` | 1-bit full adder |
| `four_to_one_mux.v` | `four_to_one_mux` | 1-bit 4-to-1 multiplexer |
| `two_to_one_mux.v` | `two_to_one_mux` | 1-bit 2-to-1 multiplexer (used by Shifter) |
| `bit_ALU.v` | `bit_ALU` | 1-bit ALU slice (AND / OR / ADD+SUB) |
| `ALU.v` | `ALU` | 32-bit ALU (AND / OR / ADD / SUB / SLT) |
| `Multiplier.v` | `Multiplier` | 32-cycle shift-and-add unsigned multiplier (64-bit output) |
| `Shifter.v` | `Shifter` | 5-stage barrel shifter (SRL, up to 31-bit shift) |
| `HiLo.v` | `HiLo` | Hi/Lo registers for upper/lower 32 bits of multiplication result |
| `MUX.v` | `MUX` | Output selector mux |
| `TotalALU.v` | `TotalALU` | Top-level: ALU + Multiplier + Shifter + HiLo + MUX + ALUControl |
| `tb_ALU.v` | `tb_ALU` | File-driven testbench for `TotalALU` |

---

## Supported Operations & Signal Encoding

The 6-bit `Signal` input selects the operation:

| Operation | Signal (decimal) | Signal (binary) | Notes |
|-----------|-----------------|-----------------|-------|
| AND  | 36 | `100100` | Bitwise AND |
| OR   | 37 | `100101` | Bitwise OR |
| ADD  | 32 | `100000` | 32-bit addition |
| SUB  | 34 | `100010` | 32-bit subtraction (two's complement) |
| SLT  | 42 | `101010` | Set-on-less-than; output is 0 or 1 |
| SRL  | 2  | `000010` | Logical right shift (barrel shifter, 5-bit shift amount in dataB) |
| MULTU| 25 | `011001` | Unsigned multiplication (32 cycles); 64-bit result in Hi/Lo |
| MFHI | 16 | `010000` | Move from Hi register (upper 32 bits of product) |
| MFLO | 18 | `010010` | Move from Lo register (lower 32 bits of product) |

---

## Running the Testbench

1. Prepare **`input.txt`** — one test vector per line in the format:

   ```
   <Signal>  <InputA>  <InputB>
   ```

2. Prepare **`ans.txt`** — one expected result per line (for MULTU, provide two lines: Hi then Lo).

3. Simulate with any Verilog simulator (e.g., ModelSim, Icarus Verilog):

   ```bash
   # Icarus Verilog example
   iverilog -o sim tb_ALU.v TotalALU.v ALUControl.v ALU.v Multiplier.v Shifter.v HiLo.v MUX.v bit_ALU.v fullAdder.v four_to_one_mux.v two_to_one_mux.v
   vvp sim
   ```

4. The testbench prints `Correct` or `Wrong Answer` for each test case along with the expected and actual values.
   > **Note:** MULTU operations require 33 clock cycles (330 ns) to complete; the testbench handles this automatically.

---

## Changelog

### [2026-06-08] — update project (`07c864e`)

### [2026-05-06] — Merge pull request #5 from explosionnnn/copilot/update-readme-newest-features (`35e59bd`)

### [2026-05-06] — 5/6 23:20 update (`6668906`)

- **Replaced unsigned divider (DIVU) with unsigned multiplier (MULTU)**
  - `Divider.v` removed; `Multiplier.v` added — shift-and-add algorithm, 32 clock cycles
  - Signal encoding changed: DIVU (`011011` / 27) → MULTU (`011001` / 25)
  - Hi/Lo registers now hold the upper and lower 32 bits of the 64-bit product
- **Barrel shifter (Shifter.v)** — reimplemented as a 5-stage mux-tree using `two_to_one_mux` primitives; supports right-shift by 0–31 bits
- `two_to_one_mux.v` added as a new primitive module
- `ALUControl.v` — counter-based sequencer updated to gate 32 MULTU cycles before asserting done
- Testbench (`tb_ALU.v`) updated: MULTU wait extended to 330 ns (33 cycles)
- `architecture.md` added — documents top-level signal flow and module interfaces

### [2026-05-05] — 5/5 16:31 remove (`fde27c4`)

### [2026-05-05] — Delete unnecessary file (`4c47cac`)

### [2026-05-05] — Merge branch 'main' of https://github.com/explosionnnn/ALU_verilog_midterm_project (`7218566`)

### [2026-05-05] — Merge branch 'main' of https://github.com/explosionnnn/ALU_verilog_midterm_project (`bba8da6`)

### [2026-05-05] — Add files via upload (`cd7d559`)

### [2026-05-04] — Add files via upload (`c224c06`)

### [2026-05-04] — Merge pull request #4 from explosionnnn/copilot/modify-readme-with-commits (`3f5a47e`)

### [2026-05-04] — Initial commit (`5e64e8b`)

- Added all core RTL source files:
  - `fullAdder.v` — 1-bit full adder primitive
  - `four_to_one_mux.v` — 1-bit 4-to-1 mux primitive
  - `bit_ALU.v` — 1-bit ALU slice built from the above primitives
  - `ALU_Adder.v` — standalone 32-bit ripple-carry adder
  - `ALU.v` — 32-bit ALU supporting AND, OR, ADD, SUB, SLT
  - `TotalALU.v` — top-level integration (ALU + Divider + Shifter + HiLo + MUX + ALUControl) adding SRL and DIVU support
  - `tb_ALU.v` — file-driven testbench with auto-check against answer file
