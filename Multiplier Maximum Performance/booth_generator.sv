module booth_generator #(
    parameter int DATA_WIDTH = 128,
    parameter int PRODUCT_WIDTH = DATA_WIDTH * 2
)(
    input logic [DATA_WIDTH-1:0] a,
    input logic [DATA_WIDTH-1:0] b,
    output logic [(DATA_WIDTH/2)-1:0][PRODUCT_WIDTH-1:0] partial_product_matrix
); 
    localparam int NUM_ROWS = DATA_WIDTH / 2;

    logic [DATA_WIDTH:0] b_extended; // to assign b[-1] = 0
    assign b_extended = {b, 1'b0};

    // Instantiating individual cells
    genvar i;
    generate
        for (i = 0; i < NUM_ROWS; i++) begin : booth_cell_gen
            logic [2:0] three_bits;
            logic [DATA_WIDTH-1:0] raw_partial_product;
            logic neg;

            assign three_bits = b_extended[2*i +: 3]; // {b[2i+1],b[2i],b[2i-1]}

            booth_encoder_cell u_cell (
                .three_bits(three_bits),
                .A(a),
                .partial_product(raw_partial_product),
                .neg(neg)
            );

            always_comb begin
                partial_product_matrix[i] = '0;
                partial_product_matrix[i][DATA_WIDTH-1:0] = raw_partial_product;
                partial_product_matrix[i] = partial_product_matrix[i] << (2 * i);

                if (neg && ((2*i + DATA_WIDTH) < PRODUCT_WIDTH)) begin
                    partial_product_matrix[i][PRODUCT_WIDTH-1:DATA_WIDTH + (2*i)] = '1;
                end
            end
        end
    endgenerate
endmodule
