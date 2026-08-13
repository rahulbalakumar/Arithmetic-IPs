`timescale 1ns / 1ps

module tb_int_divider_perf;
    localparam WIDTH = 32;
    localparam PIPELINE_STAGES = 4;

    logic clk;
    logic rstn;
    logic en;
    logic [WIDTH-1:0] dividend;
    logic [WIDTH-1:0] divisor;
    logic done;
    logic [WIDTH-1:0] quotient;
    logic [WIDTH-1:0] remainder;

    int_divider_perf #(
        .WIDTH(WIDTH),
        .PIPELINE_STAGES(PIPELINE_STAGES)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .dividend(dividend),
        .divisor(divisor),
        .done(done),
        .quotient(quotient),
        .remainder(remainder)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rstn = 0;
        en = 0;
        dividend = 0;
        divisor = 0;

        #20;
        rstn = 1;

        @(posedge clk);
        #1;

        $display("--- Starting Division ---");
        dividend = 32'd13;
        divisor = 32'd3;
        en = 1;

        @(posedge clk);
        #1;
        en = 0;

        @(posedge done);
        #1;

        $display("Time = %0t ns: %0d / %0d = Quotient: %0d, Remainder: %0d", $time, 13, 3, quotient, remainder);

        #20;
        $display("\n--- Starting Pipelined Test ---");

        @(posedge clk);
        #1;
        dividend = 32'd100;
        divisor = 32'd7;
        en = 1;

        @(posedge clk);
        #1;
        dividend = 32'd1024;
        divisor = 32'd16;

        @(posedge clk);
        #1;
        dividend = 32'd999;
        divisor = 32'd9;

        @(posedge clk);
        #1;
        en = 0;
        dividend = 0;
        divisor = 0;

        repeat (PIPELINE_STAGES + 4) begin
            @(posedge clk);
            #1;
            if (done) begin
                $display("Time = %0t ns -> Output: Quotient: %0d, Remainder: %0d", $time, quotient, remainder);
            end
        end

        #30;
        $finish;
    end

endmodule
