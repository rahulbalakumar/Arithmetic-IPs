module tb_booth_mul_unsigned;

    parameter int WIDTH = 8;

    logic [WIDTH-1:0]   A;
    logic [WIDTH-1:0]   B;
    logic [2*WIDTH-1:0] product;

    int n_tests   = 0;
    int errors    = 0;
    int n_printed = 0;
    localparam int NVALS    = 9;
    localparam int N_RANDOM = 10000;

    logic [WIDTH-1:0] vals [NVALS];

    booth_mul_unsigned #(
        .WIDTH(WIDTH)
    ) dut (.*);

    // Combinational DUT: apply, let it settle, compare
    task automatic check (
        input logic [WIDTH-1:0] a, b
    );
        logic [2*WIDTH-1:0] p_exp;
        n_tests++;
        A = a;
        B = b;
        #1;
        p_exp = {{WIDTH{1'b0}}, a} * {{WIDTH{1'b0}}, b};
        if (product !== p_exp) begin
            errors++;
            if (n_printed < 10) begin
                n_printed++;
                $display("A = %h, B = %h, product = %h, exp = %h", a, b, product, p_exp);
            end
        end
    endtask

    initial begin
        logic [WIDTH-1:0] a, b;
        vals = '{0, 1, 2, 3, (1 << (WIDTH-1)) - 1, (1 << (WIDTH-1)), (1 << (WIDTH-1)) + 1,
                 {WIDTH{1'b1}} - 1, {WIDTH{1'b1}}};

        // Corner pairs
        for (int i = 0; i < NVALS; i++)
            for (int j = 0; j < NVALS; j++)
                check(vals[i], vals[j]);

        // Exhaustive at 8 bits
        if (WIDTH == 8)
            for (int i = 0; i < 256; i++)
                for (int j = 0; j < 256; j++)
                    check(WIDTH'(i), WIDTH'(j));

        // Random pairs
        for (int k = 0; k < N_RANDOM; k++) begin
            a = {$urandom, $urandom, $urandom, $urandom};
            b = {$urandom, $urandom, $urandom, $urandom};
            check(a, b);
        end

        $display("WIDTH = %0d, Tests = %0d, Errors = %0d", WIDTH, n_tests, errors);
        if (errors == 0) $display("PASS");
        else             $display("FAIL");
        $finish;
    end
endmodule
