package acc_drv_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	import acc_txn_pkg::*;
	import acc_cfg_pkg::*;
	
	class acc_drv#(parameter int unsigned N           = 5,
					parameter int unsigned IMG_WIDTH  = 32,
					parameter int unsigned IMG_HEIGHT = 32
					) extends uvm_driver #(acc_txn);
		
		`uvm_component_param_utils(acc_drv#(N, IMG_WIDTH, IMG_HEIGHT))
		
		acc_cfg m_cfg;
		virtual acc_if vif;
		
		function new (string name = "drv" , uvm_component parent);
			super.new(name,parent);
		endfunction
		
		function void build_phase (uvm_phase phase);
			super.build_phase(phase);
			`uvm_info(get_type_name(),"acc_drv build phase",UVM_LOW)
			
			if(!uvm_config_db #(virtual acc_if)::get(this,"","vif",vif))
				`uvm_fatal(get_type_name(),"failed to get interface")
		endfunction
		
		task run_phase(uvm_phase phase);
			`uvm_info(get_type_name(),"acc_drv run phase",UVM_LOW)
			forever begin 
				acc_txn txn;
				seq_item_port.get_next_item(txn);
				txn.print();
				
				@(negedge vif.clk);   //----------------------->RST
				vif.rst_n=txn.rst_n;
				
				@(negedge vif.clk);   //----------------------->KERNEL
				for (int i = 0; i < N*N; i++) begin
					repeat (txn.kernel_idle_cycles[i]) begin
						vif.kernel_we = 0;
						@(negedge vif.clk);
					end
					vif.kernel_we    = 1;
					vif.kernel_waddr = i;
					vif.kernel_wdata = txn.kernel_wdata[i];
					if( i == N ) vif.output_raddr = txn.output_raddr1;  //------------->"invalid read address monitor output_valid"
					@(negedge vif.clk);
				end
				vif.kernel_we = 0;
				
				vif.start=txn.start; //---------------------------->START
				
				
				@(negedge vif.clk);  //------------------------------> PROCESSING_EN STATE "monitor busy signal here"
				vif.start=0;
				for (int i = 0; i < IMG_WIDTH*IMG_HEIGHT; i++) begin
					repeat (txn.idle_cycles[i]) begin
						vif.pixel_valid = 0;
						@(negedge vif.clk);
					end
					vif.pixel_dropped=txn.pixel_dropped[i];
					vif.pixel_valid  = 1;
					vif.pixel_in     = txn.pixel_in[i];
					if( i == 0 ) vif.output_raddr = txn.output_raddr2; //------------------->"raddr sent monitor output_rdata and output_valid"
					@(negedge vif.clk);
				end
					vif.pixel_valid = 0;
					
				//--------------------------------------> DONE STATE "monitor done signal here"
				
				seq_item_port.item_done();
			end
		endtask
		
	endclass
	
endpackage