// systolic_matmul : N x N unsigned matrix multiplier, C = A x B (output-stationary systolic array)
//   Feeding      : in the start cycle and the N-1 cycles after it (cycle t = 0 .. N-1),
//                  drive row_in[i] = A[i][t] (column t of A) and col_in[j] = B[t][j] (row t of B)
//   Latency      : done is high 3N-2 cycles after the start cycle
//   Results      : acc[i][j] = C[i][j], valid from the done cycle until the next accepted start
//   Widths       : DATA_W-bit unsigned inputs, ACC_W = 2*DATA_W + clog2(N) bits (cannot overflow)
//   Reset        : asynchronous, active-low rstn
//   start ignored: while busy or done is high
module systolic_matmul #(
    parameter int N      = 3,
    parameter int DATA_W = 8,
    parameter int ACC_W  = 2*DATA_W + $clog2(N)
) (
    input  logic                           clk,
    input  logic                           rstn,
    input  logic                           start,
    input  logic [N-1:0][DATA_W-1:0]       row_in,
    input  logic [N-1:0][DATA_W-1:0]       col_in,
    output logic [N-1:0][N-1:0][ACC_W-1:0] acc,
    output logic                           busy,
    output logic                           done
);
    logic in_valid, clear;
    logic [N-1:0][DATA_W-1:0] row_gated, col_gated; // zeros outside the feeding window
    logic [N-1:0][DATA_W-1:0] a_skewed, w_skewed;

    matmul_ctrl #(
        .N(N)
    ) u_ctrl (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .in_valid(in_valid),
        .clear(clear),
        .busy(busy),
        .done(done)
    );

    assign row_gated = in_valid ? row_in : '0;
    assign col_gated = in_valid ? col_in : '0;

    skew_top #(
        .N(N),
        .DATA_W(DATA_W)
    ) u_skew (
        .clk(clk),
        .rstn(rstn),
        .row_in(row_gated),
        .col_in(col_gated),
        .row_out(a_skewed),
        .col_out(w_skewed)
    );

    array_top #(
        .N(N),
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) u_array (
        .clk(clk),
        .rstn(rstn),
        .clear(clear),
        .a_in(a_skewed),
        .w_in(w_skewed),
        .acc(acc)
    );
endmodule
