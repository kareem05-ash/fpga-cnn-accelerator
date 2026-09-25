// module sw_window_extractor #(
//     // Parameters
//         parameter N = 3,
//         parameter IMG_WIDTH = 32
// ) (
//     // Inputs
//         input  logic clk,
//         input  logic [7:0]  line_buf [N * IMG_WIDTH],
//         input  logic [7:0]  pixel_in,
//         input  logic [$clog2(IMG_WIDTH)-1 : 0]  col_idx,
//         input  logic [$clog2(N)-1 : 0]          active_row,
//         input  logic [$clog2(N)-1 : 0]          oldest_row,
//     // Outputs
//         output logic [7:0] window [N*N]
// );
//     // Pointers Maping in line_buf 1-D Array
//     //////////////////////////////////////////////////
//     // A        B       C       D       E       A
//     // oldest   active  newest                  oldest
//     //          oldest  active  newest
//     //                  oldest  active  newest
//     // newest                   oldest  active  newest  
//     // active   newest                  oldest  active
//     //////////////////////////////////////////////////
//     // always_comb begin
//     //     // N-1 rows from oldest to newest
//     //     for (int i = 0; i < (N - 1); i++) begin
//     //         for (int j = 0; j < N; j++) begin
//     //             window [i*N + j] = line_buf [(((i + oldest_row) % N) * IMG_WIDTH) + (j + col_idx - N + 1)];
//     //         end
//     //     end
//     //     // active row except the last pixel
//     //     for (int j = 0; j < (N - 1); j++) begin
//     //         window [(N-1)*N + j] = line_buf [(active_row * IMG_WIDTH) + (j + col_idx - N + 1)];
//     //     end
//     //     // last pixel
//     //     window [N*N - 1] = pixel_in;
//     // end

//     always_ff @(posedge clk) begin
//         // N-1 rows from oldest to newest
//         for (int i = 0; i < (N - 1); i++) begin
//             for (int j = 0; j < N; j++) begin
//                 window [i*N + j] <= line_buf [(((i + oldest_row) % N) * IMG_WIDTH) + (j + col_idx - N + 1)];
//             end
//         end
//         // active row except the last pixel
//         for (int j = 0; j < (N - 1); j++) begin
//             window [(N-1)*N + j] <= line_buf [(active_row * IMG_WIDTH) + (j + col_idx - N + 1)];
//         end
//         // last pixel
//         window [N*N - 1] <= pixel_in;
//     end
// endmodule : sw_window_extractor



// module sw_window_extractor #(
    //Parameters
        // parameter N = 3,
        // parameter IMG_WIDTH = 32
// ) (
   // Inputs
        // input  logic clk,
        // input  logic [7:0]  line_buf [N * IMG_WIDTH],
        // input  logic [7:0]  pixel_in,
        // input  logic [$clog2(N*IMG_WIDTH)-1 : 0]  wr_addr,   // CURRENT write address
                                                              // (same signal already used to
                                                              // write line_buf this cycle --
                                                              // col_idx/active_row/oldest_row
                                                              // are no longer needed here)
    //Outputs
        // output logic [7:0] window [N*N]
// );
    // localparam int DEPTH  = N * IMG_WIDTH;
    // localparam int ADDR_W = $clog2(DEPTH);

    // genvar i, j;
    // generate
      // for (i = 0; i < N-1; i++) begin : gen_hist_row
        // localparam int BEHIND_ROWS               = (N-1) - i;
        // localparam logic [ADDR_W-1:0] OFFSET_ADD  = DEPTH - (BEHIND_ROWS * IMG_WIDTH);

        // logic [ADDR_W:0]   rd_addr_raw;     // ADDR_W+1 bits -- wide enough for the un-wrapped sum
        // logic [ADDR_W:0]   rd_addr_wrapped; // ADDR_W+1-bit temp holding the subtracted value
        // logic [ADDR_W-1:0] rd_addr;
        // logic [7:0]        shift_reg [N];

        // assign rd_addr_raw     = {1'b0, wr_addr} + {1'b0, OFFSET_ADD};
        // assign rd_addr_wrapped = rd_addr_raw - DEPTH;
        // assign rd_addr         = (rd_addr_raw >= DEPTH) ? rd_addr_wrapped[ADDR_W-1:0]
                                                         // : rd_addr_raw[ADDR_W-1:0];

        // always_ff @(posedge clk) begin
          // for (int k = 0; k < N-1; k++)
            // shift_reg[k] <= shift_reg[k+1];
          // shift_reg[N-1] <= line_buf[rd_addr];
        // end

        // for (j = 0; j < N; j++) begin : gen_tap
          // assign window[i*N + j] = shift_reg[j];
        // end
      // end
    // endgenerate

    
    // logic [7:0] active_shift [N-1];
    // always_ff @(posedge clk) begin
      // for (int k = 0; k < N-2; k++)
        // active_shift[k] <= active_shift[k+1];
      // active_shift[N-2] <= pixel_in;
    // end

    // generate
      // for (j = 0; j < N-1; j++) begin : gen_active_tap
        // assign window[(N-1)*N + j] = active_shift[j];
      // end
    // endgenerate
    //assign window[(N-1)*N + (N-1)] = pixel_in;   // newest sample, no register delay

// endmodule : sw_window_extractor
module sw_window_extractor #(
    parameter N = 3,
    parameter IMG_WIDTH = 32
) (
    input  logic clk,
    input  logic pixel_valid,
    input  logic [7:0] line_buf [N * IMG_WIDTH],
    input  logic [7:0] pixel_in,
    input  logic [$clog2(IMG_WIDTH)-1 : 0] col_idx,
    input  logic [$clog2(N)-1 : 0] active_row,
    input  logic [$clog2(N)-1 : 0] oldest_row,
    output logic [7:0] window [N*N]
);

    // Dynamic Shift registers based on N parameter
    logic [7:0] sr [N][N];

    always_ff @(posedge clk) begin
        if (pixel_valid) begin
            for (int i = 0; i < N; i++) begin
                logic [$clog2(N)-1 : 0] r_ptr;
                logic [7:0] in_pixel;

                // Dynamic Physical row pointer for any N
                r_ptr = (oldest_row + i) % N;

                // Fetch 1 single pixel per row
                if (i == N - 1) begin
                    in_pixel = pixel_in;
                end else begin
                    in_pixel = line_buf[r_ptr * IMG_WIDTH + col_idx];
                end

                // Dynamic Shift Loop for any N value
                for (int j = 0; j < N - 1; j++) begin
                    sr[i][j] <= sr[i][j + 1];
                end
                sr[i][N - 1] <= in_pixel;
            end
        end
    end

    // Fully Generic Flattening
    always_comb begin
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                window[i * N + j] = sr[i][j];
            end
        end
    end

endmodule : sw_window_extractor