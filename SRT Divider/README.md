# Radix-2 SRT Integer Divider (Max Performance)

Parametrized unsigned divider (`WIDTH` = 8/16/32/64/128) using normalised radix-2 SRT division. This is the **performance (latency)** design for part (B). It has the same ports as the restoring divider.

## How It Is Faster

- **Normalisation:** the divisor is shifted left by its leading-zero count `s`, so only `s+1` iterations are needed instead of `WIDTH`.
- **Digits {-1, 0, +1}:** each digit is chosen from only the **top 3 bits** of the partial remainder, so the selection logic is the same size at every width.

## Interface

| Item | Behaviour |
|---|---|
| Inputs | Valid only in the cycle `start` is high |
| Latency | `s+4` cycles from `start` to `done` (`s` = divisor leading zeros); 2 for divide by zero |
| Results | Held from `done` until the next accepted `start` |
| Divide by zero | `quotient` = all ones, `remainder` = `dividend`, `div_by_zero` = 1 |
| Reset | Synchronous, active-high |

## Modules

```
srt_top            top level (wiring only)
 ├─ srt_ctrl       FSM (IDLE -> NORM -> RUN x (s+1) -> FIX -> DONE)
 └─ srt_datapath   registers, SRT step, final quotient/remainder fix-up
     ├─ lzc        leading-zero counter (shift amount + zero flag)
     └─ srt_qsel   digit selection (3 bits in, +1 / 0 / -1 out)
srt_pkg            LOAD / NORM / RUN / FIX / HOLD commands
```

## Latency vs Restoring (cycles)

| WIDTH | Restoring | SRT best / worst | SRT average (random divisor) |
|---|---|---|---|
| 8 | 9 | 4 / 11 | 5 |
| 32 | 33 | 4 / 35 | 5 |
| 128 | 129 | 4 / 131 | 5 |

## Verification

| Testbench | Result |
|---|---|
| `tb_lzc` (directed, one-hot, exhaustive ≤ 16 bits, random) | PASS at WIDTH = 8 and 128 |
| `tb_srt_top` (values + latency on every division) | PASS: WIDTH = 8 (10,081 tests), WIDTH = 128 (2,081 tests) |

## Next Steps

- Synthesis (LUTs, Fmax) for comparison with the restoring divider.
- Carry-save partial remainder, if synthesis shows the RUN adder is the critical path.