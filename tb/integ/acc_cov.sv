package acc_cov_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import acc_txn_pkg::*;

	class acc_cov extends uvm_component;
	
		`uvm_component_utils(acc_cov)

		uvm_analysis_export #(acc_txn) analysis_export;
		uvm_tlm_analysis_fifo #(acc_txn) fifo;
    
		acc_txn tr;

		covergroup cg;
			cp_reset: coverpoint tr.rst_n {
				bins active = {1'b0};
				bins inactive = {1'b1};
			}
			
			cp_start: coverpoint tr.start {
				bins active = {1'b1};
				bins inactive = {1'b0};
			}
			
			cp_last: coverpoint tr.pixel_last {
				bins active = {1'b1};
				bins inactive = {1'b0};
			}
		endgroup
			
		covergroup cg_drop with function sample (logic pixel_drop_val); 
			cp_drop: coverpoint pixel_drop_val {
				bins active = {1'b1};
				bins inactive = {1'b0};
			}
		endgroup
			
		covergroup cg_pixel with function sample (logic [7:0] pixel_in_val);	
			cp_pixel: coverpoint pixel_in_val {
				bins all_ones = {8'hFF};
				bins all_zeros = {8'h00};
				bins normal = {[8'h1:8'hFE]};
			}
		endgroup
			
		covergroup cg_kernel with function sample (logic signed [7:0] kernel_wdata_val);
			cp_kernel: coverpoint kernel_wdata_val {
				bins positive = {[1 : 127]};
				bins zero = {0};
				bins negative = {[-128 : -1]};
			}
		endgroup

		function new(string name, uvm_component parent);
			super.new(name, parent);
			cg = new();
			cg_drop = new();
			cg_pixel = new();
			cg_kernel = new();
		endfunction
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			analysis_export = new("analysis_export" , this);
			fifo = new("fifo" , this);
			`uvm_info(get_type_name(), "accelerator coverage build phase", UVM_LOW)
		endfunction
		
		function void connect_phase (uvm_phase phase);
			super.connect_phase(phase);
			analysis_export.connect(fifo.analysis_export);
			`uvm_info(get_type_name(), "accelerator coverage connect phase", UVM_LOW)
		endfunction
		
		task run_phase (uvm_phase phase);
			forever
				begin
					fifo.get(tr);
					cg.sample();
					foreach(tr.pixel_dropped[i])
						begin
							cg_drop.sample(tr.pixel_dropped[i]);
							cg_pixel.sample(tr.pixel_in[i]);
						end
					foreach(tr.kernel_wdata[i])
						cg_kernel.sample(tr.kernel_wdata[i]);
				end
		endtask
		
	endclass

endpackage
