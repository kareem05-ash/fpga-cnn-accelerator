package param_pkg;
  parameter int unsigned N          = 5;
  parameter int unsigned IMG_WIDTH  = 32;
  parameter int unsigned IMG_HEIGHT = 32;
  parameter int unsigned OUT_WIDTH  = IMG_WIDTH - N + 1;
  parameter int unsigned OUT_HEIGHT = IMG_HEIGHT - N + 1;
  parameter int unsigned IN_DEPTH   = IMG_WIDTH * IMG_HEIGHT;
  parameter int unsigned OUT_DEPTH  = OUT_WIDTH * OUT_HEIGHT;
  parameter int unsigned OUT_W      = 16;
  parameter int unsigned ACC_W      = 24;
  parameter int unsigned PROD_W     = 17;
endpackage