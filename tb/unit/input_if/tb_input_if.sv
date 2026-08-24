import input_if_pkg::*;
module tb_input_if;
    // DUT Signals
        logic clk, processing_en, pixel_valid, pixel_last, pixel_dropped;
        logic pixel_out_valid, pixel_out_last;
        logic [7:0] pixel_in, pixel_out;
    // TB Needed Signals
        int unsigned tot, passed, failed_lines[$];
        Transaction tr;
        if_out_t dut_out, gm_out;
        logic [7:0] prev;
    // DUT Instantiation
        input_if dut (.*);

    // CLK Generation
        initial clk = 0;
        always #5ns clk = ~clk;

    // TASKs or FUNs
        function void print_summary(int unsigned total, pass);
            $display("\n--------------------------------------------------");
            $display("----------------- End Simulation -----------------");
            $display("--------------------------------------------------");
            $display(" > Total  Tests   : %0d", total);
            $display(" > PASSed Tests   : %0d", pass);
            $display(" > FAILed Tests   : %0d", total - pass);
            $display(" > PASS rate      : %.2f %%", 100 * (real'(pass) / real'(total)));
            $display(" > FAILed Lines   : %p\n", failed_lines);
        endfunction : print_summary

        function if_out_t gm(input Transaction tx, input logic [7:0] prev_pixel);
            if_out_t gmout;
            gmout.pixel_out         = (tx.processing_en && tx.pixel_valid && !tx.pixel_dropped)? tx.pixel_in : prev_pixel;
            gmout.pixel_out_valid   = tx.pixel_valid && tx.processing_en;
            gmout.pixel_out_last    = tx.pixel_valid && tx.processing_en && tx.pixel_last;
            return gmout;
        endfunction : gm

        function void check_print(Transaction tx, if_out_t dut, gmm);
            tot++;
            if ((dut.pixel_out === gmm.pixel_out) && 
                (dut.pixel_out_valid === gmm.pixel_out_valid) && 
                (dut.pixel_out_last === gmm.pixel_out_last)) begin
                passed++;
                $display(" %04d) [PASS] INPUTs en: %b, valid: %b, last: %b, dropped: %b, pixel: %02h | OUTPUTs valid: (dut: %b, gm: %b), last: (dut: %b, gm: %b), pixel: (dut: %02h, gm: %02h)",
                            tot,
                            tx.processing_en, tx.pixel_valid, tx.pixel_last, tx.pixel_dropped, tx.pixel_in,
                            dut.pixel_out_valid, gmm.pixel_out_valid,
                            dut.pixel_out_last , gmm.pixel_out_last,
                            dut.pixel_out      , gmm.pixel_out);
            end else begin
                failed_lines.push_back(tot);
                $display(" %04d) [FAIL] INPUTs en: %b, valid: %b, last: %b, dropped: %b, pixel: %02h | OUTPUTs valid: (dut: %b, gm: %b), last: (dut: %b, gm: %b), pixel: (dut: %02h, gm: %02h)",
                            tot,
                            tx.processing_en, tx.pixel_valid, tx.pixel_last, tx.pixel_dropped, tx.pixel_in,
                            dut.pixel_out_valid, gmm.pixel_out_valid,
                            dut.pixel_out_last , gmm.pixel_out_last,
                            dut.pixel_out      , gmm.pixel_out);
            end
        endfunction : check_print

        function void drive(Transaction tx);
            processing_en   = tx.processing_en;
            pixel_valid     = tx.pixel_valid;
            pixel_last      = tx.pixel_last;
            pixel_dropped   = tx.pixel_dropped;
            pixel_in        = tx.pixel_in;
        endfunction : drive

        function automatic void capture(ref if_out_t dutout);
            dutout.pixel_out_valid  = pixel_out_valid;
            dutout.pixel_out_last   = pixel_out_last;
            dutout.pixel_out        = pixel_out;
        endfunction : capture

        task automatic drive_check(Transaction tx, logic [7:0] prev_pixel, ref logic [7:0] pixel);
            @(negedge clk)  drive(tx);                  // drive dut
            @(negedge clk)  capture(dut_out);           // capture dut outputs
            gm_out = gm(tx, prev_pixel); // get gm outputs
            pixel  = gm_out.pixel_out;
            check_print(tx, dut_out, gm_out);
        endtask : drive_check
    // Test Cases
        initial begin
            tr = new();
            // tc-01) Deasserted `processing_en`       -> valid & last flags should be 0 while pixel_out hold the previous value
                $display("\n---------- tc-01) Deasserted `processing_en` ----------");
                tr.dasrt_all();     drive_check(tr, prev, prev);
                tr.asrt_en();       drive_check(tr, prev, prev);
            // tc-02) Deasserted 'pixel_valid`         -> valid & last flags should be 0 while pixel_out hold the previous value
                $display("\n---------- tc-02) Deasserted 'pixel_valid` ----------");
                tr.dasrt_all();     drive_check(tr, prev, prev);
                tr.asrt_valid();    drive_check(tr, prev, prev);
            // tc-03) Many pixels with 5% dropped      -> DUT shall hold the previous pixel_out for dropped pixels
                // coverd in tc-04)
            // tc-03&04) Complete image with Randomized Stimulus
                $display("\n---------- tc-03&04) Complete image with Randomized Stimulus ----------");
                repeat (25)
                    assert(tr.randomize())  drive_check(tr, prev, prev);
            // tc-01) Deasserted `processing_en`       -> valid & last flags should be 0 while pixel_out hold the previous value
                $display("\n---------- tc-01) Deasserted `processing_en` ----------");
                tr.dasrt_all();     drive_check(tr, prev, prev);
                tr.asrt_en();       drive_check(tr, prev, prev);
            // tc-02) Deasserted 'pixel_valid`         -> valid & last flags should be 0 while pixel_out hold the previous value
                $display("\n---------- tc-02) Deasserted 'pixel_valid` ----------");
                tr.dasrt_all();     drive_check(tr, prev, prev);
                tr.asrt_valid();    drive_check(tr, prev, prev);
            // End Simulation
                #10ns;
                print_summary(tot, passed);
                $stop;
        end

endmodule
