module output_ctrl #(
    // Parameters
        parameter int N             = 3,
        parameter int IMG_WIDTH     = 32,
        parameter int IMG_HEIGHT    = 32,
        parameter int OUT_WIDTH     = IMG_WIDTH  - N + 1,
        parameter int OUT_HEIGHT    = IMG_HEIGHT - N + 1,
        parameter int ADDR_W        = $clog2(OUT_WIDTH * OUT_HEIGHT)
) (
    // Inputs
        input  logic                clk,        // risign edge triggered syste clk
        input  logic                rst_n,      // synch active-low reset signal
        input  logic                fmt_valid,  // flags a valid formatted output
        input  logic                fmt_last,   // flags the last fmt_output of the feature map
    // Output
        output logic [ADDR_W-1 : 0] out_waddr,  // sent to output_mem to store the output
        output logic                out_we,     // write enable sent to output_mem block
        output logic                done        // sent to the global fsm
);

always_ff @(posedge clk)
	begin
		if(!rst_n)
			begin
				out_waddr <= 'd0;
			end
		else if (fmt_valid)
			begin
				if(fmt_last)
					out_waddr <= 'd0;
				else
					out_waddr <= out_waddr + 1;
			end
	end
assign done = (fmt_last && fmt_valid);
assign out_we = fmt_valid;

endmodule