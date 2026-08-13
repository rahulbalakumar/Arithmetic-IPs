`timescale 1ns / 1ps
module int_divider #(
    parameter int WIDTH = 32
)(
    input logic clk,
    input logic rstn,
    input logic en,
    output logic done,
    input logic [WIDTH-1:0] dividend,
    input logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder
);

    logic [WIDTH-1:0] A; // Accumulator Register
    logic [WIDTH-1:0] Q; // Quotient Register
    logic [WIDTH-1:0] M; // Divisor Register
    logic [WIDTH:0] sub_result; 
    logic [$clog2(WIDTH)-1:0] count;

    // FSM
    typedef enum logic {
        IDLE = 1'b0,
        COMPUTE = 1'b1
    } state_t ;

    state_t current_state, next_state;

    logic done_internal;
    assign done = done_internal;

    assign quotient  = Q;
    assign remainder = A;

    // Shifted version of A combined with top bit of Q for trial subtraction
    logic [WIDTH-1:0] shifted_A;
    logic [WIDTH:0]   shifted_sub;

    assign shifted_A   = {A[WIDTH-2:0], Q[WIDTH-1]};
    assign shifted_sub = {1'b0, shifted_A} - {1'b0, M};

    always_comb begin
        sub_result = {1'b0,A} - {1'b0,M}; // 1'b0 is added to make sure sub_result is WIDTH+1 long
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_state <= IDLE;
            A             <= '0;
            Q             <= '0;
            M             <= '0;
            count         <= '0;
            done_internal <= 1'b1;
        end else begin
                case (current_state)
                    IDLE: begin
                        if (en) begin
                            Q             <= dividend;
                            M             <= divisor;
                            A             <= '0;
                            count         <= $clog2(WIDTH)'(WIDTH);
                            current_state <= COMPUTE;
                            done_internal <= 0;
                        end
                    end
                    COMPUTE: begin
                        if (shifted_sub[WIDTH] == 1'b1) begin // A - M is negative
                            A <= shifted_A;
                            Q <= {Q[WIDTH-2:0], 1'b0};

                        end else begin
                            A <= shifted_sub[WIDTH-1:0];
                            Q <= {Q[WIDTH-2:0], 1'b1};
                        end

                        if (count == 'd1) begin
                            current_state <= IDLE;
                            done_internal <= 1'b1;
                        end else begin
                            count <= count - 1;
                        end
                    end
                endcase
        end
    end
endmodule