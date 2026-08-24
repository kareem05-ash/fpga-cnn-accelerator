`timescale 1ns/1ps
module output_mem_tb;

    parameter int OUT_WIDTH  = 32;
    parameter int OUT_HEIGHT = 32;
    parameter int DATA_W     = 16;
    parameter int DEPTH      = OUT_WIDTH * OUT_HEIGHT;
    parameter int ADDR_W     = $clog2(DEPTH);

    logic                clk_tb;
    logic                output_we_tb;
    logic [DATA_W-1:0]   output_wdata_tb;
    logic [ADDR_W-1:0]   output_addr_tb;
    logic [DATA_W-1:0]   output_rdata_tb;
    logic [DATA_W-1:0]   mem_tb [0:DEPTH-1];   // golden/reference model

    //--------------------------------------------------------------
    // Clock
    //--------------------------------------------------------------
    initial begin
        clk_tb = 0;
        forever #5 clk_tb = ~clk_tb;
    end

    //--------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------
    output_mem #(
        .OUT_WIDTH  (OUT_WIDTH),
        .OUT_HEIGHT (OUT_HEIGHT),
        .DATA_W     (DATA_W)
    ) u_output_mem (
        .clk          (clk_tb),
        .output_we    (output_we_tb),
        .output_wdata (output_wdata_tb),
        .output_addr  (output_addr_tb),
        .output_rdata (output_rdata_tb)
    );

    //--------------------------------------------------------------
    // Tasks
    //--------------------------------------------------------------

    // Drives a synchronous write aligned to the clock (mirrors how the
    // real DUT samples on posedge clk), updates the golden model, and
    // checks that rdata reads 0 while the write is in progress.
    task automatic do_write(input logic [DATA_W-1:0] wdata,
                             input logic [ADDR_W-1:0] waddr);
        @(negedge clk_tb);
        output_we_tb    = 1'b1;
        output_wdata_tb = wdata;
        output_addr_tb  = waddr;
        #1;   // allow the combinational rdata mux to settle
        if (output_rdata_tb == '0)
            $display("PASS: rdata=0 while writing addr=%0d", waddr);
        else
            $display("FAIL: rdata=%0d while writing addr=%0d, expected 0", output_rdata_tb, waddr);

        mem_tb[waddr] = wdata;      // golden model commits on the same edge the DUT will sample
        @(posedge clk_tb);          // this is the edge the DUT actually latches on
    endtask

    // Drops write enable, drives the read address, waits for the
    // combinational output to settle, then checks it against the golden model.
    task automatic check_read(input logic [ADDR_W-1:0] raddr);
        output_we_tb   = 1'b0;
        output_addr_tb = raddr;
        #1;   // allow output_rdata to settle combinationally
        if (output_rdata_tb == mem_tb[raddr])
            $display("PASS: addr=%0d exp=%0d got=%0d", raddr, mem_tb[raddr], output_rdata_tb);
        else
            $display("FAIL: addr=%0d exp=%0d got=%0d", raddr, mem_tb[raddr], output_rdata_tb);
    endtask

    //--------------------------------------------------------------
    // Stimulus
    //--------------------------------------------------------------
    initial begin
        // --- first pass: write 11 locations ---
        do_write(16'b1111_1111_1111_1111, 10'b1111_1111_11);
        do_write(16'b0000_0000_0000_0000, 10'b0000_0000_00);
        do_write(16'b1111_1111_1111_0000, 10'b1111_0000_11);
        do_write(16'b0000_1111_1111_1111, 10'b0000_1111_11);
        do_write(16'b1111_1000_1111_1111, 10'b1111_1001_11);
        do_write(16'b1111_1001_1111_0000, 10'b1100_1111_00);
        do_write(16'b1111_1001_0111_1010, 10'b1011_0111_10);
        do_write(16'b0011_1011_0111_1110, 10'b1001_0101_10);
        do_write(16'b1111_1000_1011_0111, 10'b0000_1011_11);
        do_write(16'b1111_0001_1001_0011, 10'b1001_0111_01);
        do_write(16'b1000_1111_0000_0011, 10'b1001_1001_11);

        // --- read back and verify every address written above ---
        check_read(10'b1111_1111_11);
        check_read(10'b0000_0000_00);
        check_read(10'b1111_0000_11);
        check_read(10'b0000_1111_11);
        check_read(10'b1111_1001_11);   // was missing from the original read-back
        check_read(10'b1100_1111_00);
        check_read(10'b1011_0111_10);
        check_read(10'b1001_0101_10);
        check_read(10'b0000_1011_11);
        check_read(10'b1001_0111_01);
        check_read(10'b1001_1001_11);

        // --- overwrite a subset of the same addresses ---
        do_write(16'b1111_1111_0000_1111, 10'b1111_1111_11);
        do_write(16'b0000_1100_1111_0000, 10'b0000_0000_00);
        do_write(16'b1111_0011_1111_1100, 10'b1111_0000_11);
        do_write(16'b0000_1100_0111_0011, 10'b0000_1111_11);
        do_write(16'b1111_1000_0001_1001, 10'b1111_1001_11);

        // --- verify the overwritten addresses (fixed: this now checks
        //     1111_1001_11, the address actually overwritten above,
        //     instead of the untouched 1100_1111_00 from the original) ---
        check_read(10'b1111_1111_11);
        check_read(10'b0000_0000_00);
        check_read(10'b1111_0000_11);
        check_read(10'b0000_1111_11);
        check_read(10'b1111_1001_11);

        $stop;
    end

endmodule