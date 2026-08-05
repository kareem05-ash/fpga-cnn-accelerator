module sliding_window #(
    // Parameters
        parameter   int N = 3,
        parameter   int IMG_WIDTH
)(
    // Inputs
        input  logic        clk,            // global active-high clk
        input  logic        rst_n,          // synch active-low rst_n
        input  logic        pixel_valid,    // flags a valid pixel is being received
        input  logic [7:0]  pixel_in,       // input pixel {data streaming}
    // Outputs
        output logic        window_valid,   // flags a valid window
        output logic [7:0]  window[N*N]     // active window
);
    // 1-D array representing line buffers + active row
    logic [7:0] line_buf [N * IMG_WIDTH];
    logic [$clog2(N * IMG_WIDTH)-1 : 0] wr_addr;
    logic [$clog2(IMG_WIDTH)-1 : 0]     col_idx;
    logic [$clog2(N)-1 : 0] active_row,
                            oldest_row,
                            stored_rows;
    always_ff @(posedge clk) begin
        if (pixel_valid)
            line_buf [wr_addr] <= pixel_in;
    end

    sw_addr_manager #(
        .N        (N /* default 3 */),
        .IMG_WIDTH(IMG_WIDTH /* default 32 */)
     ) u_addr_manager (
        .clk        (clk),
        .rst_n      (rst_n),
        .pixel_valid(pixel_valid),
        .col_idx    (col_idx),
        .stored_rows(stored_rows),
        .active_row (active_row),
        .oldest_row (oldest_row),
        .wr_addr    (wr_addr)
    );

    sw_window_valid_gen #(
        .N        (N /* default 3 */),
        .IMG_WIDTH(IMG_WIDTH /* default 32 */)
     ) u_window_valid_gen (
        .pixel_valid (pixel_valid),
        .col_idx     (col_idx),
        .stored_rows (stored_rows),
        .window_valid(window_valid)
    );

    sw_window_extractor #(
        .N        (N /* default 3 */),
        .IMG_WIDTH(IMG_WIDTH /* default 32 */)
     ) u_window_extractor (
        .line_buf  (line_buf),
        .pixel_in  (pixel_in),
        .col_idx   (col_idx),
        .active_row(active_row),
        .oldest_row(oldest_row),
        .window    (window)
    );
endmodule
