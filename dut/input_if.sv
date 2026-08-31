module input_if(
  // Inputs
    input  logic clk,
  input  logic rst_n,
    input  logic processing_en,
    input  logic pixel_valid,
    input  logic pixel_last,
    input  logic pixel_dropped,     // New signal needed to handle dropped pixels
    input  logic [7:0] pixel_in,
  // Outputs
    output logic [7:0] pixel_out,
    output logic pixel_out_last,
    output logic pixel_out_valid
  );
    // pixel_out_valid assert iff (1. || 2.) -> iff (pixel_valid)
    //  1. pixel_valid is asserted && pixel_dropped is asserted
    //  2. pixel_valid is asserted && pixel_dropped is NOT asserted
    // 1. & 2. simplified to pixel_valid only 
    assign pixel_out_valid  = pixel_valid && processing_en;
    // assign pixel_out_last   = pixel_valid && processing_en && pixel_last;

    always_ff @(posedge clk) begin
      if (!rst_n)
        pixel_out <= '0;
      else if (processing_en && pixel_valid && !pixel_dropped)
        pixel_out <=  pixel_in;
    end

    always_ff @(posedge clk) begin
      if (!rst_n)   pixel_out_last  <= 'd0;
      else          pixel_out_last  <= pixel_valid && processing_en && pixel_last;
    end
endmodule
