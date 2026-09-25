package acc_start_seq_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;

  class acc_start_seq extends uvm_sequence #(acc_txn);
    `uvm_object_utils(acc_start_seq)

    function new(string name="acc_start_seq");
      super.new(name);
    endfunction //new()

    virtual task body();
      for (int i = 1; i < 2; i++) begin
        acc_txn txn = acc_txn::type_id::create("reset_seq");

        start_item(txn);

          if (!txn.randomize() with {start == i; kernel_we == 0; pixel_valid == 0;})
            `uvm_fatal("START_SEQ", "Randomization Failed")

          `uvm_info("START_SEQ", txn.sprint(), UVM_HIGH)

        finish_item(txn);
      end
    endtask
  endclass //acc_start_seq extends uvm_sequence #(acc_txn)
endpackage