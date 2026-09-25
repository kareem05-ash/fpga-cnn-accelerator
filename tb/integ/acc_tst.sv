package acc_tst_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_seq_pkg::*;
  import acc_env_pkg::*;
  import param_pkg::*;

  class acc_tst extends uvm_test;
    `uvm_component_utils(acc_tst)

    acc_seq #(N, IN_DEPTH, OUT_DEPTH) seq;
    acc_env #(OUT_DEPTH)              env;

    function new(string name="acc_tst", uvm_component parent);
      super.new(name, parent);
      `uvm_info("NEW", get_full_name(), UVM_FULL)
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", get_full_name(), UVM_FULL)

      seq   = acc_seq #(N, IN_DEPTH, OUT_DEPTH) ::type_id::create("seq", this);
      env   = acc_env #(OUT_DEPTH)              ::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
      `uvm_info("RUN", get_full_name(), UVM_LOW)
      phase.raise_objection(this);

        seq.start(env.agt.sqr);
      
      phase.drop_objection(this);
    endtask
  endclass //acc_tst #(N, IN_DEPTH, OUT_DEPT) extends uvm_test
endpackage