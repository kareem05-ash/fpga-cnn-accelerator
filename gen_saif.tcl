#==============================================================================
# gen_saif.tcl
#
# Run this INSIDE an xsim simulation (post-synthesis timing simulation of
# netlist_timesim.v, back-annotated with netlist_timesim.sdf), driven by
# your real UVM testbench / real image stimulus (tb/integ + golden_model.py
# reference data), so the switching activity reflects actual operation.
#
# Typical usage from the Vivado/xsim Tcl console after the simulation
# snapshot is loaded and elaborated:
#
#   source gen_saif.tcl
#
# Or, non-interactively from a shell:
#   xsim <snapshot_name> -tclbatch gen_saif.tcl
#==============================================================================

# ----------------------------- USER SETTINGS --------------------------------
set SAIF_FILE   "./impl_out/power_activity.saif"
set DUT_SCOPE   "/tb_top/dut/inst"   ;# <-- change to your actual instance path
                                       ;# to the accelerator_top instance in
                                       ;# your testbench hierarchy
set SKIP_NS     1000                  ;# skip reset/startup transient
set RUN_NS      20000                 ;# steady-state capture window
                                       ;# (increase to cover a full image pass)
# ------------------------------------------------------------------------------

# 1) Let reset / startup settle before recording (excludes non-representative
#    init glitches from the activity numbers)
run ${SKIP_NS} ns

# 2) Open SAIF capture, scoped to the DUT instance only (keeps file size sane
#    and avoids polluting activity data with testbench-only signals)
open_saif $SAIF_FILE
log_saif [get_objects -r ${DUT_SCOPE}/*]

# 3) Run the representative steady-state window with real stimulus flowing
#    (make sure your testbench is actually streaming real image data /
#    kernel writes during this window, not idle)
run ${RUN_NS} ns

# 4) Close and flush the SAIF file
close_saif

puts "INFO: SAIF activity written to $SAIF_FILE"
puts "INFO: Now run report_power_saif.tcl in Vivado on post_route.dcp"
