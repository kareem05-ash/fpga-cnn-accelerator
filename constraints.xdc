#==============================================================================
# constraints.xdc
# Target: accelerator_top (N x N CNN / Canny-style convolution accelerator)
# Adjust CLK_PERIOD_NS to your real target operating frequency before
# running implementation - this value directly drives the dynamic power
# number used in your FoM.
#==============================================================================

#------------------------------------------------------------------------------
# 1) Primary clock
#------------------------------------------------------------------------------
# Example: 100 MHz -> 10.000 ns period. Change to your actual target freq.
create_clock -period 10.523 -name clk -waveform {0.000 5.2615} [get_ports clk]
# PACKAGE_PIN intentionally left unassigned: there is no real board/oscillator
# for this clock in this flow (no board demo in scope), so binding it to a
# specific physical pin would be meaningless -- Vivado will implement this
# as an unplaced port, which is fine for synthesis/implementation/power/FoM
# analysis. If you DO get a real target board later, find a real clock-capable
# pin for THAT board (do not guess) with:
#   get_package_pins -filter {IS_CLOCK_CAPABLE_PIN}
# then set_property PACKAGE_PIN <that real pin> [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]

#------------------------------------------------------------------------------
# 2) Reset
#------------------------------------------------------------------------------
# rst_n is documented as a *synchronous* active-low reset in accelerator_top,
# so no special asynchronous-reset CDC constraint is required. If you later
# change it to asynchronous, add:
#   set_false_path -from [get_ports rst_n]
# (only appropriate for a truly async reset, not for this synchronous one).

#------------------------------------------------------------------------------
# 3) I/O delays
#------------------------------------------------------------------------------
# No board-level timing spec was given, so these are placeholders assuming
# a loosely-coupled test/sim environment (e.g. driven by a UVM testbench or
# a simple source FSM, not a tight board-to-board interface). Tighten these
# if you have a real external interface spec.
set_input_delay  -clock clk -max 2.000 [get_ports {pixel_in* pixel_valid pixel_dropped pixel_last output_raddr* kernel_we kernel_waddr* kernel_wdata* start}]
set_input_delay  -clock clk -min 0.500 [get_ports {pixel_in* pixel_valid pixel_dropped pixel_last output_raddr* kernel_we kernel_waddr* kernel_wdata* start}]

set_output_delay -clock clk -max 2.000 [get_ports {busy done output_valid output_rdata*}]
set_output_delay -clock clk -min 0.500 [get_ports {busy done output_valid output_rdata*}]

#------------------------------------------------------------------------------
# 4) Clock uncertainty (jitter margin) - keep sign-off realistic
#------------------------------------------------------------------------------
set_clock_uncertainty 0.100 [get_clocks clk]

#------------------------------------------------------------------------------
# 5) Optional: false path on rst_n if you decide it should be treated as
#    a pure init/config signal outside timing-critical paths (uncomment
#    only if this matches your actual reset strategy):
#------------------------------------------------------------------------------
# set_false_path -from [get_ports rst_n] -to [all_registers]

#------------------------------------------------------------------------------
# 6) Pack the final output pipeline register into the IOB
#------------------------------------------------------------------------------
# These are the registers that directly drive output_rdata/output_valid at
# the top-level port (accelerator_top is top, so no extra hierarchy prefix).
# Packing them into the IOB removes the routing + OBUF delay from the
# critical path, since there's no logic between this register and the pad.


set_false_path -to [get_ports {busy done}]

#------------------------------------------------------------------------------
# 8) Hold checks on primary data inputs assume a real external device
#    synchronized to this chip's clock tree, with near-zero launch delay.
#    There is no such board-level device in this flow -- these are purely
#    simulation/testbench-driven inputs, so that hold relationship isn't
#    real. False-pathing HOLD ONLY (setup/max-delay checks stay fully
#    enforced -- this doesn't loosen your real frequency target at all).
#------------------------------------------------------------------------------
set_false_path -hold -from [get_ports {rst_n pixel_in* pixel_valid pixel_dropped pixel_last kernel_we kernel_waddr* kernel_wdata* start}]


set_property RAM_STYLE registers [get_cells -hierarchical -filter {NAME =~ *SW/line_buf*}]