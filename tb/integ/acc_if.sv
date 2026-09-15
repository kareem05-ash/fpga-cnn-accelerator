interface acc_if #(
	// parameters
	  parameter int unsigned  N,    // kernel dimension
    // parameter int unsigned  PROD_W          = 17,   // product bit width (unsigned 8-bit * signed 8-bit = signed 17-bit)
    parameter int unsigned  IMG_WIDTH,   // input  image width
    parameter int unsigned  IMG_HEIGHT,   // input  image height
    parameter int unsigned  OUT_WIDTH       = IMG_WIDTH  - N + 1,   // output image width
    parameter int unsigned  OUT_HEIGHT      = IMG_HEIGHT - N + 1,   // output image heigth
    // parameter int unsigned  IN_DEPTH        = IMG_WIDTH * IMG_HEIGHT,
    parameter int unsigned  OUT_DEPTH       = OUT_WIDTH * OUT_HEIGHT,
    // parameter int unsigned  ACC_W           = 24,   // accumulated result bit width
    parameter int unsigned  OUT_W,   // convolution result bit width
    parameter int unsigned  OUT_MEM_ADDR_W  = $clog2(OUT_DEPTH),
    parameter int unsigned  K_MEM_ADDR_W    = $clog2(N*N)
) (
  // Inputs
    input logic clk   // system clk | +ve edge triggered
);

	// Inputs
    // reset & SW Ctrl      
    logic                        rst_n;      // synch active-low reset
    logic                        start;      // starting processing command
    
    // source -> accelerator channel  DATAPATH
    logic                        pixel_valid;
    logic                        pixel_dropped;
    logic                        pixel_last;
    logic [OUT_MEM_ADDR_W-1 : 0] output_raddr;
    logic [7:0]                  pixel_in;

    // CFG PATH
    logic                        kernel_we;
    logic [K_MEM_ADDR_W-1 : 0]   kernel_waddr;
    logic signed [7:0]           kernel_wdata;

  // Outputs
    // accelerator -> source channel
    logic                        busy;       // processing
    logic                        done;       // processing is done
    logic                        output_valid;
    logic [OUT_W-1 : 0]          output_rdata;

	
endinterface