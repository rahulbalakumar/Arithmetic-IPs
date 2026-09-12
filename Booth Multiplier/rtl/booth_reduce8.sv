module booth_reduce8 #(
    parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] rows [0:7],
    output logic [WIDTH-1:0] final_row_1,
    output logic [WIDTH-1:0] final_row_2
);

    logic [WIDTH-1:0] stage1 [0:5]; // 8 -> 6

    booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor1 (
        .A(rows[0]),
        .B(rows[1]),
        .C(rows[2]),
        .sum(stage1[0]),
        .carry(stage1[1])
    );
    booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor2 (
        .A(rows[3]),
        .B(rows[4]),
        .C(rows[5]),
        .sum(stage1[2]),
        .carry(stage1[3])
    );
    assign stage1[4] = rows[6];
    assign stage1[5] = rows[7];

    logic [WIDTH-1:0] stage2 [0:3]; // 6 -> 4

    booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor3 (
        .A(stage1[0]),
        .B(stage1[1]),
        .C(stage1[2]),
        .sum(stage2[0]),
        .carry(stage2[1])
    );
    booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor4 (
        .A(stage1[3]),
        .B(stage1[4]),
        .C(stage1[5]),
        .sum(stage2[2]),
        .carry(stage2[3])
    );

    logic [WIDTH-1:0] stage3 [0:2]; // 4 -> 3

    booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor5 (
        .A(stage2[0]),
        .B(stage2[1]),
        .C(stage2[2]),
        .sum(stage3[0]),
        .carry(stage3[1])
    );
    assign stage3[2] = stage2[3];

    booth_compressor_3to2 #(.WIDTH(WIDTH)) compressor6 (
        .A(stage3[0]),
        .B(stage3[1]),
        .C(stage3[2]),
        .sum(final_row_1),
        .carry(final_row_2)
    );

endmodule