package input_if_pkg;
    typedef struct packed {
        logic [7:0] pixel_out;
        logic pixel_out_valid;
        logic pixel_out_last;
    } if_out_t;

    class Transaction;
        rand logic pixel_valid, pixel_last, pixel_dropped, processing_en;
        rand logic [7:0] pixel_in;

        constraint falgs_c {
            pixel_valid     dist {1'b0 := 1,  1'b1 := 9};
            pixel_last      dist {1'b0 := 9,  1'b1 := 1};
            pixel_dropped   dist {1'b0 := 8,  1'b1 := 2};
            processing_en   dist {1'b0 := 5,  1'b1 := 95};
        }

        function void asrt_en();
            pixel_valid     = 0;
            pixel_last      = 0;
            pixel_dropped   = 0;
            processing_en   = 1;
            pixel_in        = 0;
        endfunction : asrt_en

        function void asrt_valid();
            pixel_valid     = 1;
            pixel_last      = 0;
            pixel_dropped   = 0;
            processing_en   = 0;
            pixel_in        = 0;
        endfunction : asrt_valid

        function void dasrt_all();
            pixel_valid     = 0;
            pixel_last      = 0;
            pixel_dropped   = 0;
            processing_en   = 0;
            pixel_in        = 0;
        endfunction : dasrt_all
    endclass : Transaction
endpackage : input_if_pkg
