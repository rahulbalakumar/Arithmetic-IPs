module booth_group_encoder #(
    parameter WIDTH = 8,
    parameter GROUPS = WIDTH/2
) (
    input logic [WIDTH-1:0] bits,
    output logic [1:0] sel [0:GROUPS-1],
    output logic negate [0:GROUPS-1]
);
    logic [WIDTH:0] mult_bits;
    
    always_comb begin
        mult_bits = {bits, 1'b0};
    end

    genvar i;

    generate
        for (i = 0; i < GROUPS; i++) begin : encoder
            booth_encoder dut (.group_bits(mult_bits[2*i+2:2*i]),
                          .sel(sel[i]),
                          .negate(negate[i]));
        end

    endgenerate
endmodule