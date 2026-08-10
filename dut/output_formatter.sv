// module output_formatter#(parameter ACC_W) (
//     input [ACC_W -1 : 0] relu_result,
//     input relu_valid, round_en,
//     input [4:0] shamt,
//     output reg signed [15:0] pixel_out,
//     output reg pixel_valid
// );

// logic signed [ACC_W +1 :0] scalling, pre_shift;
// logic signed [ACC_W +5 :0] offcet;

// always@(*) begin

//     if(relu_valid) begin

//         pixel_valid = 1;
//         if(round_en && shamt > 0) begin
//             offcet = 1 << (shamt-1);
//         end
//         else if (round_en == 0 || shamt == 0 ) begin
//             offcet = 0;
//         end

//         pre_shift = relu_result + offcet;

//         if(shamt)
//             scalling = pre_shift >>> shamt;
//         else
//             scalling = pre_shift;

//         if(scalling > 16'sd32767)
//             scalling = 16'sd32767;
//         else if(scalling <  -16'sd32768)
//             scalling = -16'sd32768;

//         pixel_out = scalling;
//         pixel_valid = 1;

//     end
//     else begin
//         pixel_valid = 0;
//         pixel_out = 0;
//     end
// end

// endmodule

module output_formatter #(
    // Parameters
        parameter int unsigned ACC_W = 24,
        parameter int unsigned OUT_W = 16
) (
    // Inputs
        input  logic                        relu_valid,
        input  logic                        relu_last,
        input  logic [ACC_W-1 : 0]          relu_result,
    // Outputs
        output logic signed [OUT_W-1 : 0]   pixel_out,
        output logic                        pixel_valid,
        output logic                        pixel_last
);
    localparam logic signed [OUT_W-1 : 0] MAX_OUT = {1'b0, {OUT_W-1{1'b1}}};
    localparam logic signed [OUT_W-1 : 0] MIN_OUT = {1'b1, {OUT_W-1{1'b0}}};
    assign pixel_last   = relu_valid && relu_last;
    assign pixel_valid  = relu_valid;
    /* Perform Saturation Only */
    always_comb begin
        pixel_out = '0;
        if (relu_valid) begin
            // upper saturation
            if (relu_result > {{ACC_W-OUT_W{MAX_OUT[OUT_W-1]}}, MAX_OUT}) begin
                pixel_out = MAX_OUT;
            // lower saturation
            end else if (relu_result < {{ACC_W-OUT_W{MIN_OUT[OUT_W-1]}}, MIN_OUT}) begin
                pixel_out = signed'(MIN_OUT[OUT_W-1 : 0]);
            // no saturation
            end else begin
                pixel_out = signed'(relu_result[OUT_W-1 : 0]);
            end
        end
    end
endmodule
