module array (
    input logic [7:0] a_in_1,
    input logic [7:0] a_in_2,
    input logic [7:0] w_in_1,
    input logic [7:0] w_in_2,
    output logic [15:0] acc1,
    output logic [15:0] acc2,
    output logic [15:0] acc3, 
    output logic [15:0] acc4,
    output logic [7:0] a_out_1,
    output logic [7:0] a_out_2,
    output logic [7:0] w_out_1,
    output logic [7:0] w_out_2,
    input logic clk,
    input logic rstn
);
    logic [7:0] wire00_01;
    logic [7:0] wire00_10;
    logic [7:0] wire01_11;
    logic [7:0] wire10_11;
    pe pe00 (.a_in(a_in_1),
             .w_in(w_in_1),
             .rstn(rstn),
             .clk(clk),
             .a_out(wire00_01),
             .w_out(wire00_10),
             .acc(acc1));
    pe pe01 (.a_in(wire00_01),
             .w_in(w_in_2),
             .rstn(rstn),
             .clk(clk),
             .a_out(a_out_1),
             .w_out(wire01_11),
             .acc(acc2));
    pe pe10 (.a_in(a_in_2),
             .w_in(wire00_10),
             .rstn(rstn),
             .clk(clk),
             .a_out(wire10_11),
             .w_out(w_out_1),
             .acc(acc3));
    pe pe11 (.a_in(wire10_11),
             .w_in(wire01_11),
             .rstn(rstn),
             .clk(clk),
             .a_out(a_out_2),
             .w_out(w_out_2),
             .acc(acc4));

endmodule