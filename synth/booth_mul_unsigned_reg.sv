// Synthesis-only wrapper: registers on the inputs and the output of the
// combinational Booth multiplier, so the Timing Analyzer can report an Fmax
// (the register-to-register path is the multiplier itself). Latency 2 cycles.
module booth_mul_unsigned_reg #(
    parameter int WIDTH = 32
) (
    input  logic               clk,
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,
    output logic [2*WIDTH-1:0] product
);
    logic [WIDTH-1:0]   a_reg, b_reg;
    logic [2*WIDTH-1:0] p_comb;

    booth_mul_unsigned #(
        .WIDTH(WIDTH)
    ) u_mul (
        .A(a_reg),
        .B(b_reg),
        .product(p_comb)
    );

    always_ff @(posedge clk) begin
        a_reg   <= A;
        b_reg   <= B;
        product <= p_comb;
    end
endmodule
