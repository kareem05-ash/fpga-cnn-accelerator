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



module sw_window_extractor #(
    // Parameters
        parameter N = 3,
        parameter IMG_WIDTH = 32
) (
    // Inputs
        input  logic clk,
        input  logic [7:0]  line_buf [N * IMG_WIDTH],
        input  logic [7:0]  pixel_in,
        input  logic [$clog2(N*IMG_WIDTH)-1 : 0]  wr_addr,   // CURRENT write address
                                                              // (same signal already used to
                                                              // write line_buf this cycle --
                                                              // col_idx/active_row/oldest_row
                                                              // are no longer needed here)
    // Outputs
        output logic [7:0] window [N*N]
);
    localparam int DEPTH  = N * IMG_WIDTH;
    localparam int ADDR_W = $clog2(DEPTH);

    // ------------------------------------------------------------------
    // Why this is cheap where the old version was expensive:
    //
    // The old extractor computed 8 independent, fully dynamic addresses
    // into line_buf every cycle (each depending on BOTH oldest_row and
    // col_idx), which forced synthesis to build 8 separate ~DEPTH-to-1
    // multiplexer trees in fabric logic (this was 825 of 1077 total
    // design LUTs).
    //
    // Here, each of the N-1 history rows instead does exactly ONE
    // SEQUENTIAL read per cycle, at a fixed constant offset behind the
    // current (monotonically circular) write pointer. Since the write
    // pointer already wraps correctly across row boundaries, a fixed
    // offset automatically tracks the right physical row with no
    // runtime row-selection logic at all -- just "current write address
    // + a compile-time constant, wrapped once if it overflows DEPTH"
    // (a single comparator + conditional subtract, not a wide mux).
    // The N adjacent column taps per row then come from a small N-deep
    // shift register fed by that one sequential read, instead of N
    // independent random reads. The read address is deliberately chosen
    // far enough AHEAD in line_buf that, once delayed by the N-deep
    // shift register, it lands on the correct value at the correct time
    // -- this pre-compensates for the shift register's latency.
    //
    // NOTE on width: rd_addr_raw = wr_addr + OFFSET_ADD can be as large
    // as 2*(DEPTH-1), which needs ADDR_W+1 bits, NOT ADDR_W bits. Sizing
    // it at only ADDR_W bits silently truncates the sum modulo 2^ADDR_W
    // *before* the ">= DEPTH" correction runs, which is wrong whenever
    // DEPTH isn't a power of two. Using ADDR_W+1 bits for the raw sum
    // guarantees no truncation occurs before the modulo-DEPTH correction.
    // ------------------------------------------------------------------

    genvar i, j;
    generate
      for (i = 0; i < N-1; i++) begin : gen_hist_row
        localparam int BEHIND_ROWS               = (N-1) - i;
        localparam logic [ADDR_W-1:0] OFFSET_ADD  = DEPTH - (BEHIND_ROWS * IMG_WIDTH);

        logic [ADDR_W:0]   rd_addr_raw;     // ADDR_W+1 bits -- wide enough for the un-wrapped sum
        logic [ADDR_W:0]   rd_addr_wrapped; // ADDR_W+1-bit temp holding the subtracted value
        logic [ADDR_W-1:0] rd_addr;
        logic [7:0]        shift_reg [N];

        assign rd_addr_raw     = {1'b0, wr_addr} + {1'b0, OFFSET_ADD};
        assign rd_addr_wrapped = rd_addr_raw - DEPTH;
        assign rd_addr         = (rd_addr_raw >= DEPTH) ? rd_addr_wrapped[ADDR_W-1:0]
                                                         : rd_addr_raw[ADDR_W-1:0];

        always_ff @(posedge clk) begin
          for (int k = 0; k < N-1; k++)
            shift_reg[k] <= shift_reg[k+1];
          shift_reg[N-1] <= line_buf[rd_addr];
        end

        for (j = 0; j < N; j++) begin : gen_tap
          assign window[i*N + j] = shift_reg[j];
        end
      end
    endgenerate

    // Active row: unlike the history rows above, there is no line_buf
    // entry to "read ahead of time" for a pixel that hasn't arrived yet
    // -- the active row is fed live off the input stream. So only the
    // OLDER N-1 samples of this row are held in a shift register; the
    // newest sample (the pixel arriving THIS cycle) is wired straight
    // from pixel_in, combinationally, with no register delay. Sizing
    // this the same way as the history rows (N-deep, all-registered)
    // would leave the newest tap one full cycle stale.
    logic [7:0] active_shift [N-1];
    always_ff @(posedge clk) begin
      for (int k = 0; k < N-2; k++)
        active_shift[k] <= active_shift[k+1];
      active_shift[N-2] <= pixel_in;
    end

    generate
      for (j = 0; j < N-1; j++) begin : gen_active_tap
        assign window[(N-1)*N + j] = active_shift[j];
      end
    endgenerate
    assign window[(N-1)*N + (N-1)] = pixel_in;   // newest sample, no register delay

endmodule : sw_window_extractor