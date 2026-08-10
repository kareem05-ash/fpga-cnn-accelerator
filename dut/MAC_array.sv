module MAC_array #(
    // Parameters
        parameter int N = 3,
        parameter int PROD_W = 17,                 // 8-bit unsigned * 8-bit signed = 17-bit signed
	parameter int ACC_W=PROD_W+$clog2(N)
) (
    // Inputs
        input  logic              clk,             // +ve edge triggered system clk
        input  logic              rst_n,           // SYNCH active-low rst_n
        input  logic              window_valid,    // flags a valid window
        input  logic              window_last,     // flags the last window
        input  logic        [7:0] window [N*N],    // 1-D array of N*N pixels
        input  logic signed [7:0] kernel [N*N],    // 1-D kernel of N*N coeff's
    // Outputs
        output logic              conv_valid,       // flags a valid conv_result
        output logic              conv_last,        // flags that the conv_result is for the last output
        output logic signed [PROD_W+$clog2(N)-1 : 0]    conv_result
);

 logic valid_out [N*N-1:0];
 logic signed [PROD_W-1:0] product [N*N-1:0];   

 logic signed [PROD_W+$clog2(N)-1:0] conv_result_comb;
 

 generate                                  // N*N PROCESSING ELEMENT INSTANTIATION
  for (genvar r = 0; r < N*N; r++) begin
	 processing_element #(
				.PROD_W(PROD_W)
				) U0 (
				.valid_in(window_valid), 
			        .pixel(window[r]), 
				.coeff(kernel[r]), 
				.valid_out(valid_out[r]), 
	  		        .product(product[r])
			         );
  end
 endgenerate 

 always_comb begin                        // SUM OF N*N PROCESSING ELEMENT RESULTS 
	conv_result_comb=0;
		for(int i=0;i<N*N;i++) begin 
			if(valid_out[i])
				conv_result_comb=conv_result_comb+product[i];
		end
 end

 always_ff@(posedge clk) begin         
	if(!rst_n) begin
		conv_valid<=0;
		conv_last<=0;
	end
	else if (window_valid) begin
		conv_result<=conv_result_comb;
		conv_valid<=1;
		conv_last<=window_last;
	end
	else begin 
		conv_valid<=0;
		conv_last<=0;
	end
 end


endmodule