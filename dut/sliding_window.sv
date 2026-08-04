module sliding_window #(
    // Parameters
        parameter   N = 3,
        parameter   IMG_WIDTH
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
    // Pointers Maping in line_buf 1-D Array
    //////////////////////////////////////////////////
    // oldest   active  newest                  oldest
    //          oldest  active  newest
    //                  oldest  active  newest
    // newest                   oldest  active  newest  
    // active   newest                  oldest  active
    //////////////////////////////////////////////////
    // 1-D array representing line buffers + active row
        logic [7:0] line_buf [N * IMG_WIDTH];
    
    // Internal Signals
        logic [$clog2(IMG_WIDTH)-1:0]       col_idx_cnt;
        logic [$clog2(N * IMG_WIDTH)-1:0]   buf_wr_ptr;
        logic [$clog2((N-1) * IMG_WIDTH):0] active_row_ptr;
        logic [$clog2((N-1) * IMG_WIDTH):0] oldest_row_ptr;
        logic [$clog2((N-1) * IMG_WIDTH):0] newest_row_ptr;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            window_valid    <= '0;
            col_idx_cnt     <= '0;
            buf_wr_ptr      <= '0;
            oldest_row_ptr  <= '0;
            newest_row_ptr  <= (N - 2) * IMG_WIDTH;
            active_row_ptr  <= (N - 1) * IMG_WIDTH;
        // Normal Data Streaming
        end else if (pixel_valid) begin
            // Line Buffer Still Not Full
            if (buf_wr_ptr < (active_row_ptr + N - 1)) begin
                window_valid <= '0;     // we can't generate window so far
                line_buf[buf_wr_ptr] <= pixel_in;
                buf_wr_ptr <= buf_wr_ptr + 1;
                if (buf_wr_ptr >= active_row_ptr)
                    col_idx_cnt <= col_idx_cnt + 1;
            // Now, we can generate window
            end else begin
                window_valid <= 1'b1;
                // last pixel of that row
                if (col_idx_cnt == IMG_WIDTH - 1) begin
                    col_idx_cnt <= '0;
                    active_row_ptr <= oldest_row_ptr;
                    newest_row_ptr <= active_row_ptr;
                    oldest_row_ptr <= (oldest_row_ptr == (N-1)*IMG_WIDTH)? '0 : oldest_row_ptr + IMG_WIDTH;
                end else begin
                    col_idx_cnt <= col_idx_cnt + 1;
                end
                // active row is one of the boundary rows
                if (((active_row_ptr > oldest_row_ptr) && (active_row_ptr > newest_row_ptr)) || 
                    ((active_row_ptr < oldest_row_ptr) && (active_row_ptr < newest_row_ptr))) begin
                    // fill in the first N-1 rows of the window from oldest to newest
                    for (shortint i = 0; i < N - 1; i++) begin
                        // fill in N entry of each row
                        for (shortint j = col_idx_cnt; j < col_idx_cnt + N; j++) begin
                            window [(i * N) + j - col_idx_cnt] <= line_buf [oldest_row_ptr + (i * IMG_WIDTH) + j];
                        end
                    end
                    // fill in the last row with active data
                    for (shortint i = col_idx_cnt; i < (col_idx_cnt + N - 1); i++) begin
                        window [((N - 1) * N) + i - col_idx_cnt] <= line_buf [active_row_ptr + i];
                    end
                    // fill in the last pixel with the pixel is being received
                    window [(N * N) - 1] <= pixel_in;
                    line_buf [active_row_ptr + col_idx_cnt] <= pixel_in;
                // active row is between oldest and newest
                end else begin
                    // fill in the window from oldest to the end
                    for (shortint i = 0; i < (N - (oldest_row_ptr/IMG_WIDTH)); i++) begin
                        for (shortint j = col_idx_cnt; j < col_idx_cnt + N; j++) begin
                            window [(i * N) + j - col_idx_cnt] <= line_buf [oldest_row_ptr + (i * IMG_WIDTH) + j];
                        end
                    end
                    // fill in the window from the begin to newest
                    for (shortint i = 0; i < (newest_row_ptr/IMG_WIDTH); i++) begin
                        for (shortint j = col_idx_cnt; j < col_idx_cnt + N; j++) begin
                            window [(i * N) + j - col_idx_cnt] <= line_buf [(i * IMG_WIDTH) + j];
                        end
                    end
                    // fill in the window with the active row
                    for (shortint i = col_idx_cnt; i < (col_idx_cnt + N - 1); i++) begin
                        window [((N - 1) * N) + i - col_idx_cnt] <= line_buf [active_row_ptr + i];
                    end
                    // fill in the last pixel with the pixel is being received
                    window [(N * N) - 1] <= pixel_in;
                    line_buf [active_row_ptr + col_idx_cnt] <= pixel_in;
                end // active row is between oldest and newest
            end // window generation
        end // pixel_valid
    end // always_ff
endmodule
