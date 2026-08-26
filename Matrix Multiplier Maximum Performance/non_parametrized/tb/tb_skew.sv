`timescale 1ns / 1ps
module tb_skew;

    logic [7:0] row0_in, row1_in, col0_in, col1_in;
    logic clk, rstn;
    logic [7:0] row0_out, row1_out, col0_out, col1_out;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    skew dut (.*);

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        rstn = 0;
        @(negedge clk);
        rstn = 1;
        row0_in = 8'd1;
        col0_in = 8'd4;
        row1_in = 8'd3;
        col1_in = 8'd3;
        @(negedge clk);
        row0_in = 8'd2;
        col0_in = 8'd2;
        row1_in = 8'd4;
        col1_in = 8'd1;
        @(negedge clk);
        rstn = 0;
        @(negedge clk);

        $finish();
    end
endmodule