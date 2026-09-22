module div_datapath
    import div_pkg::*;
     #(parameter WIDTH = 8) (
    input logic clk,
    input logic rst,
    input command cmnd,
    input logic [WIDTH-1:0] divisor,
    input logic [WIDTH-1:0] dividend,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic div_by_zero
);
    logic [WIDTH-1:0] shift_reg;
    logic [WIDTH-1:0] d_reg;
    logic [WIDTH-1:0] r_reg;
    logic [WIDTH:0] calc_wire_1;
    logic [WIDTH:0] calc_wire_2;

    assign div_by_zero = (d_reg == 0); // Only valid when done is high

    logic q_bit;
    
    always_comb begin
        calc_wire_1 = {r_reg,shift_reg[WIDTH-1]}; // holds shifted R with leftmost bit of shift_reg
        
        q_bit = ({1'b0, d_reg} <= calc_wire_1); // zero extension to make d_reg have WIDTH + 1 bits

        calc_wire_2 = calc_wire_1 - {1'b0,d_reg}; // holds difference between remainder and divisor

    end
    always_ff @(posedge clk) begin
        if (rst) begin
            shift_reg <= '0;
            d_reg <= '0;
            r_reg <= '0;
        end else begin
            case (cmnd)
                LOAD_CMD: begin
                    r_reg <= '0;
                    shift_reg <= dividend;
                    d_reg <= divisor;
                end
                RUN_CMD: begin
                    r_reg <= q_bit ? calc_wire_2[WIDTH-1:0] : calc_wire_1[WIDTH-1:0]; 
                    shift_reg <= {shift_reg[WIDTH-2:0],q_bit}; // shifting with rightmost replaced by quotient
                end
                HOLD_CMD: begin
                end
                default: begin
                end
            endcase
        end
    end
    assign quotient = shift_reg;
    assign remainder = r_reg;
endmodule