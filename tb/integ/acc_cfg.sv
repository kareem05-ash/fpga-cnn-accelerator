package acc_cfg_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
  import param_pkg::*;
	
	class acc_cfg extends uvm_object;
		`uvm_object_utils(acc_cfg)

    event stimulus_sent_e;
    event read_seq_start_e;
    event read_seq_done_e;
    int n;
    int img_w;
    int img_h;
		virtual acc_if  #(
      .N(N),
      .IMG_WIDTH(IMG_WIDTH),
      .IMG_HEIGHT(IMG_HEIGHT),
      .OUT_W(OUT_W)
    ) acc_vif;
		uvm_active_passive_enum  is_active;
		
		function new (string name = "acc_cfg");
			super.new(name);
		endfunction
	endclass
endpackage