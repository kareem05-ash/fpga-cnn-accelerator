import accelerator_pkg::*;

module global_ctrl(
	input wire logic clk, rst, start, output_done,
	output logic  busy, done, processing_en
	);
	
	state_t cu_state, nx_state;
					
	always@(posedge clk, negedge rst) begin   // REGISTER CU_STATE 
		if(!rst) cu_state<=IDLE;
		else cu_state<=nx_state;
	end
	
	always@(*) begin 
		processing_en=0;        // DEFAULT VALUES  
		done=0;
		busy=0;
		case(cu_state) 
			IDLE: begin                   // STATE_1 WAIT FOR START SIGNAL 
				if(start==1) nx_state=PROCESSING;
				else nx_state=IDLE;
			end
			PROCESSING: begin            // STATE_2 EN_PROCESSING AND BUSY  WAIT FOR DONE SIGNAL
				processing_en=1;
				busy=1;
				if(output_done==1) nx_state=DONE;
				else nx_state=PROCESSING;
			end
			DONE: begin                 // STATE_3 SEND DONE SIGNAL 
				done=1;
				nx_state=IDLE;
			end
			default: begin             // DEFAULT RETURN TO IDLE 
				nx_state=IDLE;
			end
		endcase
	end
	
endmodule
