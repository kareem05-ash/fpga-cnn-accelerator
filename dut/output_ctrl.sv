module output_ctl #(parameter out_width = 32 , out_height = 32)
(
	input clk,
	input rst_n,				//synchronous
	input pixel_last,			//Last output pixel indicator
	input [15:0] pixel_in,		//Formatted output pixel
	input pixel_valid,
	output reg [15:0] pixel_out,
	output reg pixel_out_valid,
	output reg done					//sent to the global_ctrl
);

reg [15:0] row_cnt;				//row counter
reg [15:0] col_cnt;				//column counter

always_ff @(posedge clk)
	begin
		if(!rst_n)
			begin
				row_cnt <= 'd0;
				col_cnt <= 'd0;
				done <= 1'b0;
			end
		else if (pixel_valid)
			begin
				if (pixel_last)		//done
					begin
						row_cnt <= 'd0;
						col_cnt <= 'd0;
						done <= 1'b1;
					end
				else if(col_cnt == out_width - 1)
					begin
						row_cnt <= row_cnt + 1;
						col_cnt <= 'd0;
						done <= 1'b0;
					end
				else
					begin
						col_cnt <= col_cnt + 1;
						done <= 1'b0;
					end
			end
		else
			done <= 1'b0;		//assume we end an image and at the next posedge the pixel_valid (or else) is still zero the counters will remaain zeros but...
						//the image_done will remain 1 and we want it just for 1 clock cycle so at this state the image_done must return to zero 
	end
					
always @(*)
	begin
		if (!rst_n)
			begin
				pixel_out = 'd0;		//avoid the unintentional latch
				pixel_out_valid = 1'b0;
			end
		else if (pixel_valid)
			begin
				pixel_out = pixel_in;
				pixel_out_valid = 1'b1;
			end
		else
			begin
				pixel_out = 'd0;		//avoid the unintentional latch
				pixel_out_valid = 1'b0;
			end
	end

endmodule