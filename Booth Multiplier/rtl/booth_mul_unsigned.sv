// booth_mul_unsigned : unsigned WIDTH x WIDTH multiplier built on the signed
// radix-4 Booth / Wallace-tree core.
//   Both operands are zero-extended by 2 bits, so the signed core sees two
//   non-negative numbers and its signed product equals the unsigned product.
//   2 bits (not 1) keep the core's width even, as radix-4 Booth groups bits in pairs.
//   Cost: one extra partial-product row compared with the signed WIDTH-bit core.
//   Purely combinational: product is valid after the propagation delay.
module booth_mul_unsigned #(
    parameter int WIDTH = 8 // Operand width 8/16/32/64/128
) (
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,
    output logic [2*WIDTH-1:0] product
);
    localparam int CORE_W = WIDTH + 2;

    /* verilator lint_off UNUSEDSIGNAL */ // top 4 bits are always 0 by design
    logic [2*CORE_W-1:0] core_product;
    /* verilator lint_on UNUSEDSIGNAL */

    booth_multiplier_tree_recursive #(
        .WIDTH(CORE_W)
    ) u_core (
        .A({2'b00, A}),
        .B({2'b00, B}),
        .product(core_product)
    );

    // The full unsigned product fits in 2*WIDTH bits; the top 4 bits of the core output are always 0
    assign product = core_product[2*WIDTH-1:0];
endmodule
