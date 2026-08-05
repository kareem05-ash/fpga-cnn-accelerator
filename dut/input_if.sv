module input_if(
		input wire logic clk, rst, pixel_valid,processing_en,
		input wire logic [7:0] pixel_in,
		output  logic [7:0] pixel_out,
		output  logic pixel_out_valid);
		
	always@(posedge clk, negedge rst) begin    // LOW ASYNCHRONOUS RST 
		if(!rst) begin 
			pixel_out<=0;
			pixel_out_valid<=0;
		end
		else if (processing_en & pixel_valid) begin   // PASS PIXEL & SEND VALID SIGNAL 
			pixel_out<= pixel_in;
			pixel_out_valid<= 1;
		end
		else begin                         
			pixel_out<=0;
			pixel_out_valid<=0;
		end
	end
	
endmodule