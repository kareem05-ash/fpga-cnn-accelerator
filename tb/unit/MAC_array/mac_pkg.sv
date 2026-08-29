package mac_pkg;
    parameter N = 3;
    parameter PROD_W = 17;
    parameter ACC_W = PROD_W + $clog2(N);

    typedef struct packed {
        logic conv_valid;
        logic conv_last;
        logic signed [ACC_W-1 : 0] conv_result;
    } mac_out_t;

    class Transaction;
        rand logic rst_n, window_valid, window_last;
        rand logic          [7:0] window [N*N];
        rand logic signed   [7:0] kernel [N*N];

        constraint rst_n_c {rst_n dist {1'b0 := 5, 1'b1 := 95};}
        constraint flags_c {
            window_valid dist {1'b0 := 5, 1'b1 := 95};
            window_last  dist {1'b0 := 97, 1'b1 := 3};
        }

        function void asrt_valid();
            window_valid    = 1;
            window_last     = 0;
        endfunction : asrt_valid

        function void dasrt_all();
            window_valid    = 0;
            window_last     = 0;
        endfunction : dasrt_all

        function void print();
          $display(" > rst_n: %b, valid: %b, last: %b", rst_n, window_valid, window_last);
          $display(" > window: %p", window);
          $display(" > kernel: %p", kernel);
        endfunction
    endclass : Transaction
endpackage : mac_pkg
