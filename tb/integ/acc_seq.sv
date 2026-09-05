package acc_seq_pkg;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	import acc_txn_pkg::*;
	
	
	class acc_seq extends uvm_sequence;
		
		`uvm_object_utils(acc_seq)
		
		function new (string name = "acc_seq");
			super.new(name);
		endfunction
		
		task body();
			acc_txn txn;
			repeat(10) begin 
				txn=acc_txn::type_id::create("txn");
				start_item(txn);
					assert(txn.randomize());
						`uvm_info(get_type_name(),{"data randomized:",txn.sprint()},UVM_LOW);
				finish_item(txn);
			end
		endtask
		
	endclass
	
endpackage