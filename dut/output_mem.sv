module output_mem # (
    parameter int OUT_WIDTH = 32,
    parameter int OUT_HEIGHT = 32,
    parameter int DATA_W = 16,
    parameter int DEPTH = OUT_WIDTH * OUT_HEIGHT,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    input  logic clk,                                   // active-high system clock
    input  logic output_we,
    // input  logic output_re,                // is no longer needed 
    input  logic [ADDR_W-1 : 0]      output_waddr,
    input  logic [ADDR_W-1 : 0]      output_raddr,      // asynch
    input  logic [DATA_W-1 : 0]      output_wdata,
    output logic [DATA_W-1 : 0]      output_rdata,
    output logic                     output_valid       // raddr < waddr
);

logic [DATA_W-1:0] mem [0:(DEPTH)-1];		//every address refere to one pixel not one row

always_ff @(posedge clk)
	begin
		if (output_we)
			begin
				mem[output_waddr] <= output_wdata;
			end
	end

// assign output_rdata = (!output_we) ? mem[output_addr] : 'd0;
assign output_rdata = mem[output_raddr];
assign output_valid = output_raddr < output_waddr;

initial begin
  for (int i = 0; i < DEPTH; i++) begin
    mem [i] = '0;
  end
end

endmodule