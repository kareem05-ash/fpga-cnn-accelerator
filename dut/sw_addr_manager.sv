module sw_addr_manager #(
    // Parameters
        parameter N = 3,
        parameter IMG_WIDTH = 32
) (
    // Inputs
        input  logic        clk,            // global active-high clk
        input  logic        rst_n,          // synch active-low rst_n
        input  logic        pixel_valid,    // flags a valid pixel is being received
    // Outputs
        output logic [$clog2(IMG_WIDTH)-1 : 0]      col_idx,
        output logic [$clog2(N)-1 : 0]              stored_rows,
        output logic [$clog2(N)-1 : 0]              active_row,
        output logic [$clog2(N)-1 : 0]              oldest_row,
        output logic [$clog2(N * IMG_WIDTH)-1 : 0]  wr_addr

);
    logic [$clog2(N)-1 : 0] wr_row;
    assign wr_row   = (stored_rows == (N - 1))? active_row : stored_rows;
    assign wr_addr  = wr_row * IMG_WIDTH + col_idx;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            col_idx     <= '0;
            stored_rows <= '0;
            oldest_row  <= '0;
            active_row  <= N-1;
        end else if (pixel_valid) begin
            if (col_idx == IMG_WIDTH - 1) begin
                col_idx     <= '0;
                if (stored_rows < N - 1) begin
                    stored_rows <= stored_rows + 1;
                end else if (stored_rows == N - 1) begin
                    active_row  <= oldest_row;
                    oldest_row  <= (oldest_row == N-1)? '0 : oldest_row + 1;
                end
            end else begin
                col_idx     <= col_idx + 1;
            end
        end
    end
endmodule : sw_addr_manager
