// Control: IDLE -> FEED (N input cycles, the first is the start cycle) -> DRAIN -> DONE
//   in_valid : inputs are passed to the array only while matrices are being fed;
//              otherwise zeros are fed, so the user does not have to drive zeros
//   clear    : PE accumulators restart in the start cycle
//   done     : high 3N-2 cycles after the start cycle (last product reaches PE(N-1,N-1))
module matmul_ctrl #(
    parameter int N = 3
) (
    input  logic clk,
    input  logic rstn,
    input  logic start,
    output logic in_valid,
    output logic clear,
    output logic busy,
    output logic done
);
    localparam int LAT   = 3*N - 2;        // start cycle -> done cycle
    localparam int CNT_W = $clog2(LAT + 1);

    typedef enum logic [1:0] {IDLE, FEED, DRAIN, DONE} state_t;
    state_t state, next_state;
    logic [CNT_W-1:0] count; // cycles since the start cycle

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) state <= IDLE;
        else       state <= next_state;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)              count <= '0;
        else if (state == IDLE) count <= CNT_W'(1); // the start cycle is cycle 0
        else                    count <= count + 1'b1;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:    if (start) next_state = (N == 1) ? DRAIN : FEED;
            FEED:    if (count == CNT_W'(N-1))   next_state = DRAIN;
            DRAIN:   if (count == CNT_W'(LAT-1)) next_state = DONE;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    assign clear    = (state == IDLE) && start;
    assign in_valid = clear || (state == FEED);
    assign busy     = (state == FEED) || (state == DRAIN);
    assign done     = (state == DONE);
endmodule
