module booth_reduce_tree #(
    parameter WIDTH = 8,
    parameter N = 8
) (
    input logic [WIDTH-1:0] rows [0:N-1],
    output logic [WIDTH-1:0] out1,
    output logic [WIDTH-1:0] out2
);

    generate 
        if (N == 2) begin : base_case
            assign out1 = rows[0];
            assign out2 = rows[1];
        end else begin: recursive
            localparam GROUPS = N / 3;
            localparam REMAINDER = N % 3;
            localparam N_NEXT = 2*GROUPS + REMAINDER;

            logic [WIDTH-1:0] next_stage [0:N_NEXT-1];

            genvar i;
            for (i = 0; i < GROUPS; i++) begin : compressing
                booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor (
                    .A(rows[3*i]),
                    .B(rows[3*i+1]),
                    .C(rows[3*i+2]),
                    .sum(next_stage[2*i]),
                    .carry(next_stage[2*i+1])
                    );
            end 

            for (i = 0; i < REMAINDER; i++) begin : passthrough
                assign next_stage[2*GROUPS+i] = rows[3*GROUPS+i];
            end

            booth_reduce_tree #(.WIDTH(WIDTH), .N(N_NEXT)) recurse_inst (
                .rows(next_stage),
                .out1(out1),
                .out2(out2)
            );
        end
    endgenerate
endmodule