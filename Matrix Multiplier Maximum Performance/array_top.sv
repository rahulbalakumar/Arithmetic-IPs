`include "pe.sv"
module array_top #(
    parameter int N = 3
    ) (
        input logic [7:0] a_in [0:N-1],
        input logic [7:0] w_in [0:N-1],
        input logic clk,
        input logic rstn,
        output logic [15:0] acc [0:N-1][0:N-1]
);
    logic [7:0] a_wire [0:N-1][0:N-1];
    logic [7:0] w_wire [0:N-1][0:N-1];
    logic [7:0] a_out_dummy [0:N-1][0:N-1];
    logic [7:0] w_out_dummy [0:N-1][0:N-1];
    genvar i, j;
    generate 
        for (i = 0; i < N; i = i + 1) begin : row_gen
            for (j = 0; j < N; j = j + 1) begin : col_gen
                    if (j == 0) begin : a_external
                        assign a_wire[i][j] = a_in[i];
                    end 
                    if (i == 0) begin : w_external
                        assign w_wire[i][j] = w_in[j];
                    end
              		if (j == N-1) begin : a_edge
                
                    end else begin : a_not_edge
                        assign a_wire[i][j+1] = a_out_dummy[i][j];
                    end
              		if (i == N-1) begin : w_edge

                    end else begin : w_not_edge
                        assign w_wire[i+1][j] = w_out_dummy[i][j];
                    end
                    pe pe_inst(.a_in(a_wire[i][j]),
                               .w_in(w_wire[i][j]),
                               .rstn(rstn),
                               .clk(clk),
                               .a_out(a_out_dummy[i][j]),
                               .w_out(w_out_dummy[i][j]),
                               .acc(acc[i][j]));
                end
        end
    endgenerate
endmodule