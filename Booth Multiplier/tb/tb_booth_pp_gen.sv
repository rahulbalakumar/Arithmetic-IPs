module tb_booth_pp_gen;
    logic [7:0] M;
    logic [1:0] sel;
    logic negate;
    logic [8:0] pp;

    booth_pp_gen dut (.M(M),
                      .sel(sel),
                      .negate(negate),
                      .pp(pp));

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        sel = 2'b00;
        negate = 0;
        M = 8'b1010_1010;
        #5;
        assert(pp == 9'd0)
        else $error("Sel = 00, Negate = 0 is wrong");
        #5;
        M = 8'b1000_0000;
        #5;
        assert(pp == 9'd0)
        else $error("Sel = 00, Negate = 0 is wrong");
        sel = 2'b01;
        negate = 0;
        M = 8'b1010_1010;
        #5;
        assert(pp == 9'b11010_1010)
        else $error("Sel = 01, Negate = 0 is wrong");
        #5;
        M = 8'b1000_0000;
        #5;
        assert(pp == 9'b1_1000_0000)
        else $error("Sel = 01, Negate = 0 is wrong");
        sel = 2'b01;
        negate = 1;
        M = 8'b1010_1010;
        #5;
        assert(pp == 9'b0_0101_0101)
        else $error("Sel = 01, Negate = 1 is wrong");
        #5;
        M = 8'b1000_0000;
        #5;
        assert(pp == 9'b0_0111_1111)
        else $error("Sel = 01, Negate = 1 is wrong");
        sel = 2'b10;
        negate = 0;
        M = 8'b1010_1010;
        #5;
        assert(pp == 9'b1010_10100)
        else $error("Sel = 10, Negate = 0 is wrong");
        #5;
        M = 8'b1000_0000;
        #5;
        assert(pp == 9'b1000_0000_0)
        else $error("Sel = 10, Negate = 0 is wrong");
        sel = 2'b10;
        negate = 1;
        M = 8'b1010_1010;
        #5;
        assert(pp == 9'b0101_01011)
        else $error("Sel = 10, Negate = 1 is wrong");
        #5;
        M = 8'b1000_0000;
        #5;
        assert(pp == 9'b0111_1111_1)
        else $error("Sel = 10, Negate = 1 is wrong");
        $display("Simulation Success");
        $finish();
    end
endmodule