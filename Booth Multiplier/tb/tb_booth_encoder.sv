module tb_booth_encoder;
    logic [2:0] group_bits;
    logic [1:0] sel;
    logic negate;

    booth_encoder dut (.group_bits(group_bits),
                       .sel(sel),
                       .negate(negate));

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);

        group_bits = 3'b000;
        #1;
        assert(sel == 2'b00)
        else $error("Sel is wrong for 000");
        assert(negate == 0)
        else $error("Negate is wrong for 000");
        group_bits = 3'b001;
        #1;
        assert(sel == 2'b01)
        else $error("Sel is wrong for 001");
        assert(negate == 0)
        else $error("Negate is wrong for 001");
        group_bits = 3'b010;
        #1;
        assert(sel == 2'b01)
        else $error("Sel is wrong for 010");
        assert(negate == 0)
        else $error("Negate is wrong for 010");
        group_bits = 3'b011;
        #1;
        assert(sel == 2'b10)
        else $error("Sel is wrong for 011");
        assert(negate == 0)
        else $error("Negate is wrong for 011");
        group_bits = 3'b100;
        #1;
        assert(sel == 2'b10)
        else $error("Sel is wrong for 100");
        assert(negate == 1)
        else $error("Negate is wrong for 100");
        group_bits = 3'b101;
        #1;
        assert(sel == 2'b01)
        else $error("Sel is wrong for 101");
        assert(negate == 1)
        else $error("Negate is wrong for 101");
        group_bits = 3'b110;
        #1;
        assert(sel == 2'b01)
        else $error("Sel is wrong for 110");
        assert(negate == 1)
        else $error("Negate is wrong for 110");
        group_bits = 3'b111;
        #1;
        assert(sel == 2'b00)
        else $error("Sel is wrong for 111");
        assert(negate == 0)
        else $error("Negate is wrong for 111");
        $display("Simulation Ran Successfully.");
        $finish();
    end

endmodule