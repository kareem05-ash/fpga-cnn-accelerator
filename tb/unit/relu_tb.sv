`timescale 1ns/1ps
module relu_tb();

    logic signed [21:0] conv_result_tb;
    logic               conv_last_tb, conv_valid_tb;
    logic               relu_last_tb, relu_valid_tb;
    logic signed [21:0] relu_result;

    // DUT
    relu #(.N(5), .PROD_W(16)) dut (
        .conv_result (conv_result_tb),
        .conv_last   (conv_last_tb),
        .conv_valid  (conv_valid_tb),
        .relu_last   (relu_last_tb),
        .relu_valid  (relu_valid_tb),
        .relu_result (relu_result)
    );

    initial begin
        // --- Positive value: pass through unchanged ---
        conv_result_tb = 22'sd56;
        conv_last_tb   = 0;
        conv_valid_tb  = 0;
        #5;

        conv_valid_tb = 1;
        #1;
        if (relu_valid_tb == 1) begin
            if (relu_result == conv_result_tb)
                $display("PASS: +ve passthrough. exp=%0d got=%0d", conv_result_tb, relu_result);
            else
                $display("FAIL: +ve passthrough. exp=%0d got=%0d", conv_result_tb, relu_result);
        end else
            $display("FAIL: relu_valid not asserted for +ve case");

        // --- Negative value: clamp to zero
        conv_valid_tb  = 0;
        conv_result_tb = -22'sd26;
        #1;
        conv_valid_tb = 1;
        #1;
        if (relu_valid_tb == 1) begin
            if (relu_result == 0)
                $display("PASS: -ve clamp. exp=0 got=%0d", relu_result);
            else
                $display("FAIL: -ve clamp. exp=0 got=%0d", relu_result);
        end else
            $display("FAIL: relu_valid not asserted for -ve case");

        // --- Zero: stays zero
        conv_valid_tb  = 0;
        conv_result_tb = 0;
        #1;
        conv_valid_tb = 1;
        #1;
        if (relu_valid_tb == 1) begin
            if (relu_result == conv_result_tb)
                $display("PASS: zero passthrough. exp=0 got=%0d", relu_result);
            else
                $display("FAIL: zero passthrough. exp=0 got=%0d", relu_result);
        end else
            $display("FAIL: relu_valid not asserted for zero case");

        // --- All ones (-1): clamp to zero
        conv_valid_tb  = 0;
        conv_result_tb = 22'sb1111_1111_1111_1111_1111_11;
        #1;
        conv_valid_tb = 1;
        #1;
        if (relu_valid_tb == 1) begin
            if (relu_result == 0)
                $display("PASS: all-ones clamp. exp=0 got=%0d", relu_result);
            else
                $display("FAIL: all-ones clamp. exp=0 got=%0d", relu_result);
        end else
            $display("FAIL: relu_valid not asserted for all-ones case");

        // test the relu last signal
        conv_valid_tb = 0;
        conv_last_tb = 1;
        conv_result_tb = 22'sb0000_1111_1111_1111_1111_11;
        #1;
        conv_valid_tb = 1;
        #1;
        if (relu_valid_tb == 1 && relu_last_tb == 1) begin
            if (relu_result == conv_result_tb)
                $display("PASS: +ve num stays same & last relu works good. exp=%d got=%0d", conv_result_tb, relu_result);
            else
                $display("FAIL: +ve num is handled wrong but the last relu works good. exp=%d got=%0d", conv_result_tb ,relu_result);
        end else
            $display("FAIL: relu_valid or relu_last not asserted for this case");


        $finish;
    end

endmodule