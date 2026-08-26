module skew_top #(
    parameter int N = 3
)(  
    input logic [7:0] row_in [0:N-1],
    input logic [7:0] col_in [0:N-1],
    input logic clk,
    input logic rstn,
    output logic [7:0] row_out [0:N-1],
    output logic [7:0] col_out [0:N-1]
);

    genvar k, m;
    generate 
        for (k = 0; k < N; k = k + 1) begin : row_delay
            if (k == 0) begin : no_delay
                assign row_out[k] = row_in[k];
            end else begin : delayed
                logic [7:0] row_chain [0:k-1];
                for (m = 0; m < k; m = m + 1) begin : stage
                    if (m == 0) begin : first_stage
                        always_ff @(posedge clk or negedge rstn) begin
                            if (!rstn) begin
                                row_chain[m] <= '0;
                            end else begin
                                row_chain[m] <= row_in[k];
                            end
                        end
                    end else begin : later_stage
                        always_ff @(posedge clk or negedge rstn) begin
                            if (!rstn) begin
                                row_chain[m] <= '0;
                            end else begin
                                row_chain[m] <= row_chain[m-1];
                            end
                        end
                    end
                end

                assign row_out[k] = row_chain[k-1]; 
            end
        end 
    endgenerate
    
    generate 
        for (k = 0; k < N; k = k + 1) begin : col_delay
            if (k == 0) begin : no_delay
                assign col_out[k] = col_in[k];
            end else begin : delayed
                logic [7:0] col_chain [0:k-1];
                for (m = 0; m < k; m = m + 1) begin : stage
                    if (m == 0) begin : first_stage
                        always_ff @(posedge clk or negedge rstn) begin
                            if (!rstn) begin
                                col_chain[m] <= '0;
                            end else begin
                                col_chain[m] <= col_in[k];
                            end
                        end
                    end else begin : later_stage
                        always_ff @(posedge clk or negedge rstn) begin
                            if (!rstn) begin
                                col_chain[m] <= '0;
                            end else begin
                                col_chain[m] <= col_chain[m-1];
                            end
                        end
                    end
                end
                assign col_out[k] = col_chain[k-1];
            end
        end
    endgenerate
endmodule