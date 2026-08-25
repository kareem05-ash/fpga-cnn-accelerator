module kernel_mem_tb;

	parameter int unsigned N = 3;
    parameter int unsigned DEPTH = N*N;
    parameter int unsigned KERNEL_MEM_W = $clog2(DEPTH);

    logic                        clk;
    logic                        processing_en;
    logic                        kernel_we;
    logic [KERNEL_MEM_W-1 : 0]   kernel_waddr;
    logic signed [7:0]           kernel_wdata;
    logic signed [7:0]           kernel_coeff [DEPTH];
	
	kernel_mem #(.N(N), .DEPTH(DEPTH), .KERNEL_MEM_W(KERNEL_MEM_W)) DUT (.*);
	
	logic signed [7:0]           exp_kernel_coeff [DEPTH];
	
	
	initial begin 
		clk=0;
		forever #5 clk=~clk;
	end
	
	task generate_stim;
		@(negedge clk);
		processing_en=$random;
		kernel_we=$random;
		kernel_waddr=$random;
		kernel_wdata=$random;
	endtask
	
	task golden_model;
		@(negedge clk);
		if(!processing_en & kernel_we & kernel_waddr < DEPTH)
			exp_kernel_coeff [kernel_waddr]=kernel_wdata;
	endtask
	
	task check;
		if(exp_kernel_coeff===kernel_coeff)
			$display("test passed");
		else $display("test failed");
		$display("Time=%0t | processing_en=%d kernel_we=%d kernel_waddr=%d kernel_wdata=%d",$time,processing_en,kernel_we,kernel_waddr,kernel_wdata);
		$display("exp_kernel_coeff=%p kernel_coeff=%p\n",exp_kernel_coeff,kernel_coeff);
	endtask
	
	initial begin 
		processing_en=0;
		kernel_we=0;
		kernel_waddr=0;
		kernel_wdata=0;
		
		#25;
		
		repeat(40) begin 
			generate_stim();
			golden_model();
			check();
		end
		$stop;
	end
	
endmodule