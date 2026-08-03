module relu #(
    // Parameters
        parameter ACC_W = 24                                // accumulator output width
) (
    // Inputs
        input  logic signed [ACC_W-1 : 0]   conv_result,    // convolution result from the accumulator
        input  logic                        conv_valid,     // flags a valid convolution result
        input  logic                        relu_en,        // enables relu operation
    // Outputs
        output logic signed [ACC_W-1 : 0]   relu_result,    // ReLU result
        output logic                        relu_valid      // flags a valid ReLU valid result 
);
    assign relu_valid = conv_valid;
    always_comb begin
        // relu_en && conv_valid && conv_result is negative must asserted at the same time 
        if (relu_en && conv_valid && conv_result[ACC_W-1]) begin
            // apply ReLU
            relu_result = '0;   // Pass zero instead of negative value
        end else begin
            relu_result = conv_result;      // Pass-through convolution result
        end
    end
endmodule
