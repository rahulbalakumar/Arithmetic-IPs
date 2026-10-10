module tb_div_datapath;
    import div_pkg::*;

    localparam WIDTH = 8;
    localparam int NVALS = 9;

    logic [WIDTH-1:0] vals [NVALS];

    logic clk, rst;
    command cmnd;

    logic [WIDTH-1:0] divisor, dividend;
    logic [WIDTH-1:0] quotient, remainder;
    logic div_by_zero;

    div_datapath #(.WIDTH(WIDTH)) dut (.*);
    int errors = 0;

    initial begin
        clk = 0;
        rst = 1;
        divisor = '0;
        dividend = '0;
        cmnd = HOLD_CMD;
        forever #5 clk = ~clk;
    end

    function automatic void ref_div(
        input logic [WIDTH-1:0] a, b,
        output logic [WIDTH-1:0] q, r
    );
        if (b == 0) begin
            q = {WIDTH{1'b1}};
            r = a;
        end else begin
            q = a / b;
            r = a % b;
        end
    endfunction

    task automatic do_division(
        input logic [WIDTH-1:0] a, b,
        output logic [WIDTH-1:0] q, r
    );
        dividend = a;
        divisor = b;
        @(posedge clk);
        #1;
        cmnd = LOAD_CMD;
        @(posedge clk);
        #1;
        cmnd = RUN_CMD;
        repeat (WIDTH) @(posedge clk);
        #1;
        cmnd = HOLD_CMD;
        q = quotient;
        r = remainder;
    endtask

    task automatic check(input logic [WIDTH-1:0] a, b);
        logic [WIDTH-1:0] q_dut, r_dut, q_ref, r_ref;
        do_division(a,b,q_dut,r_dut);
        ref_div(a,b,q_ref,r_ref);

        if (q_ref != q_dut) begin 
            errors++;
            $display("Q reference not equal to Q dut, Q_dut = %0d, Q_ref = %0d", q_dut, q_ref);
        end

        if (r_ref != r_dut) begin 
            $display("R reference not equal to R dut, R_dut = %0d, R_ref = %0d", r_dut, r_ref);
        end
    endtask
    initial begin
        vals = '{0,1,2,3,(1 << (WIDTH-1))-1, (1 << (WIDTH-1)), (1 << (WIDTH-1))+1, {WIDTH{1'b1}}-1, {WIDTH{1'b1}}};
    end
    initial begin
        @(posedge clk);
        #1;
        rst = 0;

        for (int i = 0; i < 9; i++)
            for (int j = 0; j < 9; j++)
                check(vals[i], vals[j]);

        $display("Done. errors = %0d", errors);
        $finish();
    end
endmodule