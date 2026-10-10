# Restoring Integer Divider (Resource-Efficient), Parametrized

A parametrized unsigned integer divider built around a single subtractor that is reused once per quotient bit. This is the **logic-resources (cost)** structure for part (B) of the project.

## Overview

Given two `WIDTH`-bit unsigned operands, the design produces a `WIDTH`-bit quotient and a `WIDTH`-bit remainder (`WIDTH` = 8/16/32/64/128).

The algorithm is binary long division. Each clock cycle it shifts the partial remainder left by one, brings in the next dividend bit, and does a trial subtraction of the divisor. If the result is not negative, the subtraction is kept and a `1` is shifted into the quotient. Otherwise the old value is kept ("restored") and a `0` is shifted in.

Only one `WIDTH+1`-bit subtractor and a few registers are needed, whatever the width. The cost is latency: one cycle per quotient bit.

## Interface Contract

| Item | Behaviour |
|---|---|
| Inputs valid | `dividend` and `divisor` only need to be valid in the cycle `start` is high |
| Results valid | From the `done` cycle until the next accepted `start` |
| Latency | `done` is high `WIDTH+1` cycles after the `start` cycle (fixed) |
| `busy` | High during the `WIDTH` iteration cycles |
| Divide by zero | `quotient` = all ones, `remainder` = `dividend`, `div_by_zero` = 1 (same convention as RISC-V) |
| `div_by_zero` | Valid together with the results; reads 1 after reset until the first division |
| Reset | Synchronous, active-high `rst` |
| `start` | Ignored while `busy` or `done` is high |

## Module Hierarchy

```
div_top.sv                      (Top level, wiring only)
    |
    +- div_ctrl.sv              (FSM: IDLE -> RUN -> DONE, iteration counter, Mealy command output)
    +- div_datapath.sv          (shift register, remainder register, divisor register, one subtractor)

div_pkg.sv                      (LOAD / RUN / HOLD command type shared by ctrl and datapath)
```

## Worked Example: 200 / 7 at WIDTH = 8

Register values at the end of each iteration. The dividend bits shift out of the top of the quotient register while the quotient bits shift in at the bottom.

| Iteration | Quotient register | Remainder register |
|---|---|---|
| load | `11001000` (200) | 0 |
| 1 | `10010000` | 1 |
| 2 | `00100000` | 3 |
| 3 | `01000000` | 6 |
| 4 | `10000001` | 5 |
| 5 | `00000011` | 4 |
| 6 | `00000111` | 1 |
| 7 | `00001110` | 2 |
| 8 | `00011100` (**28**) | **4** |

## Design Decisions

- **Control/datapath split.** `div_ctrl` only decides *when* things happen (LOAD/RUN/HOLD); `div_datapath` only decides *what* happens. This made each half testable on its own.
- **Mealy `LOAD`.** The load command is issued in the same cycle as `start`, so the inputs only have to be held for that one cycle.
- **Divide by zero needs no special logic.** Subtracting 0 never goes negative, so every quotient bit becomes 1 and the dividend bits end up in the remainder register.

## Verification Status

`tb_div_top` is a self-checking testbench that drives the divider through `start`/`done`, exactly as a user would.

- Checks quotient, remainder, `div_by_zero` **and** latency on every division, against a reference model.
- 81 corner-value pairs (0, 1, 2, 3, values around the MSB, all ones) plus random vectors. The random divisor is shifted right by a random amount so that all quotient bits get exercised (with uniform random divisors, the top half of the quotient is almost never 1).
- After `start`, the inputs are changed to garbage to prove the design does not read them later.

| WIDTH | Tests | Result |
|---|---|---|
| 8 | 10,081 | PASS |
| 128 | 2,081 | PASS |

The testbench was checked by deliberately breaking the datapath (`<=` changed to `<` in the trial comparison); it reported the failure immediately.

Unit testbenches: `tb_div_ctrl` (latency + SVA assertions on `done`/`busy`/`LOAD`), `tb_div_datapath` (corner sweep).

## Simulation Notes

Cadence Xcelium via EDA Playground. Compile order: `div_pkg.sv`, `div_ctrl.sv`, `div_datapath.sv`, `div_top.sv`.

## Folder Structure

```
rtl/        div_pkg, div_ctrl, div_datapath, div_top
tb/         tb_div_ctrl, tb_div_datapath, tb_div_top
```

## Next Steps

- Synthesis at each width (LUTs, registers, Fmax) for the cost/performance comparison with the SRT divider.
- Signed division wrapper (absolute values in, sign fix-up out), if required.