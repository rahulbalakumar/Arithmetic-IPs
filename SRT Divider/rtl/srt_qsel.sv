module srt_qsel (
    input logic [2:0] top, // Top 3 bits of remainder (sign bit and the next two)
    output logic q_pos,
    output logic q_neg
);

    always_comb begin
        q_pos = 0;
        q_neg = 0;
        case (top)
            3'b000: begin
                q_pos = 0;
                q_neg = 0;
            end
            3'b001: begin
                q_pos = 1;
                q_neg = 0;
            end
            3'b010: begin
                q_pos = 1;
                q_neg = 0;
            end
            3'b011: begin
                q_pos = 1;
                q_neg = 0;
            end
            3'b100: begin
                q_pos = 0;
                q_neg = 1;
            end
            3'b101: begin
                q_pos = 0;
                q_neg = 1;
            end
            3'b110: begin
                q_pos = 0;
                q_neg = 1;
            end
            3'b111: begin
                q_pos = 0;
                q_neg = 0;
            end
        endcase
    end

endmodule