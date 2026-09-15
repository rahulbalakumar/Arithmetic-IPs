module booth_adder #(
    parameter WIDTH = 8,
    parameter GROUPS = WIDTH/2
) (
    input logic [2*WIDTH-1:0] addends [0:GROUPS*2-1],
    output logic [2*WIDTH-1:0] sum
);
    logic [2*WIDTH-1:0] result;
    always_comb begin
        result = '0;
        for (int i = 0; i < 2*GROUPS; i++) begin
            result = result + addends[i];
        end
        sum = result;
    end
endmodule