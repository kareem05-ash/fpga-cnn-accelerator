
`timescale 1ns/1ps

module acc_tb;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import acc_pkg::*;
    import acc_cfg_pkg::*;
    import param_pkg::*;

    logic clk;
    acc_cfg m_cfg;

    // localparam int unsigned N          = 3;
    // localparam int unsigned IMG_WIDTH  = 5;
    // localparam int unsigned IMG_HEIGHT = 5;
    // localparam int unsigned OUT_W      = 16;

    acc_if #(
        .N         (N),
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .OUT_W     (OUT_W)
    ) vif (
      .clk(clk)
    );

    accelerator_top #(
        .N         (N),
        .PROD_W    (PROD_W),
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .ACC_W     (ACC_W),
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

    initial clk = 1'b0;
    always #5ns clk = ~clk;

    initial begin
      m_cfg = acc_cfg::type_id::create("cfg", null);

      // `IS_ACTIVE is a macro should be defined in the do file
      m_cfg.is_active = `IS_ACTIVE? UVM_ACTIVE : UVM_PASSIVE;
      m_cfg.n         = N;
      m_cfg.img_w     = IMG_WIDTH;
      m_cfg.img_h     = IMG_HEIGHT;
      m_cfg.acc_vif   = vif;

      uvm_config_db #(acc_cfg)::set(null, "*", "cfg", m_cfg);
      run_test("acc_tst");
    end

endmodule : acc_tb
