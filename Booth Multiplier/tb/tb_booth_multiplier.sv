`timescale 1ns / 1ps
module tb_booth_multiplier;
    localparam WIDTH = 8;

    logic [WIDTH-1:0] A;
    logic [WIDTH-1:0] B;
    logic [2*WIDTH-1:0] product;

    booth_multiplier #(.WIDTH(WIDTH)) dut (
      .A(A),
      .B(B),
      .product(product)
    );

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        A = 16'd10;
        B = 16'd10;
        #5;
        assert (product == 16'd100)
        else $error("Multiplication Failed");
      	A = -16'sd15;
      	B = 16'd10;
      	#5;
      	assert (product == -16'sd150)
        else $error("2nd Multiplication Failed");
      	A = -16'sd60;
        B = -16'sd60;
        #5;
        assert (product == 16'd3600) 
        else $error("3rd Multiplication Failed");
        A = -16'sd128;
        B = -16'sd128;
        #5;
        assert (product == 16'd16384) 
        else $error("4th Multiplication Failed");

        $finish();

    end
endmodule