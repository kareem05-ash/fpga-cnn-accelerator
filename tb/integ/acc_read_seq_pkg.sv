package acc_read_seq_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;
  import acc_cfg_pkg::*;

  class acc_read_seq #(OUT_DEPTH) extends uvm_sequence #(acc_txn);
    `uvm_object_param_utils(acc_read_seq #(OUT_DEPTH))


    function new(string name="acc_read_seq");
      super.new(name);
    endfunction //new()

    virtual task body();
      acc_txn txn;
      acc_cfg m_cfg;

      if (!uvm_config_db #(acc_cfg)::get(get_sequencer(), "", "cfg", m_cfg))
        `uvm_fatal("READ_SEQ", "Failed to get the common cfg")

      // repeat (5) begin
      //   `uvm_info(get_full_name(), "IDLE cycles to catch dut latency", UVM_FULL)
      //   txn = acc_txn::type_id::create("output_txn");
      //   start_item(txn);
      //     if (!txn.randomize() with {
      //       rst_n           == 1;
      //       start           == 0;
      //       pixel_valid     == 0;
      //     })
      //   finish_item(txn);
      // end
      -> m_cfg.read_seq_start_e;
		
      for (int idx=0; idx <= OUT_DEPTH+1; idx++) begin
        txn = acc_txn::type_id::create("output_txn");

        start_item(txn);
        
          if (!txn.randomize() with {
            rst_n           == 1;
            start           == 0;
            pixel_valid     == 0;
            output_raddr    == idx;
          })
            `uvm_fatal("READ_SEQ", "Randomization failed")

          `uvm_info("READ_SEQ", {
            $sformatf("Seq %0d of %0d\n", idx+1, OUT_DEPTH),
            txn.sprint()
          }, UVM_HIGH)
            
        finish_item(txn);
      end
    endtask
  endclass //acc_read_seq extends uvm_sequence #(acc_txn)
endpackage