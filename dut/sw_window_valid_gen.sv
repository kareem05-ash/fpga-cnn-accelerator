module sw_window_valid_gen #(
    // Parameters
        parameter N = 3,
        parameter IMG_WIDTH = 32
) (
    // Inputs
        input  logic        pixel_valid,    // flags a valid pixel is being received
        input  logic [$clog2(IMG_WIDTH)-1 : 0]  col_idx,
        input  logic [$clog2(N)-1 : 0]          stored_rows,
    // Outputs
        output logic        window_valid
);
    assign window_valid = 
                pixel_valid             &&
                (col_idx     >= (N - 1))&&
                (stored_rows == (N - 1));
endmodule : sw_window_valid_gen
