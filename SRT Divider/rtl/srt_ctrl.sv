module srt_ctrl
    import srt_pkg::*;
    # (
        parameter int WIDTH = 8
    )(
        input logic clk,
        input logic rst,
        input logic div_by_zero,
        input logic start,
        input logic [$clog2(WIDTH)-1:0] lz_count,
        output logic done,
        output logic busy,
        output srt_command_t cmd
    );
    
    logic [$clog2(WIDTH)-1:0] counter;
    typedef enum logic [2:0] {
        IDLE,
        NORM,
        RUN,
        FIX,
        DONE
    } state_t;

    state_t state, next_state;

    // State Register
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else state <= next_state;
    end

    always_ff @(posedge clk) begin
        if (state == NORM) counter <= lz_count;
        if (state == RUN) begin
            if (counter != '0) begin
                counter <= counter-1;
            end
        end
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: next_state = start ? NORM: IDLE;
            NORM: next_state = div_by_zero ? DONE : RUN;
            RUN: next_state = (counter == 0) ? FIX : RUN;
            FIX: next_state = DONE;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Moore Outputs 
    always_comb begin
        done = (state == DONE);
        busy = (state == RUN || state == FIX || state == NORM);
    end

    // Mealy Outputs
    always_comb begin
        cmd = HOLD_CMD;
        case (state)
            IDLE: cmd = start ? LOAD_CMD : HOLD_CMD;
            NORM: cmd = NORM_CMD;
            RUN: cmd = RUN_CMD;
            FIX: cmd = FIX_CMD;
            DONE: cmd = HOLD_CMD;
            default: cmd = HOLD_CMD;
        endcase
    end

endmodule