module kogge_stone_adder #(
    parameter int WIDTH = 256
)(
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] final_product
);


    localparam int LEVELS = $clog2(WIDTH); // ceil of log_2

    logic [WIDTH-1:0] g [LEVELS:0]; // g and p for each levels, each 256 bits wide
    logic [WIDTH-1:0] p [LEVELS:0];
    logic [WIDTH-1:0] carries;


    always_comb begin
        for (int i = 0; i < WIDTH; i++) begin
            g[0][i] = a[i] & b[i];
            p[0][i] = a[i] ^ b[i];
        end
    end

    genvar lvl, i;
    generate
        for (lvl = 0; lvl < LEVELS; lvl++) begin: level_gen
            int dist = 1 << lvl;

            for (i = 0; i < WIDTH; i++) begin: node_gen
                if (i >= dist) begin
                    always_comb begin
                        g[lvl+1][i] = g[lvl][i] | (p[lvl][i] & g[lvl][i - dist]);
                        p[lvl+1][i] = p[lvl][i] & p[lvl][i-dist];
                    end
                end else begin
                    always_comb begin
                        g[lvl+1][i] = g[lvl][i];
                        p[lvl+1][i] = p[lvl][i];
                    end
                end
            end
        end
    endgenerate

    always_comb begin
        carries[0] = 1'b0;
        for (int i = 1; i < WIDTH; i++) begin
            carries[i] = g[LEVELS][i-1];
        end
    end


    always_comb begin
        for (int i = 0; i < WIDTH; i++) begin
            final_product[i] = p[0][i] ^ carries[i];
        end
    end
endmodule
