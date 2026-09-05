
`timescale 1ns/1ps

module acc_tb;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int unsigned N          = 5;
    localparam int unsigned IMG_WIDTH  = 32;
    localparam int unsigned IMG_HEIGHT = 32;
    localparam int unsigned OUT_W      = 16;

    logic clk;
    logic rst_n;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;
    end

    acc_if #(
        .N         (N),
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .OUT_W     (OUT_W)
    ) vif (
        .clk  (clk),
        .rst_n(rst_n)
    );

    accelerator_top #(
        .N         (N),
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .OUT_W     (OUT_W)
    ) dut (
        .clk          (vif.clk),
        .rst_n        (vif.rst_n),
        .start        (vif.start),
        .pixel_valid  (vif.pixel_valid),
        .pixel_dropped(vif.pixel_dropped),
        .pixel_last   (vif.pixel_last),
        .output_raddr (vif.output_raddr),
        .pixel_in     (vif.pixel_in),
        .kernel_we    (vif.kernel_we),
        .kernel_waddr (vif.kernel_waddr),
        .kernel_wdata (vif.kernel_wdata),
        .busy         (vif.busy),
        .done         (vif.done),
        .output_valid (vif.output_valid),
        .output_rdata (vif.output_rdata)
    );

    initial begin
        uvm_config_db#(virtual acc_if)::set(null, "*", "vif", vif);
        run_test();
    end

endmodule : acc_tb
