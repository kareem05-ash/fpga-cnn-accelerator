package acc_cfg_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	class acc_cfg extends uvm_object;
		
		`uvm_object_utils(acc_cfg)
		
		uvm_active_passive_enum  is_active;
		event read_in_kernel;
		event busy_state;
		event read_in_processing;
		event processing_done;
		
		function new (string name = "acc_cfg");
			super.new(name);
		endfunction
		
	endclass
	
endpackage