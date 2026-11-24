// lzc : leading-zero counter, recursive tree version (log2(WIDTH) levels)
//   Splits x into an upper and a lower half and counts each half with a smaller lzc:
//     upper half all zero -> count = WIDTH/2 + count(lower half) = {1'b1, lower count}
//     otherwise           -> count = count(upper half)           = {1'b0, upper count}
//   WIDTH must be a power of 2 (8/16/32/64/128). count is meaningless when zero = 1.
module lzc #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0]         x,     // Value to scan
    output logic [$clog2(WIDTH)-1:0] count, // Number of leading zeros
    output logic                     zero   // High if x is all zeros
);
    generate
        if (WIDTH == 2) begin : base
            assign count = ~x[1];          // 1 leading zero if the top bit is 0
            assign zero  = ~(x[1] | x[0]);
        end else begin : split
            localparam int HALF = WIDTH / 2;

            logic [$clog2(HALF)-1:0] hi_count, lo_count;
            logic                    hi_zero,  lo_zero;

            lzc #(.WIDTH(HALF)) u_hi (
                .x(x[WIDTH-1:HALF]),
                .count(hi_count),
                .zero(hi_zero)
            );

            lzc #(.WIDTH(HALF)) u_lo (
                .x(x[HALF-1:0]),
                .count(lo_count),
                .zero(lo_zero)
            );

            assign count = hi_zero ? {1'b1, lo_count} : {1'b0, hi_count};
            assign zero  = hi_zero & lo_zero;
        end
    endgenerate
endmodule
