// mul_top : unsigned shift-add multiplier (resource-efficient)
//   Inputs valid  : multiplicand and multiplier only in the cycle start is high
//   Results valid : from the done cycle until the next accepted start
//   Latency       : done is high WIDTH+1 cycles after the start cycle
//   Busy          : high during the WIDTH add-and-shift cycles
//   Reset         : synchronous, active-high rst
//   start ignored : while busy or done is high
module mul_top
    import mul_pkg::*;
    #(
        parameter int WIDTH = 8 // Operand width 8/16/32/64/128
    ) (
        // Control
        input  logic               clk,
        input  logic               rst,
        input  logic               start,        // Single-cycle pulse
        // Data in
        input  logic [WIDTH-1:0]   multiplicand, // Valid while start is high
        input  logic [WIDTH-1:0]   multiplier,
        // Data out
        output logic [2*WIDTH-1:0] product,
        // Status
        output logic               done,         // High for one cycle when product is ready
        output logic               busy          // High while multiplying
    );

    command cmnd;

    mul_ctrl #(
        .WIDTH(WIDTH)
    ) u_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .busy(busy),
        .cmnd(cmnd)
    );

    mul_datapath #(
        .WIDTH(WIDTH)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .cmnd(cmnd),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product)
    );
endmodule
