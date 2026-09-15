#.main clear

vlog -f files.txt +define+IS_ACTIVE=1

#vsim -c work.acc_tb +UVM_VERBOSITY=UVM_MEDIUM

vsim -voptargs=+acc work.acc_tb +UVM_VERBOSITY=UVM_MEDIUM
do wave.do

run -all

quit
