module multiplier #(
    parameter int WIDTH = 128
)(
    input logic clk,
    input logic rstn,
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    output logic [(2*WIDTH)-1:0] product
);


    localparam int INPUT_ROWS = WIDTH / 2;
    localparam int MATRIX_WIDTH = 2 * WIDTH;

    logic [INPUT_ROWS-1:0][MATRIX_WIDTH-1:0] partial_product_matrix;

    booth_generator #(
        .DATA_WIDTH(WIDTH)
    ) u_booth_generator (
        .a(A),
        .b(B),
        .partial_product_matrix(partial_product_matrix)
    );

    logic [MATRIX_WIDTH-1:0] wallace_sum;
    logic [MATRIX_WIDTH-1:0] wallace_carry;

    wallace_tree #(
        .INPUT_ROWS(INPUT_ROWS),
        .WIDTH(MATRIX_WIDTH)
    )u_wallace_tree(
        .partial_product_matrix(partial_product_matrix),
        .sum_out(wallace_sum),
        .carry_out(wallace_carry)
    );

    logic [MATRIX_WIDTH-1:0] final_sum;

    kogge_stone_adder #(
        .WIDTH(MATRIX_WIDTH)
    ) u_kogge_stone_adder (
        .a(wallace_sum),
        .b({wallace_carry[MATRIX_WIDTH-2:0], 1'b0}),
        .final_product(final_sum)
    );

    assign product = final_sum;
endmodule
