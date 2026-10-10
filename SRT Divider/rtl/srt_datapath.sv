module srt_datapath
    import srt_pkg::*;
    #(
        parameter int WIDTH = 8
    ) ( 
        input logic clk,
        input logic rst,
        input srt_command_t cmd, // Command from srt_ctrl
        input logic [WIDTH-1:0] dividend, // Captured on LOAD_CMD
        input logic [WIDTH-1:0] divisor, // Captured on LOAD_CMD
        output logic [WIDTH-1:0] quotient,
        output logic [WIDTH-1:0] remainder,
        output logic div_by_zero, // High when captured divisor is 0
        output logic [$clog2(WIDTH)-1:0] lz_count // Number of leading zeros of the captured divisor
    );  

        // Registers
        logic [WIDTH-1:0] a_reg; // Written during load, holds dividend
        logic [WIDTH-1:0] b_reg; // Written during load, holds divisor
        logic [$clog2(WIDTH)-1:0] s_reg; // Written during norm, holds shift amount (fix state needs it)
        logic [WIDTH-1:0] D; // Normalized divisor (MSB = 1)
        logic signed [WIDTH+1:0] V; // Partial remainder
        logic [WIDTH-1:0] Qp, Qm; // Digit shift registers

        // Combinational signals
        logic q_pos, q_neg; // Digit from srt_qsel
        logic signed [WIDTH+1:0] D_ext; // Extended D to V's width
        logic signed [WIDTH+1:0] V_step; // Holds V-D or V+D
        logic signed [WIDTH+1:0] V_next; // 2 * V_step (Stored during RUN)
        logic signed [WIDTH+1:0] R_final; // Real remainder (recovered from V by shifting right)
        logic signed [WIDTH+1:0] R_corr; // To correct negative remainder
        logic [WIDTH-1:0] Q_final; // Qp + ~Qm + carry-in
        logic [WIDTH-1:0] rem_final; // R_corr shifted right by s_reg
        logic carry_in;
        // Submodules
        lzc #(
            .WIDTH(WIDTH)
        ) u_lzc (
            .x(b_reg),
            .count(lz_count),
            .zero(div_by_zero)
        );

        srt_qsel u_qsel (
            .top(V[WIDTH+1:WIDTH-1]),
            .q_pos(q_pos),
            .q_neg(q_neg)
        );

        // Single SRT step
        always_comb begin
            D_ext = {1'b0,1'b0,D};
            if (q_pos) begin
                V_step = V - D_ext;
            end else if (q_neg) begin
                V_step = V + D_ext;
            end else begin
                V_step = V;
            end

            V_next = (V_step << 1);
        end
        // Final fix up
        always_comb begin
            R_final = V >>> 1; // Recovering R from previous step
            if (R_final < 0) begin
                R_corr = R_final + D_ext;
            end else begin
                R_corr = R_final;
            end
            if (R_final >= 0) begin
                carry_in = 1;
            end else begin
                carry_in = 0;
            end

            Q_final = Qp + ~Qm + carry_in;
            rem_final = R_corr[WIDTH-1:0] >> s_reg;
        end

        // State Registers
        always_ff @(posedge clk) begin
            if (rst) begin
                a_reg <= '0;
                b_reg <= '0;
                s_reg <= '0;
                D <= '0;
                V <= '0;
                Qp <= '0;
                Qm <= '0;
                quotient <= '0;
                remainder <= '0;
            end else begin

                case (cmd)
                    LOAD_CMD: begin
                        a_reg <= dividend;
                        b_reg <= divisor;
                    end
                    NORM_CMD: begin
                        s_reg <= lz_count;
                        D <= b_reg << lz_count;
                        V <= {2'b00,a_reg};
                        Qp <= '0;
                        Qm <= '0;
                        if (div_by_zero) begin
                            quotient <= '1;
                            remainder <= a_reg;
                        end
                    end
                    RUN_CMD: begin
                        V <= V_next;
                        Qp <= {Qp[WIDTH-2:0],q_pos};
                        Qm <= {Qm[WIDTH-2:0],q_neg};
                    end
                    FIX_CMD: begin
                        quotient <= Q_final;
                        remainder <= rem_final;
                    end
                    HOLD_CMD:begin
                    end
                    default: ;

                endcase
            end
        end

endmodule