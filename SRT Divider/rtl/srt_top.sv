// Inputs valid: Only in the cycle where 'start' is high
// Results valid: From the 'done' until the next 'start'
// Latency: 'done' is high s + 4 cycles after 'start'
// Busy: High during NORM, RUN and FIX
// Divide by 0: quotient = all ones, remainder = dividend, div_by_zero = 1
// 'start' is ignored during 'busy' or during 'done' is high

module srt_top
    import srt_pkg::*;
    #(
        parameter int WIDTH = 8
    ) (
        // Control
        input logic clk,
        input logic rst,
        input logic start,
        // Data in
        input logic [WIDTH-1:0] dividend,
        input logic [WIDTH-1:0] divisor,
        // Data out
        output logic [WIDTH-1:0] quotient,
        output logic [WIDTH-1:0] remainder,
        // Status
        output logic done,
        output logic busy,
        output logic div_by_zero
    );

    srt_command_t cmd;
    logic [$clog2(WIDTH)-1:0] lz_count;

    srt_ctrl #(
        .WIDTH(WIDTH)
    ) u_ctrl (
        .clk(clk),
        .rst(rst),
        .div_by_zero(div_by_zero),
        .start(start),
        .lz_count(lz_count),
        .done(done),
        .busy(busy),
        .cmd(cmd)
    );

    srt_datapath #(
        .WIDTH(WIDTH)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .cmd(cmd),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .div_by_zero(div_by_zero),
        .lz_count(lz_count)
    );

endmodule