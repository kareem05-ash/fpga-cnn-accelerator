onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /output_formatter_tb/DUT/relu_result
add wave -noupdate -color Magenta -radix binary /output_formatter_tb/DUT/relu_valid
add wave -noupdate -radix binary /output_formatter_tb/DUT/relu_last
add wave -noupdate -radix decimal /output_formatter_tb/DUT/pixel_out
add wave -noupdate -color Magenta -radix binary /output_formatter_tb/DUT/pixel_valid
add wave -noupdate -radix binary /output_formatter_tb/DUT/pixel_last
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5 ns} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ns} {32 ns}
