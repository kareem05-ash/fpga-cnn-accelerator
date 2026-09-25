package acc_seq_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	import acc_txn_pkg::*;
  import acc_reset_seq_pkg::*;
  import acc_kernel_seq_pkg::*;
  import acc_start_seq_pkg::*;
  import acc_stream_seq_pkg::*;
  import acc_read_seq_pkg::*;
	
	class acc_seq #(N, IN_DEPTH, OUT_DEPTH) extends uvm_sequence #(acc_txn);
		`uvm_object_param_utils(acc_seq #(N, IN_DEPTH, OUT_DEPTH))
		
		function new (string name = "acc_seq");
			super.new(name);
		endfunction
		
		task body();
      acc_reset_seq               reset_seq;
      acc_kernel_seq #(N)         kernel_seq;
      acc_start_seq               start_seq;
      acc_stream_seq #(IN_DEPTH)  stream_seq;
      acc_read_seq   #(OUT_DEPTH) read_seq;

      reset_seq   = acc_reset_seq::type_id::create("reset_seq");
      `uvm_info("MAIN_SEQ", {reset_seq.get_full_name(), ": starts"}, UVM_MEDIUM)
      reset_seq.start(m_sequencer, this);
      `uvm_info("MAIN_SEQ", {reset_seq.get_full_name(), ": completed"}, UVM_MEDIUM)

      kernel_seq  = acc_kernel_seq #(N)::type_id::create("kernel_seq");
      `uvm_info("MAIN_SEQ", {kernel_seq.get_full_name(), ": starts"}, UVM_MEDIUM)
      kernel_seq.start(m_sequencer, this);
      `uvm_info("MAIN_SEQ", {kernel_seq.get_full_name(), ": completed"}, UVM_MEDIUM)

      start_seq   = acc_start_seq::type_id::create("start_seq");
      `uvm_info("MAIN_SEQ", {start_seq.get_full_name(), ": starts"}, UVM_MEDIUM)
      start_seq.start(m_sequencer, this);
      `uvm_info("MAIN_SEQ", {start_seq.get_full_name(), ": completed"}, UVM_MEDIUM)

      stream_seq  = acc_stream_seq #(IN_DEPTH)::type_id::create("stream_seq");
      `uvm_info("MAIN_SEQ", {stream_seq.get_full_name(), ": starts"}, UVM_MEDIUM)
      stream_seq.start(m_sequencer, this);
      `uvm_info("MAIN_SEQ", {stream_seq.get_full_name(), ": completed"}, UVM_MEDIUM)

      read_seq    = acc_read_seq #(OUT_DEPTH)::type_id::create("read_seq");
      `uvm_info("MAIN_SEQ", {read_seq.get_full_name(), ": starts"}, UVM_MEDIUM)
      read_seq.start(m_sequencer, this);
      `uvm_info("MAIN_SEQ", {read_seq.get_full_name(), ": completed"}, UVM_MEDIUM)
		endtask
  endclass
endpackage