module tb_div_ctrl;
    import div_pkg::*;

    localparam WIDTH = 8;
    logic clk;
    logic rst;
    logic start;
    logic done;
    logic busy;
    command cmnd;

    div_ctrl #(.WIDTH(WIDTH)) dut (.*);

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        forever #5 clk = ~clk;
    end

    task automatic start_one_division(output int latency);
        int count;
        @(posedge clk);
        #1;
        start = 1;
        @(posedge clk);
        #1;
        start = 0;
        count = 1;
        for (int i = 0; i <= WIDTH+10; i++) begin
            if (done) break;
            @(posedge clk);
            #1;
            count = count + 1;
        end
        if (!done) $error("Division never finished correctly.");
        latency = count;
    endtask

    int lat;

    initial begin
      	$dumpfile("dump.vcd");$dumpvars(0,dut);
      	@(posedge clk);
        #1;
        rst = 0;
        start_one_division(lat);
        $display("latency = %0d", lat);
        repeat (3) @(posedge clk);
        start_one_division(lat);
        $display("latency = %0d", lat);
        repeat (3) @(posedge clk);
        start_one_division(lat);
        $display("latency = %0d", lat);
        repeat (3) @(posedge clk);
        $finish();
    end
    // Assertions

    a_done_one_cycle: assert property (
        @(posedge clk) disable iff (rst)
        done |=> !(done)
    ) else $error("Done was high more than one cycle");

    a_busy_done_exclusive: assert property(
        @(posedge clk) disable iff (rst)
        !(done && busy)
    ) else $error("Busy and Done were high at once");

    a_latency: assert property (
        @(posedge clk) disable iff (rst)
        (start && !done && !busy) |=> ##(WIDTH) done
    ) else $error("Done did not raise within WIDTH + 1 cycles");

    a_load_condition: assert property (
        @(posedge clk) disable iff (rst)
        (cmnd == LOAD_CMD) |-> (start && !(busy))
    ) else $error("LOAD_CMD issued at wrong time");
endmodule