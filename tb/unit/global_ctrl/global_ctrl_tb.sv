`timescale 1ns/1ns

module global_ctrl_tb;

import global_ctrl_transaction_pkg ::*;
import accelerator_pkg ::*;
	logic clk_tb;
	logic rst_n_tb;
	logic start_tb;
	logic output_done_tb;
	logic busy_tb;
	logic done_tb;
	logic processing_en_tb;
	
	transaction pkt;
	state_t exp_state;
	logic exp_busy;
	logic exp_done;
	logic exp_processing_en;
	
	global_ctrl DUT
	(
		.clk(clk_tb),
		.rst_n(rst_n_tb),
		.start(start_tb),
		.output_done(output_done_tb),
		.busy(busy_tb),
		.done(done_tb),
		.processing_en(processing_en_tb)
	);
	
	always #5 clk_tb = ~clk_tb;
	
	task automatic gen_stim (ref transaction obj);
		if(!obj.randomize())
			$display("Randomization Failed");
		else
			begin
				obj.cg.sample();
				obj.display_gen();
			end
	endtask
	
	task drive_stim (transaction obj);
		rst_n_tb = obj.rst_n;
		start_tb = obj.start;
		output_done_tb = obj.output_done;
	endtask
	
	task automatic collect_stim (ref transaction obj);
		obj.actual_busy = busy_tb;
		obj.actual_done = done_tb;
		obj.actual_processing_en = processing_en_tb;
	endtask
	
	function automatic void golden_model(transaction obj, ref logic exp_busy, ref logic exp_done, ref logic exp_processing_en);
    		state_t next_state;
    
    		if(!obj.rst_n) 
			begin
        			next_state = IDLE;
    			end
    		else 
			begin
        			case(exp_state)
            			IDLE: next_state = obj.start ? PROCESSING : IDLE;
            			PROCESSING: next_state = obj.output_done ? DONE : PROCESSING;
            			DONE: next_state = IDLE;
            			default: next_state = IDLE;
        			endcase
    			end
    
    		case(next_state)
        	IDLE: begin 
			exp_busy=1'b0; 
			exp_done=1'b0; 
			exp_processing_en=1'b0; 
		     end
        	PROCESSING: begin 
				exp_busy=1'b1; 
				exp_done=1'b0; 
				exp_processing_en=1'b1; 
			    end
        	DONE: begin 
			exp_busy=1'b0; 
			exp_done=1'b1; 
			exp_processing_en=1'b0; 
		      end
        	default: begin 
				exp_busy=1'b0; 
				exp_done=1'b0; 
				exp_processing_en=1'b0; 
			end
    		endcase
    
    		exp_state = next_state;
endfunction

	function void check_result (logic exp_busy , logic exp_done , logic exp_processing_en , transaction obj);
		if(exp_busy == obj.actual_busy)
			$display("[PASS] The Busy is Succesful , exp_busy = %b , actual_busy = %b" , exp_busy , obj.actual_busy);
		else 
			$display("[FAIL] The Busy Has a Problem , exp_busy = %b , actual_busy = %b" , exp_busy , obj.actual_busy);
		
		if(exp_done == obj.actual_done)
			$display("[PASS] The Done is Succesful , exp_done = %b , actual_done = %b" , exp_done , obj.actual_done);
		else 
			$display("[FAIL] The Done Has a Problem , exp_done = %b , actual_done = %b" , exp_done , obj.actual_done);
			
		if(exp_processing_en == obj.actual_processing_en)
			$display("[PASS] The Processing Enable is Succesful , exp_processing_en = %b , actual_processing_en = %b" , exp_processing_en , obj.actual_processing_en);
		else 
			$display("[FAIL] The Processing Enable Has a Problem , exp_processing_en = %b , actual_processing_en = %b" , exp_processing_en , obj.actual_processing_en);
	endfunction

	initial
		begin
			pkt = new();
			exp_state = IDLE;
			clk_tb = 1'b0;
			rst_n_tb = 1'b0;
			start_tb = 1'b0;
			output_done_tb = 1'b0;
			@(negedge clk_tb);
			rst_n_tb = 1'b1;
			
			repeat(100)
				begin
					gen_stim(pkt);
					drive_stim(pkt);
					@(negedge clk_tb);
					collect_stim(pkt);
					golden_model(pkt , exp_busy , exp_done , exp_processing_en);
					check_result(exp_busy , exp_done , exp_processing_en , pkt);
				end
			$display("============ SIMULATION FINISHED ===========");
			@(negedge clk_tb);
			$stop;
		end
endmodule
