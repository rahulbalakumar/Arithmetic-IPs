// Processing element: one unsigned multiply-accumulate per cycle.
// Activation flows right, weight flows down, each through one register.
module pe #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 19
) (
    input  logic              clk,
    input  logic              rstn,   // Asynchronous, active-low
    input  logic              clear,  // 1: start a new sum (acc <= a*w instead of acc + a*w)
    input  logic [DATA_W-1:0] a_in,
    input  logic [DATA_W-1:0] w_in,
    output logic [DATA_W-1:0] a_out,
    output logic [DATA_W-1:0] w_out,
    output logic [ACC_W-1:0]  acc
);
    logic [ACC_W-1:0]    result;
    logic [2*DATA_W-1:0] product;

    assign product = a_in * w_in; // Full 2*DATA_W-bit product (operands widened by the context)

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            result <= '0;
            a_out  <= '0;
            w_out  <= '0;
        end else begin
            a_out  <= a_in;
            w_out  <= w_in;
            result <= clear ? ACC_W'(product) : result + ACC_W'(product);
        end
    end

    assign acc = result;
endmodule
