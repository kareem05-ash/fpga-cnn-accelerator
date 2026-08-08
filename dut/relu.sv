module relu #(
    // Parameters
        parameter int N,
        parameter int PROD_W,
        parameter ACC_W = PROD_W + $clog2(N)                              // accumulator output width
) (
    // Inputs
        input  logic signed [ACC_W-1 : 0]   conv_result,    // convolution result from the accumulator
        input  logic                        conv_valid,     // flags a valid convolution result
        input  logic                        conv_last,      // flags the last conv result is being processed
        input  logic                        relu_en,        // enables relu operation
    // Outputs
        output logic signed [ACC_W-1 : 0]   relu_result,    // ReLU result
        output logic                        relu_valid,     // flags a valid ReLU valid result
        output logic                        relu_last       // flags the last relu output is sent
);
    assign relu_valid = conv_valid;
    assign relu_last  = conv_valid && conv_last;
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
