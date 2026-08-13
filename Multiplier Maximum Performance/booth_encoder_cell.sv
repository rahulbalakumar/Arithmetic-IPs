module booth_encoder_cell(
    input logic [2:0] three_bits,
    input logic [127:0] A,
    output logic [127:0] partial_product,
    output logic neg
);

    logic sel_1A, sel_2A, sel_neg;

    always_comb begin

        sel_1A = 1'b0;
        sel_2A = 1'b0;
        sel_neg = 1'b0;

        case (three_bits) // Booth recoding truth table
            3'b000: begin sel_1A = 0; sel_2A = 0; sel_neg = 0; end
            3'b001: begin sel_1A = 1; sel_2A = 0; sel_neg = 0; end
            3'b010: begin sel_1A = 1; sel_2A = 0; sel_neg = 0; end
            3'b011: begin sel_1A = 0; sel_2A = 1; sel_neg = 0; end
            3'b100: begin sel_1A = 0; sel_2A = 1; sel_neg = 1; end
            3'b101: begin sel_1A = 1; sel_2A = 0; sel_neg = 1; end
            3'b110: begin sel_1A = 1; sel_2A = 0; sel_neg = 1; end
            3'b111: begin sel_1A = 0; sel_2A = 0; sel_neg = 0; end
            default:;
        endcase
    end

    logic [127:0] selected_val;
    always_comb begin
        if (sel_2A) selected_val = (A << 1); // A times 2
        else if (sel_1A) selected_val = A; 
        else selected_val = '0;

        partial_product = sel_neg ? (~selected_val + 1'b1) : selected_val;
        neg = sel_neg;
    end
endmodule
