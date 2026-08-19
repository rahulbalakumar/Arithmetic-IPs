`timescale 1ns / 1ps
module tb_systolic_top;
    logic [7:0] row0_in, row1_in, col0_in, col1_in;
    logic clk, rstn;
    logic [15:0] acc1, acc2, acc3, acc4;
  logic [7:0] a_out_1, a_out_2, w_out_1, w_out_2;

    systolic_top dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
      $dumpfile("dump.vcd");$dumpvars(0,dut);
        rstn = 0;
        @(negedge clk);
        rstn = 1;
        row0_in = 8'd1;
        row1_in = 8'd3;
        col0_in = 8'd4;
        col1_in = 8'd3;
        @(negedge clk);
        row0_in = 8'd2;
        row1_in = 8'd4;
        col0_in = 8'd2;
        col1_in = 8'd1;
        @(negedge clk);
        row0_in = 8'd0;
        row1_in = 8'd0;
        col0_in = 8'd0;
        col1_in = 8'd0;
        @(negedge clk);
        rstn = 1;
        $finish();

    end
endmodule