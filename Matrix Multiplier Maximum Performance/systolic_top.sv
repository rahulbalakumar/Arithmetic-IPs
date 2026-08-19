module systolic_top (
    input logic [7:0] row0_in,
    input logic [7:0] col0_in,
    input logic [7:0] row1_in,
    input logic [7:0] col1_in,
    input logic clk,
    input logic rstn,
    output logic [15:0] acc1,
    output logic [15:0] acc2,
    output logic [15:0] acc3,
    output logic [15:0] acc4,
    output logic [7:0] a_out_1,
    output logic [7:0] w_out_1,
    output logic [7:0] a_out_2,
    output logic [7:0] w_out_2
);
    logic [7:0] wire1, wire2, wire3, wire4;
    skew skew1 (.row0_in(row0_in),
                .row1_in(row1_in),
                .col0_in(col0_in),
                .col1_in(col1_in),
                .clk(clk),
                .rstn(rstn),
                .row0_out(wire1),
                .row1_out(wire2),
                .col0_out(wire3),
                .col1_out(wire4));
    

    array array1 (.a_in_1(wire1),
                  .a_in_2(wire2),
                  .w_in_1(wire3),
                  .w_in_2(wire4),
                  .clk(clk),
                  .rstn(rstn),
                  .acc1(acc1),
                  .acc2(acc2),
                  .acc3(acc3),
                  .acc4(acc4),
                  .a_out_1(a_out_1),
                  .a_out_2(a_out_2),
                  .w_out_1(w_out_1),
                  .w_out_2(w_out_2));

endmodule