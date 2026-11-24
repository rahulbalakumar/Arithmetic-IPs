// N x N grid of PEs. Row i of A enters at the left of row i,
// column j of B enters at the top of column j.
module array_top #(
    parameter int N      = 3,
    parameter int DATA_W = 8,
    parameter int ACC_W  = 2*DATA_W + $clog2(N)
) (
    input  logic                              clk,
    input  logic                              rstn,
    input  logic                              clear,
    input  logic [N-1:0][DATA_W-1:0]          a_in,  // a_in[i]: left edge of row i
    input  logic [N-1:0][DATA_W-1:0]          w_in,  // w_in[j]: top edge of column j
    output logic [N-1:0][N-1:0][ACC_W-1:0]    acc    // acc[i][j] = C[i][j]
);
    // a_wire[i][j] / w_wire[i][j]: operands arriving at PE(i,j)
    logic [DATA_W-1:0] a_wire [0:N-1][0:N];
    logic [DATA_W-1:0] w_wire [0:N][0:N-1];

    genvar i, j;
    generate
        for (i = 0; i < N; i++) begin : row_gen
            assign a_wire[i][0] = a_in[i];
        end
        for (j = 0; j < N; j++) begin : col_gen
            assign w_wire[0][j] = w_in[j];
        end
        for (i = 0; i < N; i++) begin : pe_row
            for (j = 0; j < N; j++) begin : pe_col
                pe #(
                    .DATA_W(DATA_W),
                    .ACC_W(ACC_W)
                ) u_pe (
                    .clk(clk),
                    .rstn(rstn),
                    .clear(clear),
                    .a_in(a_wire[i][j]),
                    .w_in(w_wire[i][j]),
                    .a_out(a_wire[i][j+1]), // to the right neighbour (unused at the right edge)
                    .w_out(w_wire[i+1][j]), // to the neighbour below (unused at the bottom edge)
                    .acc(acc[i][j])
                );
            end
        end
    endgenerate
endmodule
