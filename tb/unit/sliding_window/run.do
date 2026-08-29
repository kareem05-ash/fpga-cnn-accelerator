vlib work
vlog *.*v 
set IMG_WIDTH_RAND 5
echo "Running with IMG_WIDTH = $IMG_WIDTH_RAND"
vsim -voptargs=+acc -g IMG_WIDTH=$IMG_WIDTH_RAND work.sliding_window_tb
do wave.do
run -all