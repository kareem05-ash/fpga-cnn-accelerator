import accelerator_pkg::*;
module cfg (
    // Inputs
        input logic         clk,            // system clk
        input logic         rst_n,          // active-low synch rst_n
        input logic         cfg_wr_en,      // configuration write enable {Data Bus}
        input cfg_addr_t    cfg_addr,       // configuration write address {Data Bus}
        input logic  [4:0]  cfg_wr_data,    // configuration write data {Data Bus}
    // Outputs
        output logic [4:0]  shift_amt,      // shift amount needed in output formatter
        output logic        relu_en,        // activation flag for ReLU module
        output logic        round_en        // enables rounding in output formatter
);
    always_ff @(posedge clk) begin
        // rst_n asserted
        if (!rst_n) begin
            shift_amt   <= '0;
            relu_en     <= '0;
            round_en    <= '0;
        // cfg write enable asserted
        end else if (cfg_wr_en) begin
            case (cfg_addr)
                SHIFT_AMT:  shift_amt   <= cfg_wr_data[4:0];
                RELU_EN:    relu_en     <= cfg_wr_data[0];
                ROUND_EN:   round_en    <= cfg_wr_data[0];
                default:    /* Ignores Invalid address access */;
            endcase
        end
    end
    // Address Map
    // 0: SHIFT_AMT
    // 1: RELU_EN
    // 2: ROUND_EN
    // 3: EMPTY
endmodule
