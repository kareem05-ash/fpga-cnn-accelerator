package acc_kernel_seq_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;

  class acc_kernel_seq #(N) extends uvm_sequence #(acc_txn);
    `uvm_object_param_utils(acc_kernel_seq #(N))

    function new(string name="acc_kernel_seq");
      super.new(name);
    endfunction //new()

    virtual task body();
      acc_txn txn;

      int file_h = $fopen("kernel.txt", "w");
      if (file_h == 0)
        `uvm_fatal("KERNEL_SEQ", "Failed to open kernel.txt for writing!")

      for (int idx=0; idx < N*N; idx++) begin
        txn = acc_txn::type_id::create("kernel_txn");

        start_item(txn);
          if (!txn.randomize() with {
            rst_n           == 1;
            start           == 0;
            pixel_valid     == 0;
            kernel_we       == 1;
            kernel_waddr    == idx;
          })
            `uvm_fatal("KERNEL_SEQ", "Randomization failed")

          `uvm_info("KERNEL_SEQ", txn.sprint(), UVM_HIGH)

          $fwrite(file_h, "%0d\n", txn.kernel_wdata);
            
        finish_item(txn);
      end

      $fclose(file_h);
    endtask
  endclass //acc_kernel_seq extends uvm_sequence #(acc_txn)
endpackage