package acc_mon_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;
  import acc_cfg_pkg::*;

  class acc_mon #(OUT_DEPTH) extends uvm_monitor;
    `uvm_component_param_utils(acc_mon #(OUT_DEPTH))

    acc_cfg m_cfg;
    uvm_analysis_port #(acc_txn) push_port;

    function new(string name="acc_mon", uvm_component parent);
      super.new(name, parent);
      push_port = new("mon_push_port", this);
      `uvm_info("NEW", get_full_name(), UVM_FULL)
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", get_full_name(), UVM_FULL)

      if (!uvm_config_db #(acc_cfg)::get(this, "", "cfg", m_cfg))
        `uvm_fatal(get_type_name(), "Failed to get the common cfg")
    endfunction

    virtual function void capture();
      acc_txn txn = acc_txn::type_id::create("mon_txn", this);

      txn.busy          = m_cfg.acc_vif.busy;
      txn.done          = m_cfg.acc_vif.done;
      txn.output_valid  = m_cfg.acc_vif.output_valid;
      txn.output_rdata  = m_cfg.acc_vif.output_rdata;

      push_port.write(txn);
    endfunction

    virtual task save_output();
      int file_h;
      file_h = $fopen("output.txt", "w");
      if (file_h == 0)
        `uvm_fatal(get_type_name(), "Failed to save outputs into output.txt")

      repeat (OUT_DEPTH) begin
        @(negedge m_cfg.acc_vif.clk);
          `uvm_info(
            get_full_name(),
            $sformatf("Before saving %0d output in output.txt", m_cfg.acc_vif.output_rdata),
            UVM_DEBUG)
          $fwrite(file_h, "%0d\n", m_cfg.acc_vif.output_rdata);
          `uvm_info(
            get_full_name(),
            $sformatf("After saving %0d output in output.txt", m_cfg.acc_vif.output_rdata),
            UVM_DEBUG)
          if (!m_cfg.acc_vif.output_valid)
            `uvm_warning(get_full_name(), "Output isn't valid")
		else `uvm_info(get_full_name(), "Output is valid",UVM_DEBUG)
      end
		`uvm_info(get_full_name(), "after repeat",UVM_DEBUG)
      $fclose(file_h);
		`uvm_info(get_full_name(), "file closed",UVM_DEBUG)
    endtask

    virtual task run_phase(uvm_phase phase);
      fork
        forever begin
          @(m_cfg.stimulus_sent_e);
            @(negedge m_cfg.acc_vif.clk);
              `uvm_info(get_full_name(), "Before capturing the outputs", UVM_DEBUG)
              capture();
              `uvm_info(get_full_name(), "After capturing the outputs", UVM_DEBUG)
        end

        begin
          @(m_cfg.read_seq_start_e);
           @(negedge m_cfg.acc_vif.clk);
		   @(negedge m_cfg.acc_vif.clk); //---------try:>
              `uvm_info(get_full_name(), "Before getting into save_output()", UVM_DEBUG)
              save_output();
              `uvm_info(get_full_name(), "After  getting into save_output()", UVM_DEBUG)
              -> m_cfg.read_seq_done_e;
              `uvm_info(get_type_name(), "Outputs saved into output.txt", UVM_FULL)
        end
      join
    endtask
  endclass //acc_mon extends uvm_monitor
endpackage