import accelerator_pkg::*;

module global_ctrl(
	input wire logic clk, rst, start, output_done,
	output logic  busy, done, processing_en
	);
	
	state_t cu_state, nx_state;
					
	always@(posedge clk, negedge rst) begin 
		if(!rst) cu_state<=IDLE;
		else cu_state<=nx_state;
	end
	
	always@(*) begin 
		processing_en=0;
		done=0;
		busy=0;
		case(cu_state) 
			IDLE: begin 
				if(start==1) nx_state=PROCESSING;
				else nx_state=IDLE;
			end
			PROCESSING: begin 
				processing_en=1;
				busy=1;
				if(output_done==1) nx_state=DONE;
				else nx_state=PROCESSING;
			end
			DONE: begin 
				done=1;
				nx_state=IDLE;
			end
			default: begin 
				nx_state=cu_state;
			end
		endcase
	end
	
endmodule
