    `timescale 1ns/1ps
    module tb_array_top;
        localparam N = 2;
        logic [7:0] a_in [0:N-1];
        logic [7:0] w_in [0:N-1];
        logic clk;
        logic rstn;
        logic [15:0] acc [0:N-1][0:N-1];

        array_top #(.N(N)) dut (
            .a_in(a_in),
            .w_in(w_in),
            .clk(clk),
            .rstn(rstn),
            .acc(acc)
        );
        initial begin // Clock Driver
            clk = 0;
            forever #5 clk = ~clk;
        end

        /**

        [1,2]  [4,3]    [8,5]
        [3,4]  [2,1]    [20,13]

        **/


        initial begin
            $dumpfile("dump.vcd");$dumpvars(0, dut);
            rstn = 0;
            @(negedge clk);
            rstn = 1;
            a_in[0] = 8'd1;
            w_in[0] = 8'd4;
            a_in[1] = 8'd0;
            w_in[1] = 8'd0;
            @(negedge clk);
            a_in[0] = 8'd2;
            w_in[0] = 8'd2;
            a_in[1] = 8'd3;
            w_in[1] = 8'd3;
            @(negedge clk);
            a_in[0] = 8'd0;
            w_in[0] = 8'd0;
            a_in[1] = 8'd4;
            w_in[1] = 8'd1;
            @(negedge clk);
            a_in[0] = 8'd0;
            w_in[0] = 8'd0;
            a_in[1] = 8'd0;
            w_in[1] = 8'd0;
            @(negedge clk);
            @(negedge clk);
            rstn = 0;
            $finish();
        end
    endmodule

