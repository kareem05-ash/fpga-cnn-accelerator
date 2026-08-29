onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /global_ctrl_tb/DUT/clk
add wave -noupdate -radix binary /global_ctrl_tb/DUT/rst_n
add wave -noupdate -color Magenta -radix binary /global_ctrl_tb/DUT/start
add wave -noupdate -color White -radix binary /global_ctrl_tb/DUT/output_done
add wave -noupdate /global_ctrl_tb/DUT/cu_state
add wave -noupdate -color Cyan -radix binary /global_ctrl_tb/DUT/busy
add wave -noupdate -radix binary /global_ctrl_tb/DUT/processing_en
add wave -noupdate -color Yellow -radix binary /global_ctrl_tb/DUT/done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {184 ns} 0}
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
WaveRestoreZoom {70 ns} {1070 ns}
