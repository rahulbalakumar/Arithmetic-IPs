// Unsigned shift-add datapath: one WIDTH-bit adder reused every cycle.
// The multiplier starts in p_lo and is consumed from the bottom while
// the product fills in from the top.
module mul_datapath
    import mul_pkg::*;
    #(
        parameter int WIDTH = 8
    ) (
        input  logic               clk,
        input  logic               rst,
        input  command             cmnd,         // Command from mul_ctrl
        input  logic [WIDTH-1:0]   multiplicand, // Captured on LOAD_CMD
        input  logic [WIDTH-1:0]   multiplier,   // Captured on LOAD_CMD (into p_lo)
        output logic [2*WIDTH-1:0] product
    );

    // Registers
    logic [WIDTH-1:0] a_reg; // Multiplicand
    logic [WIDTH-1:0] p_hi;  // Upper half of the product (partial sum)
    logic [WIDTH-1:0] p_lo;  // Lower half: remaining multiplier bits + finished product bits

    // Combinational
    logic [WIDTH:0] sum;     // p_hi + (p_lo[0] ? a_reg : 0), WIDTH+1 bits keeps the carry-out

    // One add step
    always_comb begin
        sum = {1'b0, p_hi} + (p_lo[0] ? {1'b0, a_reg} : '0);
    end

    // Registers update
    always_ff @(posedge clk) begin
        if (rst) begin
            a_reg <= '0;
            p_hi  <= '0;
            p_lo  <= '0;
        end else begin
            case (cmnd)
                LOAD_CMD: begin
                    a_reg <= multiplicand;
                    p_hi  <= '0;
                    p_lo  <= multiplier;
                end
                RUN_CMD: begin
                    // Shift {sum, p_lo} right by 1: carry-out enters the top,
                    // the used multiplier bit drops off the bottom
                    p_hi <= sum[WIDTH:1];
                    p_lo <= {sum[0], p_lo[WIDTH-1:1]};
                end
                default: ; // HOLD_CMD: keep everything
            endcase
        end
    end

    assign product = {p_hi, p_lo};
endmodule
