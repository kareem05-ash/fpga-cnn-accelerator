package acc_reset_seq_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;

  class acc_reset_seq extends uvm_sequence #(acc_txn);
    `uvm_object_utils(acc_reset_seq)

    function new(string name="acc_reset_seq");
      super.new(name);
    endfunction //new()

    virtual task body();
      acc_txn txn = acc_txn::type_id::create("reset_seq");
      start_item(txn);

        if (!txn.randomize() with {rst_n == 0;})
          `uvm_fatal("RESET_SEQ", "Randomization Failed")

        `uvm_info("RESET_SEQ", txn.sprint(), UVM_HIGH)
        
      finish_item(txn);
    endtask
  endclass //acc_reset_seq extends uvm_sequence #(acc_txn)
endpackage