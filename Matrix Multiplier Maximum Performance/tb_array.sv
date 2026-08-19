`timescale 1ns / 1ps
module tb_array;
    logic [7:0] a_in_1, a_in_2, w_in_1, w_in_2;
    logic [15:0] acc1, acc2, acc3, acc4;
    logic [7:0] a_out_1, a_out_2, w_out_1, w_out_2;
    logic clk, rstn;

    array dut(.*);

    initial begin
        clk = 0;
      	rstn = 0;
        forever #5 clk = ~clk;
    end

    /**

    [1,2]  [4,3]    [8,5]
    [3,4]  [2,1]    [20,13]

    **/
    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        rstn = 0;
      	@(negedge clk);
        
        @(negedge clk);
      	rstn = 1;	
        a_in_1 = 8'd1;
        w_in_1 = 8'd4;
      	a_in_2 = 8'd0;
      	w_in_2 = 8'd0;
        @(negedge clk);
        a_in_1 = 8'd2;
        w_in_1 = 8'd2;
        a_in_2 = 8'd3;
        w_in_2 = 8'd3;
        @(negedge clk);
 		a_in_1 = 8'd0;
      	w_in_1 = 8'd0;
        a_in_2 = 8'd4;
        w_in_2 = 8'd1;
        @(negedge clk);
      	a_in_1 = 8'd0;
      	w_in_1 = 8'd0;
        a_in_2 = 8'd0;
        w_in_2 = 8'd0;
        @(negedge clk);
        @(negedge clk);
        rstn = 0;


        $finish();

    end
endmodule