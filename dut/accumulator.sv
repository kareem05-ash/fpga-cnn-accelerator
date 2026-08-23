// /* Not Used: accumulator now is embedded with MAC module */
// module accumulator #(
//     // Parameters
//         parameter int N = 3,
//         parameter int PART_W,
//         parameter int ACC_W = PART_W + $clog2(N)
// ) (
//     // Inputs
//         input  logic partial_valid,
//         input  logic partial_last,
//         input  logic signed [PART_W-1 : 0] partial_sum [N],
//     // Outputs
//         output logic conv_valid,
//         output logic conv_last,
//         output logic signed [ACC_W-1 : 0] conv_result
// );
//     assign conv_last  = partial_valid && partial_last;
//     assign conv_valid = partial_valid;
//     always_comb begin
//         conv_result = '0;
//         if (partial_valid)
//             for (int i = 0; i < N; i++)
//                 conv_result += partial_sum [i];
//     end
// endmodule
