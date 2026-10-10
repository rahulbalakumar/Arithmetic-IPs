module lzc #(
    parameter int WIDTH = 8
) (
    input logic [WIDTH-1:0] x, // Value to scan for leading zeros
    output logic [$clog2(WIDTH)-1:0] count, // Number of leading zeros
    output logic zero // flag to set if x is 0
);
    // Zero detection
    assign zero = (x == '0);

    // Leading zero scan
    always_comb begin
        logic found;
        int i;
        count = 0;
        found = 0;
        for (i = WIDTH-1; i >= 0; i--) begin
            if ((x[i] == 1) && found == 0) begin
                count = $clog2(WIDTH)'(WIDTH - 1 - i);
                found = 1;
            end
        end
    end
endmodule