module accelerator_top #(
  // Parameters
    parameter int unsigned  N               = 5,    // kernel dimension
    parameter int unsigned  PROD_W          = 17,   // product bit width (unsigned 8-bit * signed 8-bit = signed 17-bit)
    parameter int unsigned  IMG_WIDTH       = 32,   // input  image width
    parameter int unsigned  IMG_HEIGHT      = 32,   // input  image height
    parameter int unsigned  OUT_WIDTH       = IMG_WIDTH  - N + 1,   // output image width
    parameter int unsigned  OUT_HEIGHT      = IMG_HEIGHT - N + 1,   // output image heigth
    parameter int unsigned  IN_DEPTH        = IMG_WIDTH * IMG_HEIGHT,
    parameter int unsigned  OUT_DEPTH       = OUT_WIDTH * OUT_HEIGHT,
    parameter int unsigned  ACC_W           = 24,   // accumulated result bit width
    parameter int unsigned  OUT_W           = 16,   // convolution result bit width
    parameter int unsigned  OUT_MEM_ADDR_W  = $clog2(OUT_DEPTH),
    parameter int unsigned  K_MEM_ADDR_W    = $clog2(N*N)
) (
  // Inputs
    // clk & reset & SW Ctrl
    input  logic                        clk,        // system clk | +ve edge triggered
    input  logic                        rst_n,      // synch active-low reset
    input  logic                        start,      // starting processing command
    
    // source -> accelerator channel  DATAPATH
    input  logic                        pixel_valid,
    input  logic                        pixel_dropped,
    input  logic                        pixel_last,
    input  logic [OUT_MEM_ADDR_W-1 : 0] output_raddr,
    input  logic [7:0]                  pixel_in,

    // CFG PATH
    input  logic                        kernel_we,
    input  logic [K_MEM_ADDR_W-1 : 0]   kernel_waddr,
    input  logic signed [7:0]           kernel_wdata,

  // Outputs
    // accelerator -> source channel
    output logic                        busy,       // processing
    output logic                        done,       // processing is done
    output logic                        output_valid,
    output logic [OUT_W-1 : 0]          output_rdata
);

  // Needed internal signals
    logic [7:0] pixel_in_out;                 // input_if -> sliding_window
    logic pixel_out_valid;                    // input_if -> sliding_window
    logic pixel_out_last;                     // input_if -> sliding_window

    logic output_done;                        // output_ctrl -> global_ctrl

    logic signed [7:0] kernel [N*N];          // kernel_mem -> sliding_window

    logic window_valid;                       // sliding_window -> MAC
    logic window_last;                        // sliding_window -> MAC
    logic [7:0] window[N*N];                  // slidng_window -> MAC

    logic conv_valid;                         // MAC -> relu
    logic conv_last;                          // MAC -> ReLU
    logic signed [ACC_W-1 : 0] conv_result;   // MAC -> ReLU

    logic signed [ACC_W-1 : 0] relu_result;   // ReLU -> output_formatter
    logic relu_valid;                         // RelU -> output_formatter
    logic relu_last;                          // ReLU -> output_formatter

    logic signed [OUT_W-1 : 0] fmt_out;       // output_formatter -> output_mem
    logic fmt_valid;                          // output_formatter -> output_ctrl
    logic fmt_last;                           // output_formatter -> output_ctrl

    logic [OUT_MEM_ADDR_W-1 : 0] out_waddr;   // output_ctrl -> output_mem
    logic out_we;                             // output_ctrl -> output_mem


  input_if IF(
    .clk(clk),
    .rst_n(rst_n),
    .processing_en(busy),
    .pixel_valid(pixel_valid),
    .pixel_last(pixel_last),
    .pixel_dropped(pixel_dropped),
    .pixel_in(pixel_in),
    .pixel_out(pixel_in_out),
    .pixel_out_last(pixel_out_last),
    .pixel_out_valid(pixel_out_valid)
  );

  global_ctrl fsm(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .output_done(output_done),
    // .busy(busy),
    .done(done),
    .processing_en(busy)
  );

  kernel_mem #(
    .N(N)
  ) kernel_MEM(
    .clk(clk),
    .rst_n(rst_n),
    .processing_en(busy),
    .kernel_we(kernel_we),
    .kernel_waddr(kernel_waddr),
    .kernel_wdata(kernel_wdata),
    .kernel_coeff(kernel)
  );

  sliding_window #(
    .N(N),
    .IMG_WIDTH(IMG_WIDTH)
  ) SW(
    .clk(clk),
    .rst_n(rst_n),
    .pixel_valid(pixel_out_valid),
    .pixel_last(pixel_out_last),
    .pixel_in(pixel_in_out),
    .window_valid(window_valid),
    .window_last(window_last),
    .window(window)
  );

  MAC_array #(
    .N(N),
    .PROD_W(PROD_W)
  ) MAC(
    .window_valid(window_valid),
    .window_last(window_last),
    .window(window),
    .kernel(kernel),
    .conv_valid(conv_valid),
    .conv_last(conv_last),
    .conv_result(conv_result)
  );

  relu #(
    .N(N),
    .PROD_W(PROD_W)
  ) ReLU(
    .conv_result(conv_result),
    .conv_valid(conv_valid),
    .conv_last(conv_last),
    .relu_result(relu_result),
    .relu_valid(relu_valid),
    .relu_last(relu_last)
  );

  output_formatter #(
    .ACC_W(ACC_W),
    .OUT_W(OUT_W)
  ) output_fmt(
    .relu_valid(relu_valid),
    .relu_last(relu_last),
    .relu_result(relu_result),
    .pixel_out(fmt_out),
    .pixel_valid(fmt_valid),
    .pixel_last(fmt_last)
  );

  output_ctrl #(
    .N(N),
    .IMG_WIDTH(IMG_WIDTH),
    .IMG_HEIGHT(IMG_HEIGHT)
  ) output_fsm(
    .clk(clk),
    .rst_n(rst_n),
    .fmt_valid(fmt_valid),
    .fmt_last(fmt_last),
    .out_waddr(out_waddr),
    .out_we(out_we),
    .done(output_done)
  );

  output_mem #(
    .OUT_WIDTH(OUT_WIDTH),
    .OUT_HEIGHT(OUT_HEIGHT),
    .DATA_W(OUT_W)
  ) output_MEM(
    .clk(clk),
    .output_we(out_we),
    .output_waddr(out_waddr),
    .output_raddr(output_raddr),
    .output_wdata(fmt_out),
    .output_rdata(output_rdata),
    .output_valid(output_valid)
  );
endmodule