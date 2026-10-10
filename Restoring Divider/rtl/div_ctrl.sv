module div_ctrl 
    import div_pkg::*;
    #(
    parameter WIDTH = 8
)(
    input logic clk,
    input logic rst,
    input logic start,
    output logic done,
    output logic busy,
    output command cmnd 
);

    logic [$clog2(WIDTH)-1:0] counter;
    typedef enum logic [1:0] {
        IDLE,
        RUN,
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
        if (state == IDLE) counter <= '0;
        if (state == RUN) counter <= counter + 1;
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (start) next_state = RUN;
            RUN : if (counter == WIDTH-1) next_state = DONE;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Moore Outputs
    always_comb begin
        done = (state == DONE);
        busy = (state == RUN);
    end

    // Mealy Outputs
    always_comb begin
        cmnd = HOLD_CMD;
        case (state)
            IDLE: begin  
                if (start) cmnd = LOAD_CMD; else cmnd = HOLD_CMD;
            end
            RUN: cmnd = RUN_CMD;
            DONE: cmnd = HOLD_CMD;
        endcase

    end
endmodule
