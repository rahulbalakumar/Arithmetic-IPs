# Arithmetic IPs

Parametrized arithmetic IP cores in SystemVerilog, built for the Digital System Design individual project.

No need for gate level optimization.

## Project Brief

| Part | Requirement |
|---|---|
| (A) | Configurable 8/16/32/64/128-bit integer multiplier |
| (B) | Configurable 8/16/32/64/128-bit integer divider |
| (A), (B) | Investigate hardware structures and choose one for (i) performance (latency) and (ii) logic resources (cost) |
| (C) | Configurable 3x3, 5x5, 7x7 matrix multiplication for performance |

## IPs

| Folder | IP | Structure | Status |
|---|---|---|---|
| `Booth Multiplier/` | Multiplier, performance | Radix-4 Booth + recursive Wallace (3:2) tree | Verified at WIDTH = 8 |
| `Restoring Divider/` | Divider, cost | Restoring division, one subtractor reused per bit; latency WIDTH+1 | Verified at WIDTH = 8 and 128 |
| `SRT Divider/` | Divider, performance | Normalised radix-2 SRT, digits {-1, 0, +1}; latency s+4 | Verified at WIDTH = 8 and 128 |
| `Matrix Multiplier Maximum Performance/` | Matrix multiply | Parametrized NxN systolic array | Verified at N = 2 and 3 |
| `archive/` | Earlier versions | Kept for reference | Superseded |

Each folder has its own README with the design, interface and verification results.