package acc_txn_pkg;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	class acc_txn extends uvm_sequence_item;
	
		parameter int unsigned  N               = 5;    // kernel dimension
		parameter int unsigned  PROD_W          = 17;   // product bit width (unsigned 8-bit * signed 8-bit = signed 17-bit)
		parameter int unsigned  IMG_WIDTH       = 32;   // input  image width
		parameter int unsigned  IMG_HEIGHT      = 32;   // input  image height
		parameter int unsigned  OUT_WIDTH       = IMG_WIDTH  - N + 1;   // output image width
		parameter int unsigned  OUT_HEIGHT      = IMG_HEIGHT - N + 1;   // output image heigth
		parameter int unsigned  IN_DEPTH        = IMG_WIDTH * IMG_HEIGHT;
		parameter int unsigned  OUT_DEPTH       = OUT_WIDTH * OUT_HEIGHT;
		parameter int unsigned  ACC_W           = 24;   // accumulated result bit width
		parameter int unsigned  OUT_W           = 16;   // convolution result bit width
		parameter int unsigned  OUT_MEM_ADDR_W  = $clog2(OUT_DEPTH);
		parameter int unsigned  K_MEM_ADDR_W    = $clog2(N*N);
		
		
		rand logic                        rst_n;      // synch active-low reset
		rand logic                        start;      // starting processing command
		
		// source -> accelerator channel  DATAPATH
		logic                       	  pixel_valid;
		rand logic                  	  pixel_last;
		rand logic [OUT_MEM_ADDR_W-1 : 0] output_raddr1;
		rand logic [OUT_MEM_ADDR_W-1 : 0] output_raddr2;
		rand logic [7:0]        		  pixel_in      [0:IN_DEPTH-1];   // real pixel values
		rand logic               		  pixel_dropped [0:IN_DEPTH-1];   // per real pixel
		rand int unsigned        		  idle_cycles   [0:IN_DEPTH-1];   // # of valid=0 cycles BEFORE pixel i
	
		// CFG PATH
		logic                        	  kernel_we;
		logic [K_MEM_ADDR_W-1 : 0]   	  kernel_waddr;
		rand logic signed [7:0]  	 	  kernel_wdata      [0:N*N-1];   // real coefficient values
		rand int unsigned        	 	  kernel_idle_cycles[0:N*N-1];   // # of we=0 cycles BEFORE writing coeff i

	
  //	 Outputs
		// accelerator -> source channel
		logic                        	  busy;       // processing
		logic                        	  done;       // processing is done
		logic                        	  output_valid;
		logic [OUT_W-1 : 0]          	  output_rdata;
		
		constraint idle_cycles_dist {
		foreach(idle_cycles[i])
			idle_cycles[i] dist {0 := 80, 1 := 20};
		}
		
		constraint kernel_idle_cycles_dist {
			foreach(kernel_idle_cycles[i])
				kernel_idle_cycles[i] dist {0 := 80, 1 := 20};
		}
		
		constraint kernel_wdata_dist {
			foreach(kernel_wdata[i])
				kernel_wdata[i] dist {
					[-128:-1] := 30,
					[0:127]   := 70
				};
		}
		
		constraint start_dist {
			start dist {1 := 90, 0 := 10};
		}
		
		constraint rst_n_dist {
			rst_n dist {1 := 90, 0 := 10};
		}
		
		constraint pixel_dropped_dist {
			foreach(pixel_dropped[i])
				pixel_dropped[i] dist {0 := 90, 1 := 10};
		}

		`uvm_object_utils_begin (acc_txn)
			`uvm_field_int		(rst_n,    			UVM_DEFAULT)
			`uvm_field_int		(start,    			UVM_DEFAULT)
			`uvm_field_int		(pixel_valid,     	UVM_DEFAULT)
			`uvm_field_int		(pixel_last,     	UVM_DEFAULT)
			`uvm_field_int		(output_raddr1,   	UVM_DEFAULT)
			`uvm_field_int		(output_raddr2,   	UVM_DEFAULT)
			`uvm_field_array_int(pixel_in,   	 	UVM_DEFAULT)
			`uvm_field_array_int(pixel_dropped,     UVM_DEFAULT)
			`uvm_field_array_int(idle_cycles,       UVM_DEFAULT)
			`uvm_field_int		(kernel_we,     	UVM_DEFAULT)
			`uvm_field_int		(kernel_waddr,      UVM_DEFAULT)
			`uvm_field_array_int(kernel_wdata,      UVM_DEFAULT)
			`uvm_field_array_int(kernel_idle_cycles,UVM_DEFAULT)
			`uvm_field_int		(busy,    			UVM_DEFAULT)
			`uvm_field_int		(done,    			UVM_DEFAULT)
			`uvm_field_int		(output_valid,     	UVM_DEFAULT)
			`uvm_field_int		(output_rdata,     	UVM_DEFAULT)
		`uvm_object_utils_end
		
		function new (string name = "acc_txn");
			super.new(name);
		endfunction
		
	endclass

endpackage