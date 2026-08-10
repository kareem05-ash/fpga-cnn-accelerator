// module accumulator #(
//     parameter PARTIAL_W = 18,
//     N = 3,
//     ACC_W = (PARTIAL_W + $clog2(N)) 
//     ) (
//     input signed [PARTIAL_W - 1:0] partial_sum [0 : N-1],
//     input partial_valid, partial_last,
//     output signed [ACC_W-1:0] conv_result,
//     output conv_valid, conv_last
// );



// always@(*) begin

//     if(partial_valid) begin
//         int i;
//         conv_result = 0;
//         conv_valid = 1;
//         for(i = 0; i < N; i++) begin
//             conv_result = conv_result + partial_sum[i];
//         end
//         conv_last = partial_last;
//     end
//     else begin
//         conv_valid = 0;
//         conv_result = 0;
//         conv_last = 0;
//     end
// end

// endmodule


module accumulator #(
    // Parameters
        parameter int N = 3,
        parameter int PART_W,
        parameter int ACC_W = PART_W + $clog2(N)
) (
    // Inputs
        input  logic partial_valid,
        input  logic partial_last,
        input  logic signed [PART_W-1 : 0] partial_sum [N],
    // Outputs
        output logic conv_valid,
        output logic conv_last,
        output logic signed [ACC_W-1 : 0] conv_result
);
    assign conv_last  = partial_valid && partial_last;
    assign conv_valid = partial_valid;
    always_comb begin
        conv_result = '0;
        if (partial_valid)
            for (int i = 0; i < N; i++)
                conv_result += partial_sum [i];
    end
endmodule
