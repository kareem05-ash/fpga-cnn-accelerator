`timescale 1ns/1ps

module output_ctrl #(
    // Parameters
        parameter int N             = 3,
        parameter int IMG_WIDTH     = 32,
        parameter int IMG_HEIGHT    = 32,
        parameter int OUT_WIDTH     = IMG_WIDTH  - N + 1,
        parameter int OUT_HEIGHT    = IMG_HEIGHT - N + 1,
        parameter int ADDR_W        = $clog2(OUT_WIDTH * OUT_HEIGHT)
)();

    logic                clk_tb;
    logic                rst_n_tb;
    logic                fmt_valid_tb;
    logic                fmt_last_tb;
    logic [ADDR_W-1 : 0] out_waddr_tb;
    logic                out_we_tb;
    logic                done_tb;

initial begin
    rst_n_tb = 1;
    fmt_valid_tb = 0;
    fmt_last_tb = 0;
    #1;
    @(posedge clk_tb);

    rst_n_tb = 0;
    #1;
    @(posedge clk_tb);

    rst_n_tb = 1;
    #1;

    @(posedge clk_tb);
    #2;
    if(out_waddr_tb == 0)
        $display("pass: the rst works good and the counter = %d", out_waddr_tb);
    else
        $display("fail: the rst works wrong and the counter = %d", out_waddr_tb);

    if(out_we_tb == 0)
        $display("pass: the output write enable = %d", out_we_tb);
    else
        $display("fail: the output write enable = %d", out_we_tb);

    fmt_valid_tb = 1;
    #1;
    @(posedge clk_tb);
    #2;
        if(out_waddr_tb == 1)
            $display("pass: the counter works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the counter works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 1)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);

    repeat (5) @(posedge clk_tb);
    #2;
        if(out_waddr_tb == 6)
            $display("pass: the counter works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the counter works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 1)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);

    repeat(10) @(posedge clk_tb);
    #2;
        if(out_waddr_tb == 16)
            $display("pass: the counter works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the counter works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 1)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);

    fmt_valid_tb = 0;
    #1;
    @(posedge clk_tb);
    #2;
        if(out_waddr_tb == 16)
            $display("pass: the counter works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the counter works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 0)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);


    fmt_last_tb = 1;
    fmt_valid_tb = 1;
    @(posedge clk_tb);
    #2;
        if(out_waddr_tb == 17)
            $display("pass: the counter works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the counter works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 1)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);

        if(done_tb == 1)
            $display("pass: the done signal = %d", out_we_tb);
        else
            $display("fail: the done signal = %d", out_we_tb);

    fmt_last_tb = 0;
    fmt_valid_tb = 0;
    #1;
    @(posedge clk_tb);
    #2;
    if(out_waddr_tb == 17)
            $display("pass: the counter works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the counter works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 0)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);

        if(done_tb == 0)
            $display("pass: the done signal = %d", out_we_tb);
        else
            $display("fail: the done signal = %d", out_we_tb);

    rst_n_tb = 0;
    #1;
    @(posedge clk_tb);
    #2;
        if(out_waddr_tb == 0)
            $display("pass: the rst works good and the counter = %d", out_waddr_tb);
        else
            $display("fail: the rst works wrong and the counter = %d", out_waddr_tb);

        if(out_we_tb == 0)
            $display("pass: the output write enable = %d", out_we_tb);
        else
            $display("fail: the output write enable = %d", out_we_tb);

    $stop;

end



initial begin
    clk_tb = 0;
    forever #5 clk_tb = ~ clk_tb;
end



output_ctrl #(
    .N          	(3   ),
    .IMG_WIDTH  	(32  ),
    .IMG_HEIGHT 	(32  )
)
u_output_ctrl(
    .clk       	(clk_tb        ),
    .rst_n     	(rst_n_tb      ),
    .fmt_valid 	(fmt_valid_tb  ),
    .fmt_last  	(fmt_last_tb   ),
    .out_waddr 	(out_waddr_tb  ),
    .out_we    	(out_we_tb     ),
    .done      	(done_tb       )
);




endmodule