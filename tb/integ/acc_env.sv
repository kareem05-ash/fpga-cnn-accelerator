package acc_env_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_agt_pkg::*;
  import acc_cov_pkg::*;
  import acc_scb_pkg::*;

  class acc_env #(OUT_DEPTH) extends uvm_env;
    `uvm_component_param_utils(acc_env #(OUT_DEPTH))

    acc_agt #(OUT_DEPTH)  agt;
    acc_scb #(OUT_DEPTH)  scb;
    acc_cov               cov;

    function new(string name="acc_env", uvm_component parent);
      super.new(name, parent);
      `uvm_info("NEW", get_full_name(), UVM_FULL)
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", get_full_name(), UVM_FULL)

      agt = acc_agt #(OUT_DEPTH)::type_id::create("agt", this);
      scb = acc_scb #(OUT_DEPTH)::type_id::create("scb", this);
      cov = acc_cov             ::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("CONNECT", get_full_name(), UVM_FULL)

      agt.push_port.connect(cov.push_imp);
      agt.push_port.connect(scb.push_imp);
    endfunction
  endclass //acc_env extends uvm_env

endpackage