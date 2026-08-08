package accelerator_pkg;
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        DONE
    } state_t;
  
    typedef enum logic [1:0] {
        SHIFT_AMT,
        RELU_EN,
        ROUND_EN
    } cfg_addr_t;
endpackage : accelerator_pkg
