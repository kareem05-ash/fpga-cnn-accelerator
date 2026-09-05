interface acc_if;
	// parameters
	parameter int unsigned  N               = 5;    // kernel dimension
    parameter int unsigned  PROD_W          = 17;   // product bit width (unsigned 8-bit * signed 8-bit = signed 17-bit)
    parameter int unsigned  IMG_WIDTH       = 32;   // input  image width
    parameter int unsigned  IMG_HEIGHT      = 32;   // input  image height
    parameter int unsigned  OUT_WIDTH       = IMG_WIDTH  - N + 1;   // output image width
    parameter int unsigned  OUT_HEIGHT      = IMG_HEIGHT - N + 1;   // output image heigth
    parameter int unsigned  IN_DEPTH        = IMG_WIDTH * IMG_HEIGHT;
    parameter int unsigned  OUT_DEPTH       = OUT_WIDTH * OUT_HEIGHT;
    parameter int unsigned  ACC_W           = 24;   // accumulated result bit width
    parameter int unsigned  OUT_W           = 16;   // convolution result bit width
    parameter int unsigned  OUT_MEM_ADDR_W  = $clog2(OUT_DEPTH);
    parameter int unsigned  K_MEM_ADDR_W    = $clog2(N*N);
	

	// Inputs
    // clk & reset & SW Ctrl
    logic                        clk;        // system clk | +ve edge triggered
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

	
	modport DUT_side (
		input clk,rst_n,start,pixel_valid,pixel_dropped, pixel_last,output_raddr,pixel_in,
					kernel_we,kernel_waddr,kernel_wdata,
		output  busy,done,output_valid,output_rdata
	);
	
	modport TB_side (
		output clk,rst_n,start,pixel_valid,pixel_dropped, pixel_last,output_raddr,pixel_in,
					kernel_we,kernel_waddr,kernel_wdata,
		input  busy,done,output_valid,output_rdata
	);

	modport ASSERT_side (
		input  clk,rst_n,start,pixel_valid,pixel_dropped, pixel_last,output_raddr,pixel_in,
					kernel_we,kernel_waddr,kernel_wdata,busy,done,output_valid,output_rdata
	);
	
endinterface