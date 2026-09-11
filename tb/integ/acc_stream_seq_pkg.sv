package acc_stream_seq_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;

  class acc_stream_seq #(IN_DEPTH=32*32) extends uvm_sequence #(acc_txn);
    `uvm_object_param_utils(acc_stream_seq #(IN_DEPTH))

    function new(string name="acc_stream_seq");
      super.new(name);
    endfunction //new()

    virtual task body();
      int unsigned pixel_idx = 0;
      acc_txn txn;
      int file_h;
      file_h = $fopen("input.txt", "w");
      if (file_h == 0)
        `uvm_fatal("STREAM_SEQ", "Failed to open input.txt file")

      while (pixel_idx < IN_DEPTH) begin
        txn = acc_txn::type_id::create("stream_seq");

        start_item(txn);

          if (pixel_idx == IN_DEPTH - 1) begin

            if (!txn.randomize() with {
              rst_n     == 1;
              kernel_we == 0;
              pixel_last== 1;
              start     == 0;
              pixel_dropped==0;
            })
              `uvm_fatal("STREAM_SEQ", "Randomization Failed")

          end else begin

            if (!txn.randomize() with {
              rst_n     == 1;
              kernel_we == 0;
              pixel_last== 0;
              start     == 0;
              pixel_dropped==0;
            })
              `uvm_fatal("STREAM_SEQ", "Randomization Failed")

          end

          `uvm_info("STREAM_SEQ", txn.sprint(), UVM_HIGH)

          if (txn.pixel_valid) begin
            pixel_idx++;
            $fwrite(file_h, "%0d\n", txn.pixel_in);
          end

        finish_item(txn);
      end

      $fclose(file_h);
    endtask
  endclass //acc_stream_seq extends uvm_sequence #(acc_txn)
endpackage