module booth_encoder (
    input logic [2:0] group_bits,
    output logic [1:0] sel, // 00 : zero, 01 : one, 10: two
    output logic negate
);

    always_comb begin
        sel = '0;
        negate = 0;
        case (group_bits) 
            3'b000: begin sel = 2'b00; negate = 0; end
            3'b001: begin sel = 2'b01; negate = 0; end
            3'b010: begin sel = 2'b01; negate = 0; end
            3'b011: begin sel = 2'b10; negate = 0; end
            3'b100: begin sel = 2'b10; negate = 1; end
            3'b101: begin sel = 2'b01; negate = 1; end
            3'b110: begin sel = 2'b01; negate = 1; end
            3'b111: begin sel = 2'b00; negate = 0; end
            default: ;
        endcase

    end
endmodule