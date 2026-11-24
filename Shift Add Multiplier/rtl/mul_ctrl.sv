// Same FSM as div_ctrl: IDLE -> RUN (WIDTH cycles) -> DONE
module mul_ctrl
    import mul_pkg::*;
    #(
        parameter int WIDTH = 8
    ) (
        input  logic   clk,
        input  logic   rst,
        input  logic   start,
        output logic   done,
        output logic   busy,
        output command cmnd
    );

    logic [$clog2(WIDTH)-1:0] counter;

    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE
    } state_t;

    state_t state, next_state;

    // State register
    always_ff @(posedge clk) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    // Iteration counter: 0 .. WIDTH-1 during RUN
    always_ff @(posedge clk) begin
        if (state == IDLE) counter <= '0;
        if (state == RUN)  counter <= counter + 1'b1;
    end

    // Next-state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:    if (start) next_state = RUN;
            RUN:     if (counter == $clog2(WIDTH)'(WIDTH-1)) next_state = DONE;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Moore outputs
    always_comb begin
        done = (state == DONE);
        busy = (state == RUN);
    end

    // Mealy output: LOAD in the same cycle as start
    always_comb begin
        cmnd = HOLD_CMD;
        case (state)
            IDLE:    cmnd = start ? LOAD_CMD : HOLD_CMD;
            RUN:     cmnd = RUN_CMD;
            DONE:    cmnd = HOLD_CMD;
            default: cmnd = HOLD_CMD;
        endcase
    end
endmodule
