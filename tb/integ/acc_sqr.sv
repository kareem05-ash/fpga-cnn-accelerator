package acc_sqr_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import acc_txn_pkg::*;

	class acc_sqr extends uvm_sequencer #(acc_txn);

		`uvm_component_utils(acc_sqr)

		function new(string name = "acc_sqr", uvm_component parent);
			super.new(name , parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			`uvm_info(get_type_name(), "accelerator sequencer build phase", UVM_LOW)
		endfunction

	endclass

endpackage