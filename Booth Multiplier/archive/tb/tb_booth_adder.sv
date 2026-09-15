`timescale 1ns / 1ps
module tb_booth_adder;
    localparam WIDTH = 8;
    localparam GROUPS = WIDTH / 2;

    logic [2*WIDTH-1:0] addends [0:GROUPS*2-1];
    logic [2*WIDTH-1:0] sum;

    booth_adder dut (.addends(addends),
                     .sum(sum));

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        addends = '{16'd500,-16'sd200,16'd1000,-16'sd1500,16'd300,-16'sd50,16'd25,-16'sd75};
        #5;
        assert (sum == 16'd0)
        else $error("Sum is wrong");
        #5;
        addends = '{16'd32767,-16'sd32768,16'd0,16'd0,16'd0,16'd0,16'd1,-16'sd1};
        assert (sum == 16'd0)
        else $error("Sum is wrong");
        $finish();
    end
endmodule