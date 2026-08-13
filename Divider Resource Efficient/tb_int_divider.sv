`timescale 1ns / 1ps

module tb_int_divider;
    localparam WIDTH = 4;
    
    logic clk;
    logic rstn;
    logic en;
    logic [WIDTH-1:0] dividend;
    logic [WIDTH-1:0] divisor;
    logic done;
    logic [WIDTH-1:0] quotient;
    logic [WIDTH-1:0] remainder;

    // Instantiate the Unit Under Test (UUT)
    int_divider #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .dividend(dividend),
        .divisor(divisor),
        .done(done),
        .quotient(quotient),
        .remainder(remainder)
    );

    // Clock Generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus and Test Sequence
    initial begin
        // Initialize signals
        rstn     = 0;
        en       = 0;
        dividend = 0;
        divisor  = 0;

        // Apply Reset
        #20;
        rstn = 1;
        
        // Align to clock edge
        @(posedge clk);
        #1;

        // Drive inputs and pulse 'en' for 1 clock cycle
        dividend = 4'd15;
        divisor  = 4'd5;
        en       = 1;
        
        @(posedge clk); 
        #1;
        en       = 0; // Drop enable so computation runs

        // Wait for the hardware to finish: 
        // Either wait for the 'done' signal to go high, or wait for WIDTH (4) clock cycles.
        @(posedge done);
        #1; // Small settle delay
        
        $display("Time = %0t ns: %0d / %0d = Quotient: %0d, Remainder: %0d", 
                 $time, dividend, divisor, quotient, remainder);

        #20;
        $finish;
    end

endmodule