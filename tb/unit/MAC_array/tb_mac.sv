import mac_pkg::*;
module tb_mac;
    // DUT Signals
        logic clk, rst_n, window_valid, window_last;
        logic signed [7:0] kernel [N*N];
        logic        [7:0] window [N*N];
        logic conv_valid, conv_last;
        logic signed [ACC_W-1 : 0] conv_result;
    // Needed TB Signals
        int unsigned total, passed, failed_lines[$];
        Transaction tr;
        mac_out_t dut_out, gmm_out;
    // DUT Instantiation
        MAC_array #(N, PROD_W, ACC_W) dut (.*);
    // CLK Generation
        initial clk = 0;
        always #5ns clk = ~clk;
    // TASKs or FUNs
        function void print_summary(int unsigned tot, pass);
            $display("\n--------------------------------------------------");
            $display("----------------- End Simulation -----------------");
            $display("--------------------------------------------------");
            $display(" > Total  Tests   : %0d", tot);
            $display(" > PASSed Tests   : %0d", pass);
            $display(" > FAILed Tests   : %0d", tot - pass);
            $display(" > PASS rate      : %.2f %%", 100 * (real'(pass) / real'(tot)));
            $display(" > FAILed Lines   : %p\n", failed_lines);
        endfunction : print_summary
    
        function mac_out_t gm(input Transaction tx);
            mac_out_t gmout;
            gmout.conv_valid    = tx.window_valid;
            gmout.conv_last     = tx.window_valid && tx.window_last;
            gmout.conv_result   = 0;
            for (int i = 0; i < N*N; i++) begin
                gmout.conv_result += signed'({1'b0, tx.window[i]}) * tx.kernel[i];
            end
            return gmout;
        endfunction : gm

        function void drive(Transaction tx);
            rst_n           = tx.rst_n;
            window_valid    = tx.window_valid;
            window_last     = tx.window_last;
            window          = tx.window;
            kernel          = tx.kernel;
        endfunction : drive

        function automatic void capture(ref mac_out_t dutout);
            dutout.conv_valid   = conv_valid;
            dutout.conv_last    = conv_last;
            dutout.conv_result  = conv_result;
        endfunction : capture

        function void check_print(Transaction tx, mac_out_t dut, gmm);
            total++;
            if ((dut.conv_valid === gmm.conv_valid) &&
                (dut.conv_last  === gmm.conv_last)  &&
                (dut.conv_result=== gmm.conv_result)) begin
                passed++;
                $display("\n %04d) [PASS] INPUTs rst_n: %b, valid: %b, last: %b", total, tx.rst_n, tx.window_valid, tx.window_last);
                $display("%06s ----- (window[i][j], kernel[i][j]) -> [window[i][j] * kernel[i][j]] -----", "");
                for (int i = 0; i < N; i++) begin
                    for (int j = 0; j < N; j++) begin
                        $write("%06s (%04d, %04d)", "", signed'({1'b0, window[i*N + j]}), kernel[i*N + j]);
                    end
                    for (int j = 0; j < N; j++) begin
                        $write("%06s [%06d]", "", int'(signed'({1'b0, window[i*N + j]}) * kernel[i*N + j]));
                    end
                    $display("");
                end
                $display("%06s OUTPUTs valid -> (dut: %b, gm: %b) last -> (dut: %b, gm: %b) conv_result -> (dut: %04d, gm: %04d)",
                            "",
                            dut.conv_valid , gmm.conv_valid,
                            dut.conv_last  , gmm.conv_last,
                            dut.conv_result, gmm.conv_result);
            end else begin
                // tx.print();
                failed_lines.push_back(total);
                $display("\n %04d) [FAIL] INPUTs rst_n: %b, valid: %b, last: %b", total, tx.rst_n, tx.window_valid, tx.window_last);
                $display("%06s ----- (window[i][j], kernel[i][j]) -> [window[i][j] * kernel[i][j] -----", "");
                for (int i = 0; i < N; i++) begin
                    for (int j = 0; j < N; j++) begin
                        $write("%06s (%04d, %04d)", "", window[i*N + j], kernel[i*N + j]);
                    end
                    for (int j = 0; j < N; j++) begin
                        $write("%06s [%04d]", "", window[i*N + j] * kernel[i*N + j]);
                    end
                    $display("");
                end
                $display("%06s OUTPUTs valid -> (dut: %b, gm: %b) last -> (dut: %b, gm: %b) conv_result -> (dut: %04d, gm: %04d)",
                            "",
                            dut.conv_valid , gmm.conv_valid,
                            dut.conv_last  , gmm.conv_last,
                            dut.conv_result, gmm.conv_result);
            end
        endfunction : check_print

        task automatic drive_check(Transaction tx);
            @(negedge clk)  drive(tx);
            @(negedge clk)  capture(dut_out);
            gmm_out = gm(tx);
            check_print(tx, dut_out, gmm_out);
        endtask : drive_check
    // Test Cases
        initial begin
            tr = new();
            // ---------- tc-01) 'window_valid' is deasserted ----------
                $display("\n---------- tc-01) 'window_valid' is deasserted ----------");
                tr.dasrt_all();     drive_check(tr);
            // ---------- tc-02) 'window_valid' is asserted ----------
                $display("\n---------- tc-02) 'window_valid' is asserted ----------");
                tr.asrt_valid();    drive_check(tr);
            // ---------- tc-03) Randomized stimulus to get valid 'conv_valid' 'conv_last' 'conv_result' ----------
                $display("\n---------- tc-03) Randomized stimulus to get valid 'conv_valid' 'conv_last' 'conv_result' ----------");
                repeat (10000)
                    assert(tr.randomize())      drive_check(tr);
            // ---------- tc-01) 'window_valid' is deasserted ----------
                $display("\n---------- tc-01) 'window_valid' is deasserted ----------");
                tr.dasrt_all();     drive_check(tr);
            // ---------- tc-02) 'window_valid' is asserted ----------
                $display("\n---------- tc-02) 'window_valid' is asserted ----------");
                tr.asrt_valid();    drive_check(tr);
            // End Simulation
                #10ns;
                print_summary(total, passed);
                $stop;
        end
endmodule
