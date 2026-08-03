import accelerator_pkg::*;
module cfg (
    // Inputs
        input logic         clk,            // system clk
        input logic         rst_n,          // active-low synch rst_n
        input logic         cfg_wr_en,      // configuration write enable {Data Bus}
        input cfg_addr_t    cfg_addr,       // configuration write address {Data Bus}
        input logic  [15:0] cfg_wr_data,    // configuration write data {Data Bus}
    // Outputs
        output logic [15:0] img_width,      // image width
        output logic [15:0] img_height,     // image height
        output logic [4:0]  shift_amt,      // shift amount needed in output formatter
        output logic        relu_en,        // activation flag for ReLU module
        output logic        round_en        // enables rounding in output formatter
);
    always_ff @(posedge clk) begin
        // rst_n asserted
        if (!rst_n) begin
            img_width   <= 16'd32;
            img_height  <= 16'd32;
            shift_amt   <= 5'b0;
            relu_en     <= 1'b0;
            round_en    <= 1'b0;
        // cfg write enable asserted
        end else if (cfg_wr_en) begin
            case (cfg_addr)
                IMG_WIDTH:  img_width   <= cfg_wr_data;
                IMG_HEIGHT: img_height  <= cfg_wr_data;
                SHIFT_AMT:  shift_amt   <= cfg_wr_data[4:0];
                RELU_EN:    relu_en     <= cfg_wr_data[0];
                ROUND_EN:   round_en    <= cfg_wr_data[0];
                default:    /* Ignores Invalid address access */;
            endcase
        end
    end
    // Address Map
    // 0: IMG_WIDTH
    // 1: IMG_HEIGHT
    // 2: SHIFT_AMT
    // 3: RELU_EN
    // 4: ROUND_EN
    // 5: EMPTY
    // 6: EMPTY
    // 7: EMPTY
endmodule
