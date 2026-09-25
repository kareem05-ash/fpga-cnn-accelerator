package acc_cov_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;

  covergroup cg_accelerator with function sample(acc_txn txn);
    cp_reset: coverpoint txn.rst_n {
      bins active   = {0};
      bins inactive = {1};
    }

    cp_drop:  coverpoint txn.pixel_dropped {
      bins active   = {1};
      bins inactive = {0};
    }

    cp_start: coverpoint txn.start {
      bins active   = {1};
      bins inactive = {0};
    }

    cp_last:  coverpoint txn.pixel_last {
      bins active   = {1};
      bins inactive = {0};
    }

    cp_pixel: coverpoint txn.pixel_in {
      bins allOnes = {8'hFF};
      bins allZeros= {8'h00};
    }

    cp_kernel0: coverpoint txn.kernel_wdata[7] {
      bins negative = {1};
      bins positive = {0};
    }
  endgroup

class acc_cov extends uvm_component;
  `uvm_component_utils(acc_cov)

  cg_accelerator cg;
  uvm_analysis_imp #(acc_txn, acc_cov) push_imp;

  function new(string name="acc_cov", uvm_component parent);
    super.new(name, parent);
    push_imp  = new("cov_push_imp", this);
    cg = new();
    `uvm_info("NEW", get_full_name(), UVM_FULL)
  endfunction //new()

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("BUILD", get_full_name(), UVM_FULL)
  endfunction

  virtual function void write(acc_txn txn);
    cg.sample(txn);
  endfunction
endclass //acc_cov extends uvm_component
endpackage