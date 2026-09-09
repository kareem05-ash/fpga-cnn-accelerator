package acc_cfg_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	
	class acc_cfg extends uvm_object;
		`uvm_object_utils(acc_cfg)

		virtual acc_if acc_vif;

		// uvm_active_passive_enum  is_active;
    
		// event read_in_kernel;
		// event busy_state;
		// event read_in_processing;
		// event processing_done;

    event stimulus_sent_e;
    event read_seq_start_e;
		
		function new (string name = "acc_cfg");
			super.new(name);
		endfunction
	endclass
endpackage