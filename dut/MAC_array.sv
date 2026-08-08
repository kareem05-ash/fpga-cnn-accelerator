module MAC_array #(
    // Parameters
        parameter int N = 3,
        parameter int PROD_W = 17   // 8-bit unsigned * 8-bit signed = 17-bit signed
) (
    // Inputs
        input  logic              clk,             // +ve edge triggered system clk
        input  logic              rst_n,           // SYNCH active-low rst_n
        input  logic              window_valid,    // flags a valid window
        input  logic              window_last,     // flags the last window
        input  logic        [7:0] window [N*N],    // 1-D array of N*N pixels
        input  logic signed [7:0] kernel [N*N],    // 1-D kernel of N*N coeff's
    // Outputs
        output logic              partial_valid,   // flags a valid partial sum array
        output logic              partial_last,    // flags that the partial sum array is for the last output
        output logic signed [PROD_W+$clog2(N)-1 : 0]    partial_sum [N]
);

 logic valid_out [0:N-1];
 logic signed [PROD_W-1:0] product [N-1:0];

 logic [$clog2(N)-1:0] row_sel;   

 logic [7:0] window_row [N];           //MUX_SEL_WINDOW_ROW
 logic signed [7:0] kernel_row [N];    //MUX_SEL_KERNEL_ROW

 logic signed [PROD_W+$clog2(N)-1:0] partial_sum_comb;
 

 generate                                  // N PROCESSING ELEMENT INSTANTIATION
  for (genvar r = 0; r < N; r++) begin
	 processing_element #(
				.PROD_W(PROD_W)
				) U0 (
				.valid_in(window_valid), 
			        .pixel(window_row[r]), 
				.coeff(kernel_row[r]), 
				.valid_out(valid_out[r]), 
	  		        .product(product[r])
			         );
  end
 endgenerate 


 always_comb begin                         // ROW_SEL_LOGIC               
	if ( window_valid) begin 
		for(int i=0;i<N;i++) begin 
			window_row[i]=window[row_sel*N+i];
			kernel_row[i]=kernel[row_sel*N+i];
		end
	end
	else begin 
		window_row='{default:0};
		kernel_row='{default:0};
	end
 end

 always_comb begin                        // SUM OF SEL ROW AFTER PROCESSING ELEMENT 
	partial_sum_comb=0;
	if(valid_out[row_sel]) begin 
		for(int i=0;i<N;i++) begin 
			partial_sum_comb=partial_sum_comb+product[i];
		end
	end
 end

 always_ff@(posedge clk) begin         // INCREMENT ROW_SEL AND CALC PARTIAL_VALID SIGNAL
	if(!rst_n) begin
		row_sel<=0;
		partial_valid<=0;
		partial_last<=0;
	end
	else if( valid_out[row_sel] ) begin 
		partial_sum[row_sel]<=partial_sum_comb;    // REGISTER PARTIAL SUM
		if(row_sel!=N-1) begin 
			row_sel<=row_sel+1;           
			partial_valid<=0;
			partial_last<=0;
		end 	
		else begin 
			row_sel<=0;
			partial_valid<=1;
			partial_last<=window_last;
		end
	end
	else begin 
		row_sel<=0;
		partial_valid<=0;
		partial_last<=0;
	end
 end


endmodule