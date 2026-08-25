onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sliding_window_tb/clk
add wave -noupdate /sliding_window_tb/rst_n
add wave -noupdate /sliding_window_tb/pixel_valid
add wave -noupdate /sliding_window_tb/pixel_last
add wave -noupdate /sliding_window_tb/pixel_in
add wave -noupdate -color Gold /sliding_window_tb/window_valid
add wave -noupdate -color Magenta /sliding_window_tb/window_last
add wave -noupdate /sliding_window_tb/exp_window_valid
add wave -noupdate /sliding_window_tb/exp_window_last
add wave -noupdate /sliding_window_tb/counter
add wave -noupdate /sliding_window_tb/num_passed
add wave -noupdate /sliding_window_tb/num_failed
add wave -noupdate /sliding_window_tb/test_case
add wave -noupdate /sliding_window_tb/row
add wave -noupdate /sliding_window_tb/col
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {449 ns} {534 ns}
