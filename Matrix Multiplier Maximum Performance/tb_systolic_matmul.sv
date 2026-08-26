`timescale 1ns/1ps
module tb_systolic_matmul;
    localparam N = 3;
    logic [7:0] row_in [0:N-1];
    logic [7:0] col_in [0:N-1];
    logic clk;
    logic rstn;
    logic [15:0] acc [0:N-1][0:N-1];

    systolic_matmul #(.N(N)) dut (
        .row_in(row_in),
        .col_in(col_in),
        .clk(clk),
        .rstn(rstn),
        .acc(acc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    /**
    A = [1 2 3]      B = [1 0 0]
        [4 5 6]          [0 1 0]   Output is also same as A
        [7 8 9]          [0 0 1]


    **/
    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        rstn = 0;
        @(negedge clk);
        rstn = 1;
        row_in[0] = 8'd1;
        row_in[1] = 8'd4;
        row_in[2] = 8'd7;
        col_in[0] = 8'd1;
        col_in[1] = 8'd0;
        col_in[2] = 8'd0;
        @(negedge clk);
        row_in[0] = 8'd2;
        row_in[1] = 8'd5;
        row_in[2] = 8'd8;
        col_in[0] = 8'd0;
        col_in[1] = 8'd1;
        col_in[2] = 8'd0;
        @(negedge clk);
        row_in[0] = 8'd3;
        row_in[1] = 8'd6;
        row_in[2] = 8'd9;
        col_in[0] = 8'd0;
        col_in[1] = 8'd0;
        col_in[2] = 8'd1;
        @(negedge clk);
        row_in[0] = 8'd0;
        row_in[1] = 8'd0;
        row_in[2] = 8'd0;
        col_in[0] = 8'd0;
        col_in[1] = 8'd0;
        col_in[2] = 8'd0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        rstn = 1;
        $finish();
    end
endmodule