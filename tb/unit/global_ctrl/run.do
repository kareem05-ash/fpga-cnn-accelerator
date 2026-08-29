vlib work
vlog ../../../include/accelerator_pkg.sv ../../../dut/global_ctrl.sv global_ctrl_transaction_pkg.sv global_ctrl_tb.sv +cover -covercells
vsim -voptargs=+acc work.global_ctrl_tb -cover
run 0
do wave.do
coverage save global_ctrl_tb.ucdb -onexit
vcover report global_ctrl_tb.ucdb -details -annotate -all -output coverage_global_ctrl_rpt.txt
run -all
