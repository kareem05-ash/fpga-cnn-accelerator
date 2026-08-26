vlib work
vlog ../../../dut/output_formatter.sv transaction_pkg.sv output_formatter_tb.sv +cover -covercells
vsim -voptargs=+acc work.output_formatter_tb -cover
run 0
do wave.do
coverage save output_formatter_tb.ucdb -onexit
vcover report output_formatter_tb.ucdb -details -annotate -all -output coverage_output_formatter_rpt.txt
run -all
