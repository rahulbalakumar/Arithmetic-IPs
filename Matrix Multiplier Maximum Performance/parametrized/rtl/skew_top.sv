// Input skew: row k and column k are delayed by k cycles, so that
// A[i][t] and B[t][j] meet at PE(i,j) in the same cycle (t + i + j).
module skew_top #(
    parameter int N      = 3,
    parameter int DATA_W = 8
) (
    input  logic                     clk,
    input  logic                     rstn,
    input  logic [N-1:0][DATA_W-1:0] row_in,
    input  logic [N-1:0][DATA_W-1:0] col_in,
    output logic [N-1:0][DATA_W-1:0] row_out,
    output logic [N-1:0][DATA_W-1:0] col_out
);
    genvar k;
    generate
        for (k = 0; k < N; k++) begin : lane
            if (k == 0) begin : no_delay
                assign row_out[k] = row_in[k];
                assign col_out[k] = col_in[k];
            end else begin : delayed
                // k-stage shift registers; index 0 is the newest value
                logic [DATA_W-1:0] row_chain [0:k-1];
                logic [DATA_W-1:0] col_chain [0:k-1];
                always_ff @(posedge clk or negedge rstn) begin
                    if (!rstn) begin
                        for (int m = 0; m < k; m++) begin
                            row_chain[m] <= '0;
                            col_chain[m] <= '0;
                        end
                    end else begin
                        row_chain[0] <= row_in[k];
                        col_chain[0] <= col_in[k];
                        for (int m = 1; m < k; m++) begin
                            row_chain[m] <= row_chain[m-1];
                            col_chain[m] <= col_chain[m-1];
                        end
                    end
                end
                assign row_out[k] = row_chain[k-1];
                assign col_out[k] = col_chain[k-1];
            end
        end
    endgenerate
endmodule
