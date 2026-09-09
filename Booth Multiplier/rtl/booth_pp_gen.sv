module booth_pp_gen (
    input logic [7:0] M,
    input logic [1:0] sel,
    input logic negate,
    output logic [8:0] pp
);

    always_comb begin
        if (sel == 2'b00 && negate == 0) begin // Zero
            pp = 8'd0;
        end else if (sel == 2'b01 && negate == 0) begin // M
            pp = {M[7],M};
        end else if (sel == 2'b10 && negate == 0) begin // 2*M
            pp = {M,1'b0};
        end else if (sel == 2'b10 && negate == 1) begin // -2*M
            pp = {~M,1'b1};
        end else if (sel == 2'b01 && negate == 1) begin // -M
            pp = {~M[7],~M};
        end else begin
            pp = 8'd0;
        end
    end
endmodule
