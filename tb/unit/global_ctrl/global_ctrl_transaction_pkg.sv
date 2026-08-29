package global_ctrl_transaction_pkg;
	class transaction;
		rand logic rst_n;
		rand logic start;
		rand logic output_done;
		logic  actual_busy;
		logic actual_done;
		logic actual_processing_en;
		
		constraint RESET {
			rst_n dist {1'b1 := 95 , 1'b0 := 5};
		}
		
		constraint START {
			start dist {1'b1 := 60 , 1'b0 := 40};
		}
		
		constraint DONE {
			output_done dist {1'b1 := 30 , 1'b0 := 70};
		}
		
		covergroup cg;
			reset_c: coverpoint rst_n {
				bins rst_active = {1'b0};
				bins rst_inactive = {1'b1};
			}
			
			start_c: coverpoint start {
				bins start_high = {1'b1};
				bins start_low = {1'b0};
			}
			
			done_c: coverpoint output_done {
				bins end_reach = {1'b1};
				bins continue_send = {1'b0};
			}
			
			busy_c: coverpoint actual_busy {
				bins busy_active   = {1'b1};
				bins busy_inactive = {1'b0};
			}
			
			done_out_c: coverpoint actual_done {
				bins done_active   = {1'b1};
				bins done_inactive = {1'b0};
			}
			
			processing_en_c: coverpoint actual_processing_en {
				bins pe_active   = {1'b1};
				bins pe_inactive = {1'b0};
			}
			
			// -------- Cross coverage --------
			//test start = 1 when busy = 1
			start_x_busy: cross start_c, busy_c {
				bins start_in_busy = binsof(start_c.start_high) && binsof(busy_c.busy_active);
			}
			
			// test the mid reset case rst = 0 when busy = 1
			reset_x_busy: cross reset_c, busy_c {
				bins mid_reset = binsof(reset_c.rst_active) && binsof(busy_c.busy_active);
			}
		endgroup

		function new();
			cg = new();
		endfunction
		
		function void display_gen ();
			$display("============== generated values ===========");
			$display("rst_n = %b" , rst_n);
			$display("start = %b" , start);
			$display("output_done = %b" , output_done);
		endfunction
	endclass
endpackage
