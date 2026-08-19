module skew (
    input logic [7:0] row0_in,
    input logic [7:0] row1_in,
    input logic [7:0] col0_in,
    input logic [7:0] col1_in,
    input logic clk,
    input logic rstn,
    output logic [7:0] row0_out,
    output logic [7:0] row1_out,
    output logic [7:0] col0_out,
    output logic [7:0] col1_out
);
    
    always_comb begin
        row0_out = row0_in;
        col0_out = col0_in;
    end
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            row1_out <= '0;
            col1_out <= '0;
        end else begin
            row1_out <= row1_in;
            col1_out <= col1_in;
        end
    end

endmodule