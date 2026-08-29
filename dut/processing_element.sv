module processing_element #(
    // Parameters
        parameter int PROD_W = 17
) (
    // Inputs
        input logic unsigned [7:0] pixel,   // input unsigned data pixel [0-255]
        input logic signed   [7:0] coeff,   // kernel signed coefficient [-128-127]
        // input logic                valid_in,// flags that input pixel is valid
    // Outputs
        output logic signed [PROD_W-1 : 0] product // product signed output
        // output logic               valid_out// flags that product is valid iff valid_in asserted
);
    // product_dsp signal is needed to infer a dsp blcok for each PE
    (* use_dsp48 = "yes" *)
    logic signed [PROD_W-1 : 0] product_dsp;
    logic signed [8:0] pixel_ext;

    assign pixel_ext    = {1'b0, pixel};
    assign product_dsp  = pixel_ext * coeff;
    assign product      = product_dsp;
    // assign valid_out    = valid_in;
endmodule
