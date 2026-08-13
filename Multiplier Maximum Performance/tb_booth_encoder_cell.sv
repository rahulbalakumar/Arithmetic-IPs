module tb_booth_encoder_cell();
    logic [2:0] three_bits;
    logic [127:0] A;
    logic [127:0] partial_product;
    logic neg;

    booth_encoder_cell uut (
        .three_bits(three_bits),
        .A(A),
        .partial_product(partial_product),
        .neg(neg)
    );

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0,uut);
        $display("--- Starting Booth Encoder Cell Test ---");
        A = 128'd100;

        for (int i = 0; i < 8; i++) begin
            three_bits = i[2:0];
            #10;
            $display("Three Bits: %3b | Neg: %b | Partial Prodcut: %0d", three_bits, neg, $signed(partial_product));
        end
        $display("--- Booth Encode Cell Complete --- \n");
    end
endmodule
