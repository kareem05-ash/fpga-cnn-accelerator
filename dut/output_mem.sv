module output_mem #(parameter out_width = 32 , out_height = 32 , addr_width = $clog2((out_height)*(out_width)) , data_width = 16)
(
	input clk,
	input rst_n,						//synchronous
	input output_we,					//write enable
	input output_re,					//read enable
	input [addr_width-1:0] output_addr,
	input [data_width-1:0] output_data,	//out from the output_ctl
	output reg [out_width-1:0] read_data
);

reg [out_width-1:0] mem [0:(out_width*out_height)-1];		//every address refere to one pixel not one row

always_ff @(posedge clk)
	begin
		if(!rst_n)
			begin
				read_data <= 'd0;
			end
		else if (output_we && !output_re)				//in case both 1s preserve the values 
			begin
				mem[output_addr] <= output_data;
			end
		else if (!output_we && output_re)
			begin
				read_data <= mem[output_addr];
			end
	end

endmodule