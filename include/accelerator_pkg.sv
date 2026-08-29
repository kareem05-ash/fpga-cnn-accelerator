package accelerator_pkg;
  // Parameters
    parameter int unsigned  N           = 3;    // kernel dimension
    parameter int unsigned  PROD_W      = 17;   // product bit width (unsigned 8-bit * signed 8-bit = signed 17-bit)
    parameter int unsigned  IMG_WIDTH   = 32;   // input  image width
    parameter int unsigned  IMG_HEIGHT  = 32;   // input  image height
    parameter int unsigned  OUT_WIDTH   = 32;   // output image width
    parameter int unsigned  OUT_HEIGHT  = 32;   // output image heigth
    parameter int unsigned  ACC_W       = 24;   // accumulated result bit width
    parameter int unsigned  OUT_W       = 16;   // convolution result bit width

  // Enums
    typedef enum logic [1:0] {
      IDLE,
      PROCESSING,
      DONE
    } state_t;

    // typedef enum logic [1:0] {
    //     SHIFT_AMT,
    //     RELU_EN,
    //     ROUND_EN
    // } cfg_addr_t;

endpackage : accelerator_pkg
