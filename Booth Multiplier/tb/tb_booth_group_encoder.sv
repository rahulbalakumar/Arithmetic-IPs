`timescale 1ns / 1ps
module tb_booth_group_encoder;
    localparam WIDTH = 8;
    localparam GROUPS = WIDTH/2;

    logic [WIDTH-1:0] bits;
    logic [1:0] sel [0:GROUPS-1];
    logic negate [0:GROUPS-1];

    booth_group_encoder dut (.bits(bits),
                             .sel(sel),
                             .negate(negate));

    initial begin
      	$dumpfile("dump.vcd");$dumpvars(0,dut);

        bits = 8'b1011_0101;
        #5;
      assert (sel[0] == 2'b01 && negate[0] == 0)
        else $error("First Group is wrong");
        assert (sel[1] == 2'b01 && negate[1] == 0)
        else $error("Second Group is wrong");
        assert (sel[2] == 2'b01 && negate[2] == 1)
        else $error("Third Group is wrong");
        assert (sel[3] == 2'b01 && negate[3] == 1)
        else $error("Fourth Group is wrong");

        $display("Simulation Done");
        $finish();

    end
endmodule