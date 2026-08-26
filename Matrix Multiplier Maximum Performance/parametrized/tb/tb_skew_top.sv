`timescale 1ns/1ps
module tb_skew_top;
    localparam int N = 3;
    logic [7:0] row_in [0:N-1];
    logic [7:0] col_in [0:N-1];
    logic clk;
    logic rstn;
    logic [7:0] row_out [0:N-1];
    logic [7:0] col_out [0:N-1];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    skew_top #(.N(N)) dut (
        .row_in(row_in),
        .col_in(col_in),
        .clk(clk),
        .rstn(rstn),
        .row_out(row_out),
        .col_out(col_out)
    );
    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        rstn = 0;
        @(negedge clk);
        rstn = 1;
        row_in[0] = 8'd10;
        row_in[1] = 8'd20;
        row_in[2] = 8'd30;
        col_in[0] = 8'd40;
        col_in[1] = 8'd50;
        col_in[2] = 8'd60;
        @(negedge clk);
        @(negedge clk);
        $finish();
    end
endmodule