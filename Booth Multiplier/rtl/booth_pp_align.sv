module booth_pp_align #(
    parameter WIDTH = 8,
    parameter IDX = 0
)(
    input logic [WIDTH:0] pp,
    output logic [2*WIDTH-1:0] row
);
    localparam shift_amount = 2 * IDX;
    localparam sign_copies = WIDTH - shift_amount - 1;

    always_comb begin
        row = {{(sign_copies){pp[WIDTH]}}, pp, {(shift_amount){1'b0}}};
    end

endmodule