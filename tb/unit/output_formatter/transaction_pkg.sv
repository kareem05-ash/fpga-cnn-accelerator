package transaction_pkg;
	class transaction;
		parameter ACC_W = 24;
		parameter OUT_W = 16;
		
		rand logic signed [ACC_W-1:0] relu_result;
		rand logic relu_valid;
		rand logic relu_last;
		logic signed [OUT_W-1:0] actual_pixel_out;
		logic actual_pixel_valid;
		logic actual_pixel_last;
		
		constraint RELU_RANGE {
			relu_result dist {[24'sh000001 : 24'sh007FFE] :/ 40 ,
					  [24'shFF8001 : 24'shFFFFFF] :/ 40 ,
					   24'sh007FFF                 :/ 5 ,
					   24'shFF8000                 :/ 5 ,
					   24'd0                       :/ 5 ,
					  [24'sh008000 : 24'sh7fffff] :/ 5  ,
					  [24'sh800000 : 24'shFF7FFF] :/ 5 };
		}
		
		constraint VALID {
			relu_valid dist {1'b1 := 90 , 1'b0 := 10};
		}
		
		constraint LAST {
			relu_last dist {1'b1 := 50 , 1'b0 := 50};
		}
		
		task display_gen ();
			$display("============== generated values ===========");
			$display("relu_result = %d" , relu_result);		//display pos & neg
			$display("relu_valid = %b" , relu_valid);
			$display("relu_last = %b" , relu_last);
		endtask

		covergroup cg;
			valid_c: coverpoint relu_valid {
				bins valid_high = {1'b1};
				bins valid_low = {1'b0};
			}
			
			last_c: coverpoint relu_last {
				bins last_high = {1'b1};
				bins last_low = {1'b0};
			}
			result_c: coverpoint relu_result {
				bins max_neg = {24'shFF8000};
				bins max_pos = {24'sh007FFF};
				bins in_range_negative = {[24'shFF8001 : 24'shFFFFFF]};
				bins in_range_positive = {[24'sh000001 : 24'sh007FFE]};
				bins zero = {24'd0};
				bins out_of_range_pos = {[24'sh008000:24'sh7fffff]};
				bins out_of_range_neg = {[24'sh800000:24'shFF7FFF]};
			}
		endgroup
		function new();
			cg = new();
		endfunction
	endclass
endpackage
