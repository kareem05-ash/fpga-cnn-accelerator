module sw_window_extractor #(
    // Parameters
        parameter N = 3,
        parameter IMG_WIDTH = 32
) (
    // Inputs
        input  logic [7:0]  line_buf [N * IMG_WIDTH],
        input  logic [7:0]  pixel_in,
        input  logic [$clog2(IMG_WIDTH)-1 : 0]  col_idx,
        input  logic [$clog2(N)-1 : 0]          active_row,
        input  logic [$clog2(N)-1 : 0]          oldest_row,
    // Outputs
        output logic [7:0] window [N*N]
);
    // Pointers Maping in line_buf 1-D Array
    //////////////////////////////////////////////////
    // A        B       C       D       E       A
    // oldest   active  newest                  oldest
    //          oldest  active  newest
    //                  oldest  active  newest
    // newest                   oldest  active  newest  
    // active   newest                  oldest  active
    //////////////////////////////////////////////////
    always_comb begin
        // N-1 rows from oldest to newest
        for (int i = 0; i < (N - 1); i++) begin
            for (int j = 0; j < N; j++) begin
                window [i*N + j] = line_buf [(((i + oldest_row) % N) * IMG_WIDTH) + (j + col_idx - N + 1)];
            end
        end
        // active row except the last pixel
        for (int j = 0; j < (N - 1); j++) begin
            window [(N-1)*N + j] = line_buf [(active_row * IMG_WIDTH) + (j + col_idx - N + 1)];
        end
        // last pixel
        window [N*N - 1] = pixel_in;
    end
endmodule : sw_window_extractor
