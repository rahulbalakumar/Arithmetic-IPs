// Inputs valid: Only in the cycle start is high
// Results valid: From the done cycle until the next start is high
// Latency: done is high WIDTH+1 cycles after the start cycle
// Busy: High during WIDTH iteration cycles
// Divide by 0: quotient = all ones, remainder = dividend, div_by_zero = 1
// Start is ignored during busy or done is high


module div_top 
    import div_pkg::*;
    #(
        parameter WIDTH = 8 // Operand Width 8/16/32/64/128
    ) (
        // Control
        input logic clk,
        input logic rst,
        input logic start, // Single cycle pulse to indicate start
        // Data In
        input logic [WIDTH-1:0] dividend, // Valid while start is high
        input logic [WIDTH-1:0] divisor,
        // Data out
        output logic [WIDTH-1:0] quotient,
        output logic [WIDTH-1:0] remainder,
        // Status
        output logic done, // High for exactly one cycle when result is ready
        output logic busy, // High while division in progress
        output logic div_by_zero // High if divisor is 0
    );
    // Internal Signal
    command cmnd;

    // Control Unit
    div_ctrl #(
        .WIDTH(WIDTH)
    ) u_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .busy(busy),
        .cmnd(cmnd)
    );
    // Datapath
    div_datapath #(
        .WIDTH(WIDTH)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .cmnd(cmnd),
        .divisor(divisor),
        .dividend(dividend),
        .quotient(quotient),
        .remainder(remainder),
        .div_by_zero(div_by_zero)
    );



endmodule