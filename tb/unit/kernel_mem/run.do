vlib work
vlog *.*v
vsim -voptargs=+acc work.kernel_mem_tb
add wave *
run -all