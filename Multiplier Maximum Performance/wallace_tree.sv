module wallace_tree #(
    parameter int INPUT_ROWS = 64,
    parameter int WIDTH = 256
)(
    input logic [INPUT_ROWS-1:0][WIDTH-1:0] partial_product_matrix, // 64 rows and 256 columns
    output logic [WIDTH-1:0] sum_out,
    output logic [WIDTH-1:0] carry_out
);

    genvar col;
    generate
        for (col = 0; col < WIDTH; col++) begin: col_gen
            logic [INPUT_ROWS-1:0] col_bits;
            int r;
            always_comb begin
                for (r = 0; r < INPUT_ROWS; r++) begin
                    col_bits[r] = partial_product_matrix[r][col];
                end
            end

            logic [7:0] pop_count;

            always_comb begin
                pop_count = '0;
                for (int r = 0; r < INPUT_ROWS; r++) begin
                    if (col_bits[r]) pop_count = pop_count + 1'b1;
                end
            end


            assign sum_out[col] = pop_count[0];
            assign carry_out[col] = pop_count[1];

        end
    endgenerate
endmodule
            