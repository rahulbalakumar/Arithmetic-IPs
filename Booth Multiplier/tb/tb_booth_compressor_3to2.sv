`timescale 1ns / 1ps

class booth_compressor_random #(parameter WIDTH = 8);
    rand logic [WIDTH-1:0] A;
    rand logic [WIDTH-1:0] B;
    rand logic [WIDTH-1:0] C;
endclass

module tb_booth_compressor_3to2;
    localparam WIDTH = 8;
    localparam TESTS = 10;

    logic [WIDTH-1:0] A,B,C,sum,carry;
    int errors;

    booth_compressor #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
        .C(C),
        .sum(sum),
        .carry(carry)
    );

    booth_compressor_random #(.WIDTH(WIDTH)) stim;


    initial begin
        stim = new();
        errors = 0;

        for (int t = 0; t < TESTS; t++) begin
            void'(stim.randomize());
            A = stim.A;
            B = stim.B;
            C = stim.C;
            #1;

            if (A+B+C != (carry+sum)) begin
                errors++;
                $display("MISMATCH: A=%0d B=%0d C=%0d sum=%0d carry=%0d", A, B, C, sum, carry);
            end
        end 
        if (errors == 0) $display("All tests cases passed!");
        else $display("%0d/%0d failed.", errors, TESTS);
        $finish();
    end
endmodule