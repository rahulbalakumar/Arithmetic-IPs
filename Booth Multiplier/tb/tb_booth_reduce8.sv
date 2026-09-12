`timescale 1ns / 1ps

class booth_reduce8_random #(parameter WIDTH = 8);
    rand logic [WIDTH-1:0] rows [0:7];
endclass

module tb_booth_reduce8;
    localparam WIDTH = 8;
    localparam TESTS = 10;

    logic [WIDTH-1:0] rows [0:7];
    logic [WIDTH-1:0] final_row_1;
    logic [WIDTH-1:0] final_row_2;

    int errors;
    logic [WIDTH-1:0] sum;

    booth_reduce8 #(.WIDTH(WIDTH)) dut (
        .rows(rows),
        .final_row_1(final_row_1),
        .final_row_2(final_row_2)
    );

    booth_reduce8_random #(.WIDTH(WIDTH)) stim;

    initial begin
        stim = new();
        errors = 0;
        
        
        for (int t = 0; t < TESTS; t++) begin
            void'(stim.randomize());
            rows = stim.rows;
            #10;

            for (int j = 0; j < 8; j++) begin
                sum = sum + rows[j];
            end

            if(sum != (final_row_1 + final_row_2)) begin
                errors++;
                $display("Error");
            end
            sum = 0;
        end
        if (errors == 0) $display("No errors");
        else $display("%0d/%0d failed", errors, TESTS);
        $finish();

    end



endmodule


