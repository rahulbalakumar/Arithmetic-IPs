module booth_compressor_3to2 #(
    parameter WIDTH = 8
)(
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    input logic [WIDTH-1:0] C,
    output logic [WIDTH-1:0] sum,
    output logic [WIDTH-1:0] carry
);
    logic [WIDTH-1:0] raw_carry; 

    always_comb begin
        for (int j = 0; j < WIDTH; j++) begin
            {raw_carry[j],sum[j]} = A[j] + B[j] + C[j];
        end
        carry = {raw_carry,1'b0};
    end
endmodule