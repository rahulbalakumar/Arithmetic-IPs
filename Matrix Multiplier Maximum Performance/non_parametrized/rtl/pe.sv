module pe (
    input logic [7:0] a_in,
    input logic [7:0] w_in,
    input logic rstn,
    input logic clk,
    output logic [7:0] a_out,
    output logic [7:0] w_out,
    output logic [15:0] acc
);
    logic [15:0] result;
    logic [7:0] a_reg;
    logic [7:0] w_reg;
    always_ff @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            result <= '0;
            a_reg <= '0;
            w_reg <= '0;
        end else begin
            a_reg <= a_in;
            w_reg <= w_in;
            result <= result + a_in * w_in;
        end
    end 

    always_comb begin
        a_out = a_reg;
        w_out = w_reg;
        acc = result;
    end
endmodule
