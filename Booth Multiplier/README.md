# Booth Radix-4 Signed Parametrized Multiplier

A parametrized signed multiplier built from scratch with Radix-4 Booth algorithm, with two interchangeable summing backends: sequential adder and recursive Wallace compressor tree.

## Overview

Given two 'WIDTH'-bit signed two's complement operands, the design produces '2*WIDTH'-bit signed product.
Radix-4 Booth algorithm groups the multiplier into overlapping 3-bit windows, halving the number of partial products.
Each partial product is computer without any multiplication hardware, instead only uses shifts and inversions.

Two designs exist side by side:
**Sequential Adder** ('booth multiplier') : 
Sums up all partial-product rows with a plain chain of addition operators. This design is simple but scales poorly with higher width multiplications.

**Compressor-Tree Design** ('booth_multiplier_tree_recursive') : 
Summation is done via recursive 3:2 carry-save reduction tree, turning linear chain of additions down to 'O(log N)' levels of parallel compression. This can be scaled toward wider operands.

## Module Hierarchy

```
booth_multiplier_tree_recursive.sv          (Top Level)
                |
                +- booth_group_encoder.sv   (Groups into overlapping 3-bit windows)
                +- booth_encoder.sv         (Encodes each group)
                |
                +- booth_pp_gen.sv          (Computes each group's partial product magnitude)
                |
                |
                +- booth_pp_align.sv        (Sign extends and shifts partial product into correct position)
                |
                |
                +- booth_neg_align.sv       (Produces '+1' correction bit for correct inversion)
                |
                |
                +- booth_reduce_tree.sv     
                +- booth_compressor_3to2.sv (Recursively reduces rows + correction bits down to 2 rows)

final product = (tree's 2 output rows) added with simple addition
```

## Things to read before to understand RTL better

'booth_pp_gen' 's negate output is simply one's complement, and the "+1" needed to complete the true negation is added seperately by 'booth_pp_align' as a single bit at the correct position. This desing decision is made to avoid building a small incrementer per partial product.

Compressor's per-stage overflow bit is dropped since the true final product will anyhow be contained withing '2*WIDTH'-bits.

'booth_reduce_tree' is fully recursive. It groups and compresses down to 2 rows, otherwise instantiating a smaller copy of itself and stop exactly at 2 rows.(base case)

## Verification Status

Fully verified end-to-end at 'WIDTH = 8', both sequential and compressor adding methods against hand-derived products covering (+,+), (+,-) and (-,-) cases.

Every individual module has its own self-checking testbench, with hand derived edge cases and randomized testing for compressor based modules.

## Simulation Notes

Cadence Xcelium via edaplayground is extensively used to verify this IP.

## Folder Structure

```
rtl/                            compressor based adder design
rtl/top                         DE0-Nano top level wrapper (still in progress)
tb/                             testbenches for compressor based adder design
archive/rtl                     sequential based adder design
archive/tb                      testbenches for sequential based adder design
```

## Next steps

End-to-end verification of the full IP at 'WIDTH=128'.

Area optimization when it comes to deployment by utilizing a shortened-sign-extension optimization in 'booth_pp_align'.