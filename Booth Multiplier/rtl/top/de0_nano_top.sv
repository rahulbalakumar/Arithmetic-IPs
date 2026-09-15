module de0_nano_top (
    input logic [3:0] SW,
    input logic [1:0] KEY,
    output logic [7:0] LED
);

    logic [7:0] A, B;
    logic [15:0] product;


    always_comb begin
        case (SW)
            4'd0:  begin A = 8'd10;    B = 8'd10;    end // 100
            4'd1:  begin A = -8'sd15;  B = 8'd10;    end // -150
            4'd2:  begin A = -8'sd60;  B = -8'sd60;  end // 3600
            4'd3:  begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd4:  begin A = 8'd1;     B = -8'sd128; end // -128
            4'd5:  begin A = -8'sd12;  B = 8'd10;    end // -120
            4'd6:  begin A = -8'sd8;   B = -8'sd10;  end // 80
            4'd7:  begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd8:  begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd9:  begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd10: begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd11: begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd12: begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd13: begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd14: begin A = -8'sd128; B = -8'sd128; end // 16384
            4'd15: begin A = -8'sd128; B = -8'sd128; end // 16384

            default: begin A = 8'd0; B = 8'd0; end
        endcase
    end

    booth_multiplier_tree_recursive #(.WIDTH(8)) dut (
        .A(A),
        .B(B),
        .product(product)
    );


    assign LED = KEY[0] ? product[15:8] : product[7:0];
endmodule