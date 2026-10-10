`timescale 1ns / 1ps
module int_divider_perf #(
    parameter int WIDTH = 32,
    parameter int PIPELINE_STAGES = 4
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
    // Number of bits handled by each pipeline stage
    localparam int BITS_PER_STAGE = WIDTH / PIPELINE_STAGES;

    logic [WIDTH:0] pipe_A [PIPELINE_STAGES:0]; 
    logic [WIDTH-1:0] pipe_Q [PIPELINE_STAGES:0]; 
    logic [WIDTH-1:0] pipe_M [PIPELINE_STAGES:0]; // Divisor
    logic pipe_valid [PIPELINE_STAGES:0];

    assign done = pipe_valid[PIPELINE_STAGES]; // output done is connected to last pipeline stage's pipe_valid register


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pipe_valid[0] <= 1'b0;
            pipe_A[0] <= '0;
            pipe_Q[0] <= '0;
            pipe_M[0] <= '0;
        end else begin
            pipe_valid[0] <= en;
            if (en) begin
                pipe_A[0] <= '0;
                pipe_Q[0] <= dividend;
                pipe_M[0] <= divisor;
            end
        end
    end


    genvar s, b;
    generate
        for (s = 0; s < PIPELINE_STAGES; s++) begin : pipe_stage
            
            /* verilator lint_off UNOPTFLAT */
            
            // Packed arrays for internal stage routing
            logic [BITS_PER_STAGE:0] [WIDTH:0]   stage_A;
            logic [BITS_PER_STAGE:0] [WIDTH-1:0] stage_Q;

            assign stage_A[0] = pipe_A[s];
            assign stage_Q[0] = pipe_M[s] == '0 ? '0 : pipe_Q[s]; // Safe connection

            for (b = 0; b < BITS_PER_STAGE; b++) begin : bit_loop
                logic [WIDTH-1:0] shifted_A;
                logic [WIDTH:0]   sub_result;

                assign shifted_A  = {stage_A[b][WIDTH-2:0], stage_Q[b][WIDTH-1]};
                assign sub_result = {1'b0, shifted_A} - {1'b0, pipe_M[s]};

                assign stage_A[b+1] = (sub_result[WIDTH] == 1'b1) ? {1'b0, shifted_A} : sub_result;
                assign stage_Q[b+1] = (sub_result[WIDTH] == 1'b1) ? {stage_Q[b][WIDTH-2:0], 1'b0} : {stage_Q[b][WIDTH-2:0], 1'b1};
            end

            /* verilator lint_on UNOPTFLAT */
            /* verilator lint_on UNOPTFLAT */


            always_ff @(posedge clk or negedge rstn) begin
                if (!rstn) begin
                    pipe_valid[s+1] <= 1'b0;
                    pipe_A[s+1] <= '0;
                    pipe_Q[s+1] <= '0;
                    pipe_M[s+1] <= '0;
                end else begin
                    pipe_valid[s+1] <= pipe_valid[s];
                    pipe_A[s+1] <= stage_A[BITS_PER_STAGE];
                    pipe_Q[s+1] <= stage_Q[BITS_PER_STAGE];
                    pipe_M[s+1] <= pipe_M[s]; // Divisor remains unchanged
                end
            end
        end
    endgenerate

    assign quotient = pipe_Q[PIPELINE_STAGES];
    assign remainder = pipe_A[PIPELINE_STAGES][WIDTH-1:0]; // To exclude MSB
endmodule
