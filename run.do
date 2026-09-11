#.main clear

vlog -f files.txt +define+IS_ACTIVE=1

vsim -c work.acc_tb +UVM_VERBOSITY=UVM_LOW

#vsim -voptargs=+acc work.acc_tb +UVM_VERBOSITY=UVM_LOW
#do wave.do

run -all

quit
