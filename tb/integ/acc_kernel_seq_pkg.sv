package acc_kernel_seq_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;

  class acc_kernel_seq #(N=3) extends uvm_sequence #(acc_txn);
    `uvm_object_utils(acc_kernel_seq)

    function new(string name="acc_kernel_seq");
      super.new(name);
    endfunction //new()

    virtual task body();
      acc_txn txn;

      for (int idx=0; idx < N*N; idx++) begin
        txn = acc_txn::type_id::create("kernel_txn");

        start_item(txn);
          if (!txn.randomize() with {
            rst_n           == 1;
            start           == 0;
            kernel_we       == 1;
            kernel_waddr    == idx;
          })
            `uvm_fatal("KERNEL_SEQ", "Randomization failed")
            
        finish_item(txn);
      end
    endtask
  endclass //acc_kernel_seq extends uvm_sequence #(acc_txn)
endpackage