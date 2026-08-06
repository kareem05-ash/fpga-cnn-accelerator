module input_ctl #(parameter img_width = 32 , img_height = 32)
(
	input clk,
	input rst_n,				//synchronous
	input processing_en,
	input [7:0] pixel_in,
	input pixel_valid,
	output reg [7:0] pixel_out,
	output reg pixel_out_valid,
	output [15:0] row_idx,		//Current image row
	output [15:0] col_idx,		//Current image column
	output reg image_done
);

reg [15:0] row_cnt;				//row counter
reg [15:0] col_cnt;				//column counter

always_ff @(posedge clk)
	begin
		if(!rst_n)
			begin
				row_cnt <= 'd0;
				col_cnt <= 'd0;
				image_done <= 1'b0;
			end
		else if (processing_en && pixel_valid)
			begin
				if (row_cnt == img_height - 1 && col_cnt == img_width - 1)		//done
					begin
						row_cnt <= 'd0;
						col_cnt <= 'd0;
						image_done <= 1'b1;
					end
				else if(col_cnt == img_width - 1)
					begin
						row_cnt <= row_cnt + 1;
						col_cnt <= 'd0;
						image_done <= 1'b0;
					end
				else
					begin
						col_cnt <= col_cnt + 1;
						image_done <= 1'b0;
					end
			end
		else
			image_done <= 1'b0;	//assume we end an image and at the next posedge the pixel_valid (or else) is still zero the counters will remaain zeros but...
						//the image_done will remain 1 and we want it just for 1 clock cycle so at this state the image_done must return to zero 
	end
					
always @(*)
	begin
		if (!rst_n)
			begin
				pixel_out = 'd0;
				pixel_out_valid = 1'b0;
			end
		else if (processing_en && pixel_valid)
			begin
				pixel_out = pixel_in;
				pixel_out_valid = 1'b1;
			end
		else
			begin
				pixel_out_valid = 1'b0;
				pixel_out = 'd0;		//to avoid the unintentional latch
			end
	end

//sent to the window to help in building it
assign row_idx = row_cnt;		//assign is used to avoid the delay
assign col_idx = col_cnt;

endmodule