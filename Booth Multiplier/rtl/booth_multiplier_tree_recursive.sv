module booth_multiplier_tree_recursive #(
    parameter WIDTH = 8,
    parameter GROUPS = WIDTH/2
) (
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    output logic [2*WIDTH-1:0] product
);
    logic [1:0] sel [0:GROUPS-1];
    logic negate [0:GROUPS-1];
    logic [WIDTH:0] pp [0:GROUPS-1];
    logic [2*WIDTH-1:0] row [0:GROUPS-1];
    logic [2*WIDTH-1:0] neg_bits [0:GROUPS-1];
    logic [2*WIDTH-1:0] addends [0:2*GROUPS-1];

    booth_group_encoder #(.WIDTH(WIDTH)) encoder (
        .bits(A),
        .sel(sel),
        .negate(negate)
    );

    genvar i;
    generate
        for (i = 0; i < GROUPS; i++) begin : gen
            booth_pp_gen #(.WIDTH(WIDTH)) u_pp_gen (
                .M(B),
                .sel(sel[i]),
                .negate(negate[i]),
                .pp(pp[i])
            );

            booth_pp_align #(.WIDTH(WIDTH), .IDX(i)) u_pp_align (
                .pp(pp[i]),
                .row(row[i])
            );

            booth_neg_align #(.WIDTH(WIDTH),.IDX(i)) u_neg_align (
                .negate(negate[i]),
                .neg_bits(neg_bits[i])
            );

        end 
    endgenerate
    logic [2*WIDTH-1:0] final_row_1;
    logic [2*WIDTH-1:0] final_row_2;
    
    always_comb begin
        for (int i = 0; i < GROUPS; i++) begin
            addends[i] = row[i];
            addends[i+GROUPS] = neg_bits[i];
        end

    end
    
    booth_reduce_tree #(.WIDTH(2*WIDTH), .N(2*GROUPS)) dut (
        .rows(addends),
        .out1(final_row_1),
        .out2(final_row_2)
    );
    
    assign product = final_row_1 + final_row_2;

endmodule