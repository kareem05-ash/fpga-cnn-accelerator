package acc_drv_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;
  import acc_cfg_pkg::*;

  class acc_drv extends uvm_driver #(acc_txn);
    `uvm_component_utils(acc_drv)

    acc_cfg m_cfg;

    function new(string name="acc_drv", uvm_component parent);
      super.new(name, parent);
      `uvm_info("NEW", get_full_name(), UVM_FULL)
    endfunction //new()

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", get_full_name(), UVM_FULL)

      if (!uvm_config_db #(acc_cfg)::get(this, "", "cfg", m_cfg))
        `uvm_fatal(get_type_name(), "Failed to get the common cfg")
    endfunction

    virtual function void drive(acc_txn txn);
      m_cfg.acc_vif.rst_n           = txn.rst_n;
      m_cfg.acc_vif.start           = txn.start;

      m_cfg.acc_vif.pixel_valid     = txn.pixel_valid;
      m_cfg.acc_vif.pixel_dropped   = txn.pixel_dropped;
      m_cfg.acc_vif.pixel_last      = txn.pixel_last;
      m_cfg.acc_vif.output_raddr    = txn.output_raddr;
      m_cfg.acc_vif.pixel_in        = txn.pixel_in;

      m_cfg.acc_vif.kernel_we       = txn.kernel_we;
      m_cfg.acc_vif.kernel_waddr    = txn.kernel_waddr;
      m_cfg.acc_vif.kernel_wdata    = txn.kernel_wdata;
      `uvm_info(get_full_name(), "Inside drive function before stimulus_sent_e", UVM_DEBUG)

      -> m_cfg.stimulus_sent_e;
      `uvm_info(get_full_name(), "Inside drive function after stimulus_sent_e", UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      forever begin
        acc_txn txn;
        `uvm_info(get_full_name(), "Before getting the next item", UVM_DEBUG)
        seq_item_port.get_next_item(txn);
        `uvm_info(get_full_name(), "After getting the next item", UVM_DEBUG)

        `uvm_info(get_full_name(), "Waiting for the next negative clock edge", UVM_DEBUG)

          @(negedge m_cfg.acc_vif.clk);
            `uvm_info(get_full_name(), "Driving packet", UVM_FULL)
            drive(txn);
        `uvm_info(get_full_name(), "Before item_done", UVM_DEBUG)
        seq_item_port.item_done();
        `uvm_info(get_full_name(), "After item_done", UVM_DEBUG)
      end
    endtask
  endclass //acc_drv extends uvm_driver #(acc_txn)
endpackage