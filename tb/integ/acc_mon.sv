package acc_mon_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import acc_cfg_pkg::*;
	import acc_txn_pkg::*;
	
	class acc_mon extends uvm_monitor;
	
		virtual acc_if acc_vif;
		acc_cfg m_cfg;
		uvm_analysis_port #(acc_txn) ap;
	
		`uvm_component_utils(acc_mon)
	
		function new(string name = "acc_mon", uvm_component parent);
			super.new(name , parent);
		endfunction
	
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			ap = new ("ap" , this);
	
			if(!uvm_config_db #(virtual acc_if)::get (this , "" , "vif" , acc_vif))
				`uvm_fatal(get_type_name() , "failed to get the interface in the monitor")
	
			`uvm_info(get_type_name(), "accelerator monitor build phase", UVM_LOW)
		endfunction
	
		task run_phase(uvm_phase phase);
			acc_txn rsp;
			`uvm_info(get_type_name() , "enter the run phase" , UVM_LOW)
			forever 
				begin
					rsp = acc_txn::type_id::create("rsp");
					
					@(m_cfg.read_in_kernel);
					@(negedge acc_vif)
					rsp.output_raddr1 = acc_vif.output_raddr;
					rsp.output_valid = acc_vif.output_valid;
					rsp.output_rdata = acc_vif.output_rdata;
					
					@(m_cfg.busy_state)
					@(negedge acc_vif.clk);
					rsp.busy = acc_vif.busy;
					
					@(m_cfg.read_in_processing);
					@(negedge acc_vif)
					rsp.output_raddr2 = acc_vif.output_raddr;
					rsp.output_valid = acc_vif.output_valid;
					rsp.output_rdata = acc_vif.output_rdata;
					
					@(m_cfg.processing_done);
					@(negedge acc_vif)
					rsp.done = acc_vif.done;
					
					ap.write(rsp);
					`uvm_info(get_type_name() , $sformatf("IN MON : busy = %b , output_valid = %b , output_rdata = %d , done = %d" , rsp.busy , rsp.output_valid , rsp.output_rdata , rsp.done) , UVM_LOW)
				end
		endtask
	endclass

endpackage
