module output_mem # (
    parameter int OUT_WIDTH = 32,
    parameter int OUT_HEIGHT = 32,
    parameter int DATA_W = 16,
    parameter int DEPTH = OUT_WIDTH * OUT_HEIGHT,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    input  logic clk,                                   // active-high system clock
    input  logic output_we,                      // 1: synch write | 0: asynch read
    input  logic [DATA_W-1 : 0]      output_wdata,
    input  logic [ADDR_W-1 : 0]      output_addr,
    output logic [DATA_W-1 : 0]      output_rdata
);

logic [DATA_W-1:0] mem [0:(DEPTH)-1];		//every address refere to one pixel not one row

always_ff @(posedge clk)
	begin
		if (output_we)
			begin
				mem[output_addr] <= output_wdata;
			end
	end

assign output_rdata = (!output_we) ? mem[output_addr] : 'd0;

endmodule