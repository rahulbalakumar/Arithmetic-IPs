module systolic_matmul #(
    parameter int N = 2
)(
    input logic [7:0] row_in [0:N-1],
    input logic [7:0] col_in [0:N-1],
    input logic clk,
    input logic rstn,
    output logic [15:0] acc [0:N-1][0:N-1]
);
    logic [7:0] a_wire [0:N-1];
    logic [7:0] w_wire [0:N-1];

    skew_top #(.N(N)) skew_inst (
        .row_in(row_in),
        .col_in(col_in),
        .clk(clk),
        .rstn(rstn),
        .row_out(a_wire),
        .col_out(w_wire)
    );

    array_top #(.N(N)) array_inst (
        .a_in(a_wire),
        .w_in(w_wire),
        .clk(clk),
        .rstn(rstn),
        .acc(acc)
    );
endmodule