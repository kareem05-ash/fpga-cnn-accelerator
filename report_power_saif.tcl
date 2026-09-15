#==============================================================================
# report_power_saif.tcl
#
# Usage (from repo root, after gen_saif.tcl has produced the SAIF file):
#   vivado -mode batch -source report_power_saif.tcl
#
# Loads the post-route checkpoint, reads the switching activity captured
# from real-stimulus simulation, and reports SAIF-based dynamic power at
# the design's operating frequency (as constrained in constraints.xdc).
#==============================================================================

# ----------------------------- USER SETTINGS --------------------------------
set OUT_DIR      "./impl_out"
set DCP_FILE     "$OUT_DIR/post_route.dcp"
set SAIF_FILE    "$OUT_DIR/power_activity.saif"
set SAIF_SCOPE   ""   ;# set e.g. "tb_top/dut/inst" if hierarchy needs remapping
# ------------------------------------------------------------------------------

puts "INFO: Opening $DCP_FILE"
open_checkpoint $DCP_FILE

puts "INFO: Reading SAIF activity from $SAIF_FILE"
if {$SAIF_SCOPE ne ""} {
    read_saif -file $SAIF_FILE -scope $SAIF_SCOPE
} else {
    read_saif -file $SAIF_FILE
}

report_power -file $OUT_DIR/power_saif.rpt

puts "=============================================================="
puts "DONE. SAIF-based power report: $OUT_DIR/power_saif.rpt"
puts "Compare against $OUT_DIR/power_default.rpt (vectorless estimate)"
puts "to show the difference in your writeup if useful."
puts "Next: run calc_fom.py to combine power/timing/area into your FoM"
puts "=============================================================="
