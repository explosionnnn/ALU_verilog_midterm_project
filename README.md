# ALU Verilog Midterm Project

A 32-bit Arithmetic Logic Unit (ALU) implemented in Verilog, supporting integer arithmetic, bitwise logic, shift, and unsigned division operations.

## Features

- **32-bit data path** built from individual 1-bit ALU slices
- **Ripple-carry adder** for ADD and SUB (two's complement via Binvert)
- **Bitwise AND / OR**
- **Set-on-Less-Than (SLT)**
- **Logical right shift (SRL)**
- **Unsigned division (DIVU)** with separate Hi/Lo result registers (MFHI / MFLO)
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
├── Divider       ← unsigned 32-bit divider (multi-cycle)
├── Shifter       ← logical right shifter (SRL)
├── HiLo          ← Hi/Lo registers that store division quotient/remainder
└── MUX           ← output selector
```

### Standalone modules

| File | Module | Description |
|------|--------|-------------|
| `fullAdder.v` | `fullAdder` | 1-bit full adder |
| `four_to_one_mux.v` | `four_to_one_mux` | 1-bit 4-to-1 multiplexer |
| `bit_ALU.v` | `bit_ALU` | 1-bit ALU slice (AND / OR / ADD+SUB) |
| `ALU_Adder.v` | `ALU_Adder` | Standalone 32-bit ripple-carry adder |
| `ALU.v` | `ALU` | 32-bit ALU (AND / OR / ADD / SUB / SLT) |
| `TotalALU.v` | `TotalALU` | Top-level: ALU + Divider + Shifter + HiLo + MUX |
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
| SRL  | 2  | `000010` | Logical right shift |
| DIVU | 27 | `011011` | Unsigned division (multi-cycle) |
| MFHI | 16 | `010000` | Move from Hi register (division remainder) |
| MFLO | 18 | `010010` | Move from Lo register (division quotient) |

---

## Running the Testbench

1. Prepare **`input.txt`** — one test vector per line in the format:

   ```
   <Signal>  <InputA>  <InputB>
   ```

2. Prepare **`ans.txt`** — one expected result per line (two lines per DIVU test: Hi then Lo).

3. Simulate with any Verilog simulator (e.g., ModelSim, Icarus Verilog):

   ```bash
   # Icarus Verilog example
   iverilog -o sim tb_ALU.v TotalALU.v ALU.v ALU_Adder.v bit_ALU.v fullAdder.v four_to_one_mux.v
   vvp sim
   ```

4. The testbench prints `Correct` or `Wrong Answer` for each test case along with the expected and actual values.

---

## Changelog

### [2026-05-04] — Initial commit (`5e64e8b`)

- Added all core RTL source files:
  - `fullAdder.v` — 1-bit full adder primitive
  - `four_to_one_mux.v` — 1-bit 4-to-1 mux primitive
  - `bit_ALU.v` — 1-bit ALU slice built from the above primitives
  - `ALU_Adder.v` — standalone 32-bit ripple-carry adder
  - `ALU.v` — 32-bit ALU supporting AND, OR, ADD, SUB, SLT
  - `TotalALU.v` — top-level integration (ALU + Divider + Shifter + HiLo + MUX + ALUControl) adding SRL and DIVU support
  - `tb_ALU.v` — file-driven testbench with auto-check against answer file
