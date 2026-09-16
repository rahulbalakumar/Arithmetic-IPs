# Parametrized Systolic Array Matrix Multiplier (NxN)

Parametrized NxN systolic array for hardware matrix multiplication, built and verified module-by-module in SystemVerilog.

## Overview

Systolic Array architecture is used in this design, where data flows through a grid of small multiply and accumulate units with activations streaming rightwared and weights streaming downward with each processing element accumulating one output element of the result matrix. This avoids the broadcast bottleneck entirely, keeps interconnect local (which maps well onto FPGA fabric), and lets a small physical array sustain high throughput once its pipeline is full.

## Architecture

**Dataflow:** Matrix A's rows enter from the left edge, matrix B's columns enter from the top edge. Each processing element sits at grid position (i, j) and computes output element C[i][j].

**Timing:** Since each value must propogate through intermediate processing elements, inputs must be skewed. This is done by delaying row i by i cycles and column j by j cycles. This way every processing element receives its correct operand pair at the correct moment. Total latency for an NxN array is `3N - 2` cycles.

### Module hierarchy

| Module | Role |
|---|---|
| `pe.sv` | Single processing element: one MAC (multiply-accumulate) per cycle, plus one-cycle pass-through registers forwarding activation and weight values to neighboring PEs. |
| `array_top.sv` | Parametrized N×N grid of `pe` instances. Handles PE-to-PE interconnect and the boundary conditions for edge PEs (which read from external inputs instead of a neighbor). |
| `skew_top.sv` | Automatic input staggering. For each row/column index k, builds a k-stage shift-register chain so external data arrives at the array with the correct per-row/per-column delay. |
| `systolic_matmul.sv` | Top-level module wiring `skew_top`'s outputs into `array_top`'s inputs - the complete, self-contained multiplier. |

### Key parameters

- `N` (parameter, default varies by testbench): array dimension, supports any N×N square matrix pair.
- Data width: 8-bit inputs (`a_in`/`w_in`), 16-bit accumulators (`acc`) to avoid overflow across accumulated products.

## Design decisions

- **Accumulator width (16-bit) vs. data width (8-bit):** sized to prevent truncation across N accumulated 16-bit products.
- **Interconnect uses `assign`, not registers:** the wiring between wire arrays and PE ports is purely combinational. All actual timing/delay behavior lives inside `pe` (pass-through registers) and `skew_top` (delay chains) by design, so the interconnect layer never introduces unintended extra cycles of latency.
- **Skew chains are variable-length:** row/column k needs exactly k cycles of delay, built as a k-stage register chain rather than a fixed number of stages, so the same module scales to any N.

## Verification approach

Every module was built and verified in isolation before integration, from the bottom up:

1. **`pe`** — verified against hand-computed MAC sequences via waveform inspection.
2. **Fixed 2×2 `array`** — verified with manually-timed testbench stimulus against a hand-computed 2×2 matrix product.
3. **Fixed 2×2 `skew`** — verified that row/column 1 outputs show exactly one cycle of delay relative to row/column 0.
4. **Fixed `systolic_top`** verified that raw, unstaggered input values produce the correct matrix product automatically, with no manual timing needed in the testbench.
5. **Parametrized `array_top`** — verified against the known-good fixed 2×2 reference at N=2, then debugged and re-verified for larger N.
6. **Parametrized `skew_top`** — verified the k-cycle-delay staircase property at N=3 (row/col k delayed by exactly k cycles).
7. **Parametrized `systolic_matmul`** — verified end-to-end at N=3, including an identity-matrix sanity check (A × I = A).


## Parametrized Modules' Structure

```
pe.sv                  - single processing element
array_top.sv           - parametrized N×N PE grid
skew_top.sv            - parametrized input skew/delay logic
systolic_matmul.sv     - top-level module (skew_top + array_top)
tb_pe.sv               - PE testbench
tb_array_top.sv        - array testbench
tb_skew_top.sv         - skew testbench
tb_systolic_matmul.sv  - full end-to-end testbench
```

## Status

Core architecture complete and verified at N=2 and N=3. Not yet synthesized or deployed to hardware.

## Future work

- **FPGA deployment** — build a board-level wrapper (hardcoded test stimulus, push-button reset, LED pass/fail indicator) for the DE0-Nano, assign pins, and confirm hardware results match simulation.
- **Timing/performance validation** — run synthesis and timing analysis to determine actual achievable clock frequency and embedded multiplier usage, and compare cycle-count throughput against a naive sequential MAC baseline.
- **Tiling** — support matrices larger than N×N by streaming tile pairs through the array and accumulating partial sums across passes.
- **Memory-fed operands** — replace testbench-driven inputs with BRAM storage and address generators, so matrices are read from memory rather than driven externally.
- **Output readout strategy** — decide between parallel and serialized result readout for integration into a larger system.