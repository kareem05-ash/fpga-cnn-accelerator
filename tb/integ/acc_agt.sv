// package acc_agt_pkg;

// 	import uvm_pkg::*;
// 	`include "uvm_macros.svh"
// 	import acc_drv_pkg::*;
// 	import acc_sqr_pkg::*;
// 	import acc_mon_pkg::*;
	
// 	class acc_agt #(parameter int unsigned N = 5,
//                 	parameter int unsigned IMG_WIDTH = 32,
//                		parameter int unsigned IMG_HEIGHT = 32) extends uvm_agent;
	
// 		acc_drv#(N, IMG_WIDTH, IMG_HEIGHT) drv;
// 		acc_sqr sqr;
// 		acc_mon mon;
	
// 		uvm_active_passive_enum is_active = UVM_ACTIVE;
	
// 		`uvm_component_utils(acc_agt)
	
// 		function new(string name = "acc_agt", uvm_component parent);
// 			super.new(name , parent);
// 		endfunction
	
// 		function void build_phase(uvm_phase phase);
// 			super.build_phase(phase);
// 			mon = acc_mon::type_id::create("mon" , this);
	
// 			if(!uvm_config_db #(uvm_active_passive_enum) ::get (this , "" , "is_active" , is_active))
// 				`uvm_fatal(get_type_name() , "failed to get agent enum value")
	
// 			if(is_active == UVM_ACTIVE)
// 				begin
// 					drv = acc_drv#(N, IMG_WIDTH, IMG_HEIGHT)::type_id::create("drv", this);
// 					sqr = acc_sqr::type_id::create("sqr", this);
// 				end
	
// 			`uvm_info(get_type_name(), "accelerator agent build phase", UVM_LOW)
// 		endfunction
	
// 		function void connect_phase(uvm_phase phase);
// 			super.connect_phase(phase);
// 			if(is_active == UVM_ACTIVE)
// 				drv.seq_item_port.connect(sqr.seq_item_export);
// 		endfunction

//   endclass

// endpackage


package acc_agt_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;
  import acc_mon_pkg::*;
  import acc_drv_pkg::*;
  import acc_sqr_pkg::*;
  import acc_cfg_pkg::*;

  class acc_agt #(OUT_DEPTH) extends uvm_agent;
    `uvm_component_param_utils(acc_agt #(OUT_DEPTH))

    acc_mon #(OUT_DEPTH) mon;
    acc_drv drv;
    acc_sqr sqr;
    acc_cfg m_cfg;
    uvm_analysis_port #(acc_txn) push_port;

    function new(string name="acc_agt", uvm_component parent);
      super.new(name, parent);
      push_port = new("agt_push_port", this);
      `uvm_info("NEW", get_full_name(), UVM_FULL)
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", get_full_name(), UVM_FULL)

      if (!uvm_config_db #(acc_cfg)::get(this, "", "cfg", m_cfg))
        `uvm_fatal(get_type_name(), "Failed to get the common cfg")

      mon = acc_mon #(OUT_DEPTH)::type_id::create("mon", this);
      if (m_cfg.is_active == UVM_ACTIVE) begin
        drv = acc_drv::type_id::create("drv", this);
        sqr = acc_sqr::type_id::create("sqr", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      mon.push_port.connect(this.push_port);
      `uvm_info(get_full_name(), "MON push_port was passed to AGT push_port", UVM_FULL)

      drv.seq_item_port.connect(sqr.seq_item_export);
      `uvm_info(get_full_name(), "DRV seq_item_port was passed to SQR seq_item_export", UVM_FULL)
    endfunction
  endclass //acc_agt extends uvm_agent
endpackage