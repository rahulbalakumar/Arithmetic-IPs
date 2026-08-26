`timescale 1ns / 1ps
module tb_pe;
    logic [7:0] a_in;
    logic [7:0] w_in;
    logic rstn;
    logic clk;
    logic [7:0] a_out;
    logic [7:0] w_out;
    logic [15:0] acc;

    pe dut (.a_in(a_in),
            .w_in(w_in),
            .rstn(rstn),
            .clk(clk),
            .a_out(a_out),
            .w_out(w_out),
            .acc(acc));
    
    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        clk = 0;
    end

    initial forever #5 clk = ~clk;

    initial begin
        rstn = 0;
        #10;
        rstn = 1;
        a_in = 8'd10;
        w_in = 8'd25;
        #10;
        a_in = 8'd20;
        w_in = 8'd15;
        #10;
        #10;
        $finish();
    end
endmodule


