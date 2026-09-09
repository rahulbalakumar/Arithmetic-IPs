`timescale 1ns / 1ps
module tb_booth_pp_align;
    localparam WIDTH = 8;
    
    logic [WIDTH:0] pp;
    logic [2*WIDTH-1:0] row1;
    logic [2*WIDTH-1:0] row2;

    booth_pp_align #(.WIDTH(WIDTH),
                     .IDX(0)) dut1 (
                        .pp(pp),
                        .row(row1)
                     );

    booth_pp_align #(.WIDTH(WIDTH),
                     .IDX(3)) dut2 (
                        .pp(pp),
                        .row(row2)
                     );

    initial begin
        pp = 9'b1_0110_1101;
        #1;
        assert (row1 == 16'b1111_1111_0110_1101)
        else $error("DUT1 row is wrong");
        assert (row2 == 16'b1_1_0110_1101_000000)
        else $error("DUT2 row is wrong");
        $finish();
    end
endmodule