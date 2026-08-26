`timescale 1ns/1ns

module output_formatter_tb;

import transaction_pkg ::*;
parameter ACC_W_tb = 24;
parameter OUT_W_tb = 16;

logic [ACC_W_tb-1:0] relu_result_tb;
logic relu_valid_tb;
logic relu_last_tb;
logic [OUT_W_tb-1:0] pixel_out_tb;
logic pixel_valid_tb;
logic pixel_last_tb;

transaction pkt;
logic signed [OUT_W_tb-1:0] expected_pixel_out;
logic expected_pixel_valid;
logic expected_pixel_last;

output_formatter #(.ACC_W(ACC_W_tb) , .OUT_W(OUT_W_tb)) DUT
(
	.relu_result(relu_result_tb),
	.relu_valid(relu_valid_tb),
	.relu_last(relu_last_tb),
	.pixel_out(pixel_out_tb),
	.pixel_valid(pixel_valid_tb),
	.pixel_last(pixel_last_tb)
);

task automatic gen_stim (ref transaction obj);
	if(!obj.randomize())
		$display("ERROR IN RANDOMIZATION");
	else
		begin
			pkt.cg.sample();
			pkt.display_gen();
		end
endtask

task drive_stim (transaction obj);
	#1
	relu_result_tb = obj.relu_result;
	relu_valid_tb = obj.relu_valid;
	relu_last_tb = obj.relu_last;
endtask

task automatic collect_out (ref transaction obj);
	#1; 
	obj.actual_pixel_out = pixel_out_tb;
	obj.actual_pixel_valid = pixel_valid_tb;
	obj.actual_pixel_last = pixel_last_tb;
endtask

function automatic void golden_model (transaction obj , ref logic signed [OUT_W_tb-1:0] expected_pixel_out , ref logic expected_pixel_valid , ref logic expected_pixel_last);
	if(obj.relu_valid)
		begin
			expected_pixel_valid = 1'b1;
			if(obj.relu_last)
				expected_pixel_last = 1'b1;
			else
				expected_pixel_last = 1'b0;
			if(obj.relu_result > 24'sh007FFF)
				expected_pixel_out = 24'sh007FFF;
			else if(obj.relu_result < 24'shFF8000)
				expected_pixel_out = 24'shFF8000;
			else
				expected_pixel_out = obj.relu_result;
		end
	else
		begin
			expected_pixel_valid = 1'b0;
			expected_pixel_last = 1'b0;
			expected_pixel_out = 'd0;
		end
endfunction

function void check_result (logic signed [OUT_W_tb-1:0] expected_pixel_out , logic expected_pixel_valid , logic expected_pixel_last , transaction obj);
	if(expected_pixel_out == obj.actual_pixel_out)
		$display("[PASS] the expected_pixel_out = %d , the actual_pixel_out = %d" , expected_pixel_out , obj.actual_pixel_out);
	else
		$display("[FAIL] SOMTHING WRONG IN THE OUTPUT , expected_pixel_out = %d , actual_pixel_out = %d" , expected_pixel_out , obj.actual_pixel_out);
	
	if(expected_pixel_valid == obj.actual_pixel_valid)
		$display("[PASS] the expected_pixel_valid = %b , the actual_pixel_valid = %b" , expected_pixel_valid , obj.actual_pixel_valid);
	else
		$display("[FAIL] SOMTHING WRONG IN THE VALID SIGNAL , expected_pixel_valid = %b , actual_pixel_valid = %b" , expected_pixel_valid , obj.actual_pixel_valid);
		
	if(expected_pixel_last == obj.actual_pixel_last)
		$display("[PASS] the expected_pixel_last = %b , the actual_pixel_last = %b" , expected_pixel_last , obj.actual_pixel_last);
	else
		$display("[FAIL] SOMTHING WRONG IN THE LAST SIGNAL , expected_pixel_last = %b , actual_pixel_last = %b" , expected_pixel_last , obj.actual_pixel_last);
endfunction

initial 
	begin
		pkt = new();
		repeat (100)
			begin
				#1
				gen_stim(pkt);
				drive_stim(pkt);
				golden_model(pkt , expected_pixel_out , expected_pixel_valid , expected_pixel_last);
        			collect_out(pkt);
				check_result(expected_pixel_out , expected_pixel_valid , expected_pixel_last , pkt);
    			end
		$stop;
	end

endmodule
