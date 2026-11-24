module tb_mul_top;

    parameter int WIDTH = 8;

    // Control
    logic clk;
    logic rst;
    logic start;
    // Data in
    logic [WIDTH-1:0] multiplicand;
    logic [WIDTH-1:0] multiplier;
    // Data out
    logic [2*WIDTH-1:0] product;
    // Status
    logic done;
    logic busy;

    // Counters
    int n_tests    = 0;
    int p_errors   = 0; // Wrong product
    int lat_errors = 0; // done on the wrong cycle
    int n_printed  = 0;
    localparam int NVALS    = 9;
    localparam int N_RANDOM = (WIDTH <= 32) ? 10000 : 2000;

    logic [WIDTH-1:0] vals [NVALS];

    mul_top #(
        .WIDTH(WIDTH)
    ) dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task automatic do_mul (
        input  logic [WIDTH-1:0] a,
        input  logic [WIDTH-1:0] b,
        output int               latency
    );
        @(posedge clk); #1;
        multiplicand = a;
        multiplier   = b;
        start        = 1;
        @(posedge clk); #1;
        start        = 0;
        multiplicand = ~a; // Inputs must not be read after the start cycle
        multiplier   = ~b;
        latency = 1;
        while (!done && latency < 4*WIDTH+10) begin
            @(posedge clk); #1;
            latency++;
        end
        if (!done) begin
            $error("done still low after timeout, a = %0h, b = %0h", a, b);
            latency = -1;
        end
    endtask

    task automatic check (
        input logic [WIDTH-1:0] a, b
    );
        logic [2*WIDTH-1:0] p_exp;
        int lat;
        bit fail = 0;

        n_tests++;
        do_mul(a, b, lat);
        p_exp = {{WIDTH{1'b0}}, a} * {{WIDTH{1'b0}}, b}; // Reference: full 2*WIDTH-bit product
        if (lat == -1) begin
            lat_errors++;
            return;
        end
        if (product !== p_exp) begin
            p_errors++;
            fail = 1;
        end
        if (lat != WIDTH+1) begin
            lat_errors++;
            fail = 1;
        end
        if (fail && n_printed < 10) begin
            n_printed++;
            $display("a = %h, b = %h, product = %h, exp = %h, lat = %0d", a, b, product, p_exp, lat);
        end
    endtask

    initial begin
        logic [WIDTH-1:0] a, b;
        vals = '{0, 1, 2, 3, (1 << (WIDTH-1)) - 1, (1 << (WIDTH-1)), (1 << (WIDTH-1)) + 1,
                 {WIDTH{1'b1}} - 1, {WIDTH{1'b1}}};
        rst = 1; start = 0; multiplicand = 0; multiplier = 0;
        repeat (2) @(posedge clk); #1;
        rst = 0;

        // Corner pairs
        for (int i = 0; i < NVALS; i++)
            for (int j = 0; j < NVALS; j++)
                check(vals[i], vals[j]);

        // Random pairs
        for (int k = 0; k < N_RANDOM; k++) begin
            a = {$urandom, $urandom, $urandom, $urandom};
            b = {$urandom, $urandom, $urandom, $urandom};
            check(a, b);
        end

        $display("WIDTH = %0d, Tests = %0d, Product errors = %0d, Latency errors = %0d",
                 WIDTH, n_tests, p_errors, lat_errors);
        if (p_errors == 0 && lat_errors == 0) $display("PASS");
        else                                  $display("FAIL");
        $finish;
    end
endmodule
