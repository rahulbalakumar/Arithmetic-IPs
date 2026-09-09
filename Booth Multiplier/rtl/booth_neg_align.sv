module booth_neg_align #(
    parameter WIDTH = 8,
    parameter IDX = 0
) (
    input logic negate,
    output logic [2*WIDTH-1:0] neg_bits
);

    always_comb begin
        neg_bits = '0;
        if (negate) begin
            neg_bits = {{(2*WIDTH - 2*IDX - 1){1'b0}},1'b1,{(2*IDX){1'b0}}};
        end
    end
endmodule