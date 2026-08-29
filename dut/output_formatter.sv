module output_formatter #(
    // Parameters
        parameter int unsigned ACC_W = 24,
        parameter int unsigned OUT_W = 16
) (
    // Inputs
        input  logic                        relu_valid,
        input  logic                        relu_last,
        input  logic signed [ACC_W-1 : 0]   relu_result,
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
            if (relu_result > signed'({{ACC_W-OUT_W{MAX_OUT[OUT_W-1]}}, MAX_OUT})) begin
                pixel_out = MAX_OUT;
            // lower saturation
            end else if (relu_result < signed'({{ACC_W-OUT_W{MIN_OUT[OUT_W-1]}}, MIN_OUT})) begin
                pixel_out = MIN_OUT;
            // no saturation
            end else begin
                pixel_out = relu_result;
            end
        end
    end
endmodule
