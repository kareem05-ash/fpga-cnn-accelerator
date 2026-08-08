module input_if(
		input  logic clk,
		input  logic rst_n,
		input  logic pixel_valid,
		input  logic processing_en,
		input  logic pixel_last,
		input  logic [7:0] pixel_in,
		output  logic [7:0] pixel_out,
		output  logic pixel_out_last,
		output  logic pixel_out_valid);
		
	always_ff@(posedge clk) begin     
		if(!rst_n) begin        // LOW SYNCHRONOUS RST 
			pixel_out_valid<=0;
			pixel_out_last<=0;
		end
		else if (processing_en & pixel_valid) begin   // PASS PIXEL & SEND VALID SIGNAL 
			pixel_out<= pixel_in;
			pixel_out_valid<= 1;
			pixel_out_last  <= pixel_last;
		end
		else begin
			pixel_out_valid<=0;
			pixel_out_last<=0;
		end
	end
	
endmodule