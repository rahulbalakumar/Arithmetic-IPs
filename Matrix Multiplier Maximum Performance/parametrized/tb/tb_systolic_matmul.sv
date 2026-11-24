module tb_systolic_matmul;

    parameter int N      = 3;
    localparam int DATA_W = 8;
    localparam int ACC_W  = 2*DATA_W + $clog2(N);
    localparam int LAT    = 3*N - 2;
    localparam int N_RANDOM = 500;

    logic clk, rstn, start, busy, done;
    logic [N-1:0][DATA_W-1:0]       row_in, col_in;
    logic [N-1:0][N-1:0][ACC_W-1:0] acc;

    systolic_matmul #(
        .N(N)
    ) dut (.*);

    // Matrices for the current test
    logic [DATA_W-1:0] A [N][N];
    logic [DATA_W-1:0] B [N][N];

    int n_tests = 0, val_errors = 0, lat_errors = 0, hold_errors = 0, n_printed = 0;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reference: C[i][j] = sum_k A[i][k] * B[k][j]
    function automatic logic [ACC_W-1:0] ref_c(input int i, input int j);
        logic [ACC_W-1:0] s = '0;
        for (int k = 0; k < N; k++) s += ACC_W'(A[i][k]) * ACC_W'(B[k][j]);
        return s;
    endfunction

    // Compare every output element with the reference; returns the number of mismatches
    function automatic int compare();
        int bad = 0;
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++)
                if (acc[i][j] !== ref_c(i, j)) begin
                    bad++;
                    if (n_printed < 10) begin
                        n_printed++;
                        $display("C[%0d][%0d] = %0d, expected %0d", i, j, acc[i][j], ref_c(i, j));
                    end
                end
        return bad;
    endfunction

    // Feed A and B (column t of A, row t of B in cycle t), wait for done, check
    task automatic run_test();
        int lat;
        n_tests++;
        for (int t = 0; t < N; t++) begin
            @(posedge clk); #1;
            start = (t == 0);
            for (int i = 0; i < N; i++) row_in[i] = A[i][t];
            for (int j = 0; j < N; j++) col_in[j] = B[t][j];
        end
        // After feeding: drive garbage to prove the inputs are ignored
        @(posedge clk); #1;
        start  = 0;
        row_in = {N{8'hA5}};
        col_in = {N{8'h5A}};
        lat = N;
        while (!done && lat < LAT + 20) begin
            @(posedge clk); #1;
            lat++;
        end
        if (lat != LAT) begin
            lat_errors++;
            if (n_printed < 10) begin n_printed++; $display("latency %0d, expected %0d", lat, LAT); end
        end
        val_errors += compare();
        // Results must hold after done
        repeat (3) @(posedge clk); #1;
        if (compare() != 0) hold_errors++;
    endtask

    initial begin
        rstn = 0; start = 0; row_in = '0; col_in = '0;
        repeat (2) @(posedge clk); #1;
        rstn = 1;

        // 1) A x I = A
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) begin
            A[i][j] = DATA_W'(i*N + j + 1);
            B[i][j] = (i == j) ? 8'd1 : 8'd0;
        end
        run_test();

        // 2) All 255: largest possible entry N*255^2 (accumulator overflow check)
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) begin
            A[i][j] = 8'hFF; B[i][j] = 8'hFF;
        end
        run_test();

        // 3) Zero matrix right after the largest result (accumulators must clear)
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) begin
            A[i][j] = 8'd0; B[i][j] = 8'hFF;
        end
        run_test();

        // 4) Random matrices, back to back without reset
        for (int r = 0; r < N_RANDOM; r++) begin
            for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) begin
                A[i][j] = DATA_W'($urandom);
                B[i][j] = DATA_W'($urandom);
            end
            run_test();
        end

        $display("N = %0d, Tests = %0d, Value errors = %0d, Latency errors = %0d, Hold errors = %0d",
                 N, n_tests, val_errors, lat_errors, hold_errors);
        if (val_errors == 0 && lat_errors == 0 && hold_errors == 0) $display("PASS");
        else                                                         $display("FAIL");
        $finish;
    end
endmodule
