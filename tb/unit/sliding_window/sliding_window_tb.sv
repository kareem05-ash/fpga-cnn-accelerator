module sliding_window_tb;

	parameter   int unsigned N = 3;
    parameter   int unsigned IMG_WIDTH;

	logic 		clk;
	logic 		rst_n;
	logic 		pixel_valid;
	logic 		pixel_last;
	logic [7:0] pixel_in;
	logic 		window_valid;
	logic 		window_last;
	logic [7:0] window [N*N];

	sliding_window #(.N(N),.IMG_WIDTH(IMG_WIDTH))DUT(.*);
	
	logic 		exp_window_valid;
	logic 		exp_window_last;
	logic [7:0] exp_window[N*N];
	logic [7:0] image [IMG_WIDTH*IMG_WIDTH];
	int 		counter;
	int			num_passed;
	int			num_failed;
	int			test_case;
	int row, col;
	
	assign	row = (counter) / IMG_WIDTH;   
	assign	col = (counter) % IMG_WIDTH;
	
	initial begin 
		clk=0;
		forever #5 clk=~clk;
	end
	
	task generate_stimulus;
		foreach(image[i]) image[i]=0;
		@(posedge clk);
		rst_n=$random;
		pixel_valid=$random;
		pixel_in=$random;
		pixel_last=0;
		counter=0;
	endtask
	
	task collect_output_check;
		if(rst_n) begin
			while (counter!=IMG_WIDTH*IMG_WIDTH) begin 
				while(counter<((N-1)*IMG_WIDTH+(N-1))) begin
					if(pixel_valid) begin 
						image[counter]=pixel_in;
						counter++;
					end
					@(posedge clk);
					pixel_valid=$random;
					pixel_in=$random;
				end
				
				if(col<N-1) begin
					if(pixel_valid) begin 
						image[counter]=pixel_in;
						counter++;
					end
					@(posedge clk);
					pixel_valid=$random;
					pixel_in=$random;
					
				end
				else begin 
					if(pixel_valid) begin 
						if(counter==IMG_WIDTH*IMG_WIDTH-1) begin
							pixel_last=1;
						end
						else 
							pixel_last=0;
						image[counter]=pixel_in;
						golden_model();
						rst_n=$random;          //------------------------------------------------mid rst test
						if(!rst_n) counter=IMG_WIDTH*IMG_WIDTH-1;
						counter++;
					end
					@(posedge clk);
					pixel_valid=$random;
					pixel_in=$random;
				end
			end
			counter=0;
		end
		else begin 
			golden_model();
		end
	endtask
	
	task golden_model;
	 @(negedge clk);
	 if(rst_n) begin 
		for (int i = 0; i < N; i++)
			for (int j = 0; j < N; j++)
				exp_window[i*N + j] = image[(row - N + 1 + i)*IMG_WIDTH + (col - N + 1 + j)];
					
		exp_window_valid=1;
		if(col==IMG_WIDTH-1 & row==IMG_WIDTH-1) begin 
			exp_window_last=1;
		end
		else 
			exp_window_last=0;
	 end
	 else begin 
		exp_window_valid=0;
 		exp_window_last=0;
		for(int i=0;i<N*N;i++)
			exp_window[i]=0;
	 end
	 
	 check_result();
	endtask
					
	task check_result;
	 if(rst_n) begin 
		if(exp_window_valid==window_valid &&
			exp_window_last==window_last &&
			exp_window==window
			) begin 
			$display("test passed");
			num_passed++;
		end 
		else begin 
			$display("teat failed");
			num_failed++;
		end
	end
	 else begin 
		$display("test rst");
		if(exp_window_valid==window_valid &&
			exp_window_last==window_last
			) begin 
			$display("test passed");
			num_passed++;
		end 
		else begin 
			$display("teat failed");
			num_failed++;
		end
	 end
	 
		$display("Time=%0t | exp_window_valid=%d window_valid=%d | exp_window_last=%d window_last=%d | exp_window=%p window=%p\n",
					$time,exp_window_valid, window_valid, exp_window_last, window_last, exp_window, window);			
	endtask
					
	
	initial begin 
		rst_n=0;
		pixel_valid=0;
		pixel_last=0;
		pixel_in=0;
		
		#25;
		
		repeat(80) begin 
			$display("***************************test case %d***********************************",test_case);
			generate_stimulus();
			collect_output_check();
			$display("image=%p",image);
			test_case++;
			@(posedge clk);
			@(posedge clk);
		end
		
		$display("******************************************************************************");
		$display("	TOTAL PASSED=%d		TOTAL FAILED=%d		",num_passed, num_failed);
		$display("******************************************************************************\n");
		
		$stop;
	end
	
endmodule



	
					