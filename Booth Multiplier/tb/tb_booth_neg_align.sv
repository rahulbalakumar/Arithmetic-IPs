module tb_booth_neg_align;
    localparam WIDTH = 8;

    logic negate;
    logic [2*WIDTH-1:0] neg_bits1;
    logic [2*WIDTH-1:0] neg_bits2;

    booth_neg_align #(.WIDTH(WIDTH),
                      .IDX(0)) dut1 (.negate(negate),
                                     .neg_bits(neg_bits1));
    
    booth_neg_align #(.WIDTH(WIDTH),
                      .IDX(3)) dut2 (.negate(negate),
                                     .neg_bits(neg_bits2));

    initial begin
        negate = 1;
        #5;
        assert (neg_bits1 == 16'b0000_0000_0000_0001)
        else $error("DUT1 output is wrong.");

        assert (neg_bits2 == 16'b0000_0000_0100_0000)
        else $error("DUT2 output is wrong.");

        $finish();

    end

endmodule