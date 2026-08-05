module MAC #(parameter int N)(
	input wire logic  clk, rst, window_valid,
	input wire logic  [7:0] window [0:N-1][0:N-1],
	input wire logic  signed [7:0] kernel_coeff [0:N-1][0:N-1], 
	output logic signed [16+$clog2(N)-1:0] partial_sum [0:N-1],
	output logic partial_valid);

 logic valid_out [0:N-1];
 logic signed [15:0] product [N-1:0];

 logic [$clog2(N)-1:0] row_sel;   

 logic [7:0] window_row [0:N-1];           //MUX_SEL_WINDOW_ROW
 logic signed [7:0] kernel_row [0:N-1];    //MUX_SEL_KERNEL_ROW

 logic signed [16+$clog2(N)-1:0] partial_sum_comb;
 

 generate                                  // N PROCESSING ELEMENT INSTANTIATION
  for (genvar r = 0; r < N; r++) begin
	 processing_element U0 (.valid_in(window_valid), .pixel(window_row[r]), .coeff(kernel_row[r]), 
		.valid_out(valid_out[r]), .product(product[r]));
  end
 endgenerate 


 always@(*) begin                         // ROW_SEL_LOGIC               
	if ( window_valid) begin 
		window_row=window[row_sel];
		kernel_row=kernel_coeff[row_sel];
	end
	else begin 
		window_row='{default:0};;
		kernel_row='{default:0};;
	end
 end

 always@(*) begin                        // SUM OF SEL ROW AFTER PROCESSING ELEMENT 
	partial_sum_comb=0;
	if(valid_out[row_sel]) begin 
		for(int i=0;i<N;i++) begin 
			partial_sum_comb=partial_sum_comb+product[i];
		end
	end
 end

 always@(posedge clk , negedge rst) begin         // INCREMENT ROW_SEL AND CALC PARTIAL_VALID SIGNAL
	if(!rst) begin
		row_sel<=0;
		partial_valid<=0;
	end
	else if( valid_out[row_sel] ) begin 
		partial_sum[row_sel]<=partial_sum_comb;    // REGISTER PARTIAL SUM
		if(row_sel!=N-1) begin 
			row_sel<=row_sel+1;           
			partial_valid<=0;
		end
		else begin 
			row_sel<=0;
			partial_valid<=1;
		end
	end
	else begin 
		row_sel<=0;
		partial_valid<=0;
	end
 end


endmodule