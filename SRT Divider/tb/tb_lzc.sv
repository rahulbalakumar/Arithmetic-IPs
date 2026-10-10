module tb_lzc;
    parameter int WIDTH = 8;
    logic [WIDTH-1:0] x;
    logic [$clog2(WIDTH)-1:0] count;
    logic zero;

    // Variables
    int n_tests = 0;
    int errors = 0;
    int n_printed = 0;

    lzc #(
        .WIDTH(WIDTH)
    ) dut (.*);

    initial begin 
        check(8'b1000_0000);
        check(8'b0000_1100);
        check(8'b1100_1000);
        check(8'b0000_0111);
        check(8'b0000_0001);
        check(8'b0000_0000);

        for (int p = 0; p < WIDTH; p++) begin
            logic [WIDTH-1:0] v;
            v = '0;
            v[p] = 1'b1;
            check(v);
        end

        for (int k = 0; k < WIDTH; k++) begin
            logic [WIDTH-1:0] v;
            v = '1 >> (WIDTH-1-k);
            check(v);
        end

        if (WIDTH <= 16) begin
            for (int k = 0; k < (1 << WIDTH) - 1; k++) begin
                check(WIDTH'(k));
            end
        end

        for (int j = 0; j < 1000; j++) begin
            logic [WIDTH-1:0] v;
            v = {$urandom, $urandom, $urandom, $urandom} >> ($urandom % WIDTH);
            check(v);
        end

        $display("WIDTH = %0d, Tests = %0d, Errors = %0d", WIDTH, n_tests, errors);

        $finish();
    end

    task automatic check(
        input logic [WIDTH-1:0] v
    );
        int exp_count = 0;
        logic exp_zero = 1'b0;
        bit fail = 0;
        n_tests++;
        x = v;
        #1;
        exp_count = ref_lz(v);
        exp_zero = (v == '0);

        if (zero !== exp_zero) begin
            fail = 1;
        end
        if (v !== '0) begin
            if (count !== exp_count) begin
                fail = 1;
            end
        end
        if (fail) errors++;
        if ((n_printed < 10) && fail) begin
            n_printed++;
            $display("v = %b, count = %0d, exp_count = %0d, zero = %0d, exp_zero = %0d",v,count,exp_count,zero,exp_zero);
        end
    endtask


    function automatic int ref_lz(
        input logic [WIDTH-1:0] v
    );
        for(int i = WIDTH-1; i >= 0; i--) begin
            if (v[i] == 1) return WIDTH-1-i;
        end
        return 0;
    endfunction

endmodule