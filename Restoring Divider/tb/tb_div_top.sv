module tb_div_top;

    parameter int WIDTH = 8;

    // Control
    logic clk;
    logic rst;
    logic start;
    // Data in
    logic [WIDTH-1:0] dividend;
    logic [WIDTH-1:0] divisor;
    // Data out
    logic [WIDTH-1:0] quotient;
    logic [WIDTH-1:0] remainder;
    // Status
    logic done;
    logic busy;
    logic div_by_zero;

    // Variables
    int n_tests = 0; // Number of runs
    int q_errors = 0; // Errors from wrong quotient
    int r_errors = 0; // Errors from wrong remainder
    int dz_errors = 0; // Errors from wrong div_by_zero flag
    int lat_errors = 0; // Errors from done arriving on the wrong cycle
    int n_printed = 0;
    localparam int NVALS = 9;
    localparam int N_RANDOM = (WIDTH <= 32) ? 10000 : 2000;


    logic [WIDTH-1:0] vals [NVALS];

    div_top #(
        .WIDTH(WIDTH)
    ) dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        vals = '{0,1,2,3,(1 << (WIDTH-1))-1, (1 << (WIDTH-1)), (1 << (WIDTH-1))+1, {WIDTH{1'b1}}-1, {WIDTH{1'b1}}};
    end

    initial begin
        logic [WIDTH-1:0] a, b;
        rst = 1;
        start = 0;
        dividend = 0;
        divisor = 0;
        repeat(2) @(posedge clk);
        #1;
        rst = 0;
        for (int i = 0; i < NVALS; i++)
            for (int j = 0; j < NVALS; j++)
                check(vals[i], vals[j]);

        for (int j = 0; j < N_RANDOM; j++) begin
            a = {$urandom,$urandom,$urandom,$urandom};
            b = {$urandom,$urandom,$urandom,$urandom};
            b = b >> ($urandom % WIDTH);
            check(a,b);
        end

        $display("WIDTH = %0d, Tests = %0d, Q errors = %0d, R errors = %0d, Latency Errors = %0d, Divzero Errors = %0d", WIDTH, n_tests, q_errors, r_errors, lat_errors, dz_errors);
        if ((q_errors == 0) && (r_errors == 0) && (lat_errors == 0) && (dz_errors == 0)) begin
            $display("PASS");
            $finish();
        end else begin
            $display("FAIL");
            $finish();
        end
    end

    function automatic void ref_div (
        input logic [WIDTH-1:0] a,
        input logic [WIDTH-1:0] b,
        output logic [WIDTH-1:0] q,
        output logic [WIDTH-1:0] r,
        output logic dz
    );
        if (b == 0) begin
            q = '1;
            r = a;
            dz = 1;
        end else begin
            q = a / b;
            r = a % b;
            dz = 0;
        end
    endfunction

    task automatic do_div (
        input logic [WIDTH-1:0] a,
        input logic [WIDTH-1:0] b,
        output int latency
    );
        @(posedge clk);
        #1;
        dividend = a; 
        divisor = b;
        start = 1;
        @(posedge clk);
        #1;
        start = 0;
        dividend = ~a; // Changes to dividend and divisor won't be reflected during division 
        divisor = ~b;
        latency = 1;
        while ((!done) && latency < 4*WIDTH+10) begin
            @(posedge clk);
            #1;
            latency++;
        end
        if (!done) begin
            $error("done still low after timeout, a = %0d, b = %0d",a , b);
            latency = -1;
        end
    endtask

    task automatic check(
        input logic [WIDTH-1:0] a, b
    );
        logic [WIDTH-1:0] q_exp, r_exp; // Expected quotient / remainder
        logic dz_exp; // expected div by zero flag
        int lat;
        bit fail = 0;

        n_tests++;
        do_div(a,b,lat);
        ref_div(a,b,q_exp,r_exp,dz_exp);
        if (lat == -1) begin
            lat_errors++;
            return;
        end
        if (quotient !== q_exp) begin
            q_errors++;
            fail = 1;
        end
        if (remainder !== r_exp) begin
            r_errors++;
            fail = 1;
        end
        if (div_by_zero !== dz_exp) begin 
            dz_errors++;
            fail = 1;
        end
        if (lat !== WIDTH+1) begin 
            lat_errors++;
            fail = 1;
        end
        if (fail && n_printed < 10) begin
            n_printed++;
            $display("a = %0d, b = %0d, quotient = %h, remainder = %h, div_by_zero = %0d, lat = %0d, exp_q = %h, exp_r = %h, exp_dz = %0d",a, b, quotient, remainder, div_by_zero, lat, q_exp, r_exp, dz_exp);
        end

    endtask

endmodule