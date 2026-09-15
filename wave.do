onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TOP -color gold /acc_tb/dut/clk
add wave -noupdate -expand -group TOP -color cyan /acc_tb/dut/rst_n
add wave -noupdate -expand -group TOP -color {Violet Red} /acc_tb/dut/start
add wave -noupdate -expand -group TOP -color {Slate Blue} /acc_tb/dut/pixel_valid
add wave -noupdate -expand -group TOP -color {Violet Red} /acc_tb/dut/pixel_dropped
add wave -noupdate -expand -group TOP -color cyan /acc_tb/dut/pixel_last
add wave -noupdate -expand -group TOP -color magenta -radix unsigned /acc_tb/dut/pixel_in
add wave -noupdate -expand -group TOP -color blue /acc_tb/dut/output_raddr
add wave -noupdate -expand -group TOP /acc_tb/dut/kernel_we
add wave -noupdate -expand -group TOP -color blue /acc_tb/dut/kernel_waddr
add wave -noupdate -expand -group TOP -color {Medium Slate Blue} /acc_tb/dut/kernel_wdata
add wave -noupdate -expand -group TOP /acc_tb/dut/busy
add wave -noupdate -expand -group TOP /acc_tb/dut/done
add wave -noupdate -expand -group TOP -color {Dark Orchid} /acc_tb/dut/output_valid
add wave -noupdate -expand -group TOP -radix unsigned /acc_tb/dut/output_rdata
add wave -noupdate -group OUT_FSM /acc_tb/dut/output_fsm/fmt_valid
add wave -noupdate -group OUT_FSM /acc_tb/dut/output_fsm/out_waddr
add wave -noupdate -group OUT_FSM -color cyan /acc_tb/dut/output_fsm/fmt_last
add wave -noupdate -group OUT_FSM /acc_tb/dut/output_fsm/done
add wave -noupdate -expand -group FSM /acc_tb/dut/fsm/cu_state
add wave -noupdate -expand -group FSM /acc_tb/dut/fsm/nx_state
add wave -noupdate -expand -group FSM /acc_tb/dut/fsm/done
add wave -noupdate -expand -group FSM /acc_tb/dut/fsm/processing_en
add wave -noupdate -group ReLU -radix unsigned /acc_tb/dut/ReLU/relu_result
add wave -noupdate -group ReLU /acc_tb/dut/ReLU/relu_valid
add wave -noupdate -group ReLU -color cyan /acc_tb/dut/ReLU/relu_last
add wave -noupdate -group MAC -radix unsigned /acc_tb/dut/MAC/window_valid
add wave -noupdate -group MAC -radix unsigned /acc_tb/dut/MAC/window_last
add wave -noupdate -group MAC -radix decimal /acc_tb/dut/MAC/conv_result
add wave -noupdate -group MAC -radix unsigned /acc_tb/dut/MAC/conv_valid
add wave -noupdate -group MAC -color cyan -radix unsigned /acc_tb/dut/MAC/conv_last
add wave -noupdate -group SW -color gold -radix unsigned /acc_tb/dut/SW/pixel_in
add wave -noupdate -group SW /acc_tb/dut/SW/window_valid
add wave -noupdate -group SW -color cyan /acc_tb/dut/SW/window_last
add wave -noupdate -group SW -radix unsigned -childformat {{{/acc_tb/dut/SW/window[0]} -radix unsigned} {{/acc_tb/dut/SW/window[1]} -radix unsigned} {{/acc_tb/dut/SW/window[2]} -radix unsigned} {{/acc_tb/dut/SW/window[3]} -radix unsigned} {{/acc_tb/dut/SW/window[4]} -radix unsigned} {{/acc_tb/dut/SW/window[5]} -radix unsigned} {{/acc_tb/dut/SW/window[6]} -radix unsigned} {{/acc_tb/dut/SW/window[7]} -radix unsigned} {{/acc_tb/dut/SW/window[8]} -radix unsigned}} -expand -subitemconfig {{/acc_tb/dut/SW/window[0]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[1]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[2]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[3]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[4]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[5]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[6]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[7]} {-height 15 -radix unsigned} {/acc_tb/dut/SW/window[8]} {-height 15 -radix unsigned}} /acc_tb/dut/SW/window
add wave -noupdate -group SW -color magenta -radix unsigned -childformat {{{/acc_tb/dut/SW/line_buf[0]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[1]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[2]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[3]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[4]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[5]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[6]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[7]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[8]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[9]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[10]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[11]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[12]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[13]} -radix unsigned} {{/acc_tb/dut/SW/line_buf[14]} -radix unsigned}} -subitemconfig {{/acc_tb/dut/SW/line_buf[0]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[1]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[2]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[3]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[4]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[5]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[6]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[7]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[8]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[9]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[10]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[11]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[12]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[13]} {-color magenta -height 15 -radix unsigned} {/acc_tb/dut/SW/line_buf[14]} {-color magenta -height 15 -radix unsigned}} /acc_tb/dut/SW/line_buf
add wave -noupdate -group IF /acc_tb/dut/IF/pixel_out_last
add wave -noupdate -group IF /acc_tb/dut/IF/pixel_out_valid
add wave -noupdate -group IF -color gold -radix unsigned -childformat {{{/acc_tb/dut/IF/pixel_out[7]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[6]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[5]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[4]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[3]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[2]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[1]} -radix unsigned} {{/acc_tb/dut/IF/pixel_out[0]} -radix unsigned}} -subitemconfig {{/acc_tb/dut/IF/pixel_out[7]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[6]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[5]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[4]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[3]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[2]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[1]} {-color gold -height 15 -radix unsigned} {/acc_tb/dut/IF/pixel_out[0]} {-color gold -height 15 -radix unsigned}} /acc_tb/dut/IF/pixel_out
add wave -noupdate -expand -group OUT_MEM -radix unsigned /acc_tb/dut/output_MEM/output_valid
add wave -noupdate -expand -group OUT_MEM -radix unsigned /acc_tb/dut/output_MEM/output_rdata
add wave -noupdate -expand -group OUT_MEM -radix unsigned /acc_tb/dut/output_MEM/output_raddr
add wave -noupdate -expand -group OUT_MEM -radix unsigned -childformat {{{/acc_tb/dut/output_MEM/mem[0]} -radix unsigned -childformat {{{/acc_tb/dut/output_MEM/mem[0][15]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][14]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][13]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][12]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][11]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][10]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][9]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][8]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][7]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][6]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][5]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][4]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][3]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][2]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][1]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][0]} -radix unsigned}}} {{/acc_tb/dut/output_MEM/mem[1]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[2]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[3]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[4]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[5]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[6]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[7]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[8]} -radix unsigned}} -subitemconfig {{/acc_tb/dut/output_MEM/mem[0]} {-height 15 -radix unsigned -childformat {{{/acc_tb/dut/output_MEM/mem[0][15]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][14]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][13]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][12]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][11]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][10]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][9]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][8]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][7]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][6]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][5]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][4]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][3]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][2]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][1]} -radix unsigned} {{/acc_tb/dut/output_MEM/mem[0][0]} -radix unsigned}}} {/acc_tb/dut/output_MEM/mem[0][15]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][14]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][13]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][12]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][11]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][10]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][9]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][8]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][7]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][6]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][5]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][4]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][3]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][2]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][1]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[0][0]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[1]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[2]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[3]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[4]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[5]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[6]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[7]} {-height 15 -radix unsigned} {/acc_tb/dut/output_MEM/mem[8]} {-height 15 -radix unsigned}} /acc_tb/dut/output_MEM/mem
add wave -noupdate -group SW_Addr -radix unsigned /acc_tb/dut/SW/u_addr_manager/col_idx
add wave -noupdate -group SW_Addr -radix unsigned /acc_tb/dut/SW/u_addr_manager/stored_rows
add wave -noupdate -group SW_Addr -radix unsigned /acc_tb/dut/SW/u_addr_manager/active_row
add wave -noupdate -group SW_Addr -radix unsigned /acc_tb/dut/SW/u_addr_manager/oldest_row
add wave -noupdate -group SW_Addr -radix unsigned /acc_tb/dut/SW/u_addr_manager/wr_addr
add wave -noupdate -group FMT -radix unsigned /acc_tb/dut/output_fmt/pixel_out
add wave -noupdate -group FMT -radix unsigned /acc_tb/dut/output_fmt/pixel_valid
add wave -noupdate -group FMT -radix unsigned /acc_tb/dut/output_fmt/pixel_last
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {388033 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 66
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
configure wave -timelineunits ps
update
WaveRestoreZoom {329901 ps} {487900 ps}
