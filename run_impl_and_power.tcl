# # #==============================================================================
# # # run_impl_and_power.tcl
# # #
# # # Usage (from the repo root, e.g. C:\Dana\NxN_CNN_SSCS\fpga-cnn-accelerator):
# # #   vivado -mode batch -source run_impl_and_power.tcl
# # #
# # # What it does:
# # #   1. Reads ./include/*.sv packages, then ./dut/*.sv sources
# # #   2. Reads constraints.xdc
# # #   3. Synthesizes accelerator_top with your chosen generics
# # #   4. IOB-packs output_rdata_reg/output_valid_reg (must happen right after
# # #      synth_design, once cells actually exist -- doing this via XDC before
# # #      synth_design silently matches nothing)
# # #   5. Implements with stronger PnR directives to push harder on timing
# # #   6. Writes a post-route checkpoint (needed for SAIF-based power later)
# # #   7. Dumps ALL failing paths (not just the worst one) to worst37.rpt
# # #   8. Reports baseline (default/vectorless) power, timing, utilization
# # #
# # # After this script finishes, go run a simulation (xsim) with real test
# # # vectors to produce power_activity.saif (see gen_saif.tcl), then come back
# # # and run report_power_saif.tcl to get the SAIF-based power number.
# # #==============================================================================

# # # ----------------------------- USER SETTINGS --------------------------------
# # set PART           "xc7z020clg400-1"   ;# <-- change to your actual target part
# # set DUT_DIR         "./dut"
# # set INCLUDE_DIR     "./include"
# # set OUT_DIR         "./impl_out"
# # set TOP_MODULE      "accelerator_top"

# # # RTL generics (must match accelerator_top's parameters that have no default)
# # set GEN_N           3
# # set GEN_PROD_W      17
# # set GEN_IMG_WIDTH   32
# # set GEN_IMG_HEIGHT  32
# # set GEN_ACC_W       24
# # set GEN_OUT_W       16
# # # ------------------------------------------------------------------------------

# # file mkdir $OUT_DIR

# # # 1) Read packages, then RTL
# # puts "INFO: Reading packages from $INCLUDE_DIR"
# # set pkg_files [glob -nocomplain $INCLUDE_DIR/*.sv]
# # if {[llength $pkg_files] == 0} {
# #     puts "WARNING: No .sv files found in $INCLUDE_DIR"
# # } else {
# #     read_verilog -sv $pkg_files
# # }

# # puts "INFO: Reading RTL from $DUT_DIR"
# # read_verilog -sv [glob -nocomplain $DUT_DIR/*.sv]

# # # 2) Read constraints
# # puts "INFO: Reading constraints.xdc"
# # read_xdc constraints.xdc

# # # 3) Synthesize
# # puts "INFO: Running synth_design on $TOP_MODULE (part=$PART)"
# # synth_design -top $TOP_MODULE -part $PART \
# #     -generic N=$GEN_N -generic PROD_W=$GEN_PROD_W \
# #     -generic IMG_WIDTH=$GEN_IMG_WIDTH -generic IMG_HEIGHT=$GEN_IMG_HEIGHT \
# #     -generic ACC_W=$GEN_ACC_W -generic OUT_W=$GEN_OUT_W

# # # Cells exist now -- safe to query/constrain them
# # set_property IOB TRUE [get_cells -hier -filter {NAME =~ *output_rdata_reg* || NAME =~ *output_valid_reg*}]

# # write_checkpoint -force $OUT_DIR/post_synth.dcp
# # report_utilization -file $OUT_DIR/util_post_synth.rpt
# # report_timing_summary -file $OUT_DIR/timing_post_synth.rpt

# # # 4) Implement -- stronger directives to push harder on timing closure
# # #    (single pass only -- this used to run twice, wasting runtime and
# # #    overwriting the first pass's results with a plain, no-directive pass)
# # puts "INFO: Running opt_design / place_design / route_design (aggressive directives)"
# # opt_design -directive Explore
# # place_design -directive ExtraTimingOpt
# # phys_opt_design -directive AggressiveExplore
# # route_design -directive AggressiveExplore

# # write_checkpoint -force $OUT_DIR/post_route.dcp

# # # 5) Full failing-path dump (not just the single worst path)
# # report_timing -sort_by group -max_paths 50 -path_type full -file $OUT_DIR/worst37.rpt

# # # 6) Post-route reports (utilization, timing, default/vectorless power)
# # report_utilization       -file $OUT_DIR/util_post_route.rpt
# # report_timing_summary    -file $OUT_DIR/timing_post_route.rpt
# # report_power              -file $OUT_DIR/power_default.rpt

# # # 7) Export a post-implementation timing-annotated Verilog netlist + SDF,
# # #    so your gate-level SAIF simulation reflects real routed timing/glitches.
# # write_verilog -force -mode timesim -sdf_anno true $OUT_DIR/netlist_timesim.v
# # write_sdf     -force $OUT_DIR/netlist_timesim.sdf

# # puts "=============================================================="
# # puts "DONE. post_route.dcp, gate-level timesim netlist + SDF are in $OUT_DIR"
# # puts "Check timing_post_route.rpt for WNS/TNS and worst37.rpt for the"
# # puts "full list of failing paths."
# # puts "Next steps:"
# # puts "  1) Simulate netlist_timesim.v (+ SDF) in xsim with real stimulus"
# # puts "     using gen_saif.tcl to produce $OUT_DIR/power_activity.saif"
# # puts "  2) Run report_power_saif.tcl to get the SAIF-based power number"
# # puts "  3) Run calc_fom.py to combine timing/area/power into your FoM"
# # puts "=============================================================="




# #==============================================================================
# # run_impl_and_power.tcl
# #
# # Usage (from the repo root, e.g. C:\Dana\NxN_CNN_SSCS\fpga-cnn-accelerator):
# #   vivado -mode batch -source run_impl_and_power.tcl
# #
# # What it does:
# #   1. Reads ./include/*.sv packages, then ./dut/*.sv sources
# #   2. Reads constraints.xdc
# #   3. Synthesizes accelerator_top with your chosen generics
# #   4. IOB-packs output_rdata_reg/output_valid_reg if they exist (guarded --
# #      will NOT abort the script if the names don't match, unlike before)
# #   5. Implements with stronger PnR directives to push harder on timing
# #   6. Writes a post-route checkpoint (needed for SAIF-based power later)
# #   7. Dumps ALL failing paths to all_violations.rpt
# #   8. Reports baseline (default/vectorless) power, timing, utilization
# #
# # Every report-generation step below is guarded with `catch` so that a
# # failure in one optional step (e.g. IOB property not matching, timesim
# # netlist export choking) can NEVER stop the rest of the script from
# # running and producing the required report files:
# #   power_default.rpt, timing_post_route.rpt, timing_post_synth.rpt,
# #   util_post_route.rpt, util_post_synth.rpt, all_violations.rpt
# #
# # After this script finishes, go run a simulation (xsim) with real test
# # vectors to produce power_activity.saif (see gen_saif.tcl), then come back
# # and run report_power_saif.tcl to get the SAIF-based power number.
# #==============================================================================

# # ----------------------------- USER SETTINGS --------------------------------
# set PART           "xc7z020clg400-1"   ;# <-- change to your actual target part
# set DUT_DIR         "./dut"
# set INCLUDE_DIR     "./include"
# set OUT_DIR         "./impl_out"
# set TOP_MODULE      "accelerator_top"

# # RTL generics (must match accelerator_top's parameters that have no default)
# set GEN_N           3
# set GEN_PROD_W      17
# set GEN_IMG_WIDTH   32
# set GEN_IMG_HEIGHT  32
# set GEN_ACC_W       24
# set GEN_OUT_W       16
# # ------------------------------------------------------------------------------

# file mkdir $OUT_DIR

# # Small helper: run a command, report success/failure, but NEVER let a
# # failure here stop the rest of the script.
# proc safe_run {desc cmd} {
#     if {[catch {uplevel 1 $cmd} err]} {
#         puts "WARNING: $desc failed -- $err"
#         return 0
#     } else {
#         puts "INFO: $desc OK"
#         return 1
#     }
# }

# # 1) Read packages, then RTL
# puts "INFO: Reading packages from $INCLUDE_DIR"
# set pkg_files [glob -nocomplain $INCLUDE_DIR/*.sv]
# if {[llength $pkg_files] == 0} {
#     puts "WARNING: No .sv files found in $INCLUDE_DIR"
# } else {
#     read_verilog -sv $pkg_files
# }

# puts "INFO: Reading RTL from $DUT_DIR"
# read_verilog -sv [glob -nocomplain $DUT_DIR/*.sv]

# # 2) Read constraints
# puts "INFO: Reading constraints.xdc"
# read_xdc constraints.xdc

# # 3) Synthesize (this one is NOT guarded -- if synthesis itself fails,
# #    nothing downstream can produce meaningful reports anyway, so we
# #    want the script to stop here and show the real synthesis error)
# puts "INFO: Running synth_design on $TOP_MODULE (part=$PART)"
# synth_design -top $TOP_MODULE -part $PART \
#     -generic N=$GEN_N -generic PROD_W=$GEN_PROD_W \
#     -generic IMG_WIDTH=$GEN_IMG_WIDTH -generic IMG_HEIGHT=$GEN_IMG_HEIGHT \
#     -generic ACC_W=$GEN_ACC_W -generic OUT_W=$GEN_OUT_W

# # 4) IOB-pack the output pipeline registers IF they exist under this name.
# #    Guarded: if nothing matches (e.g. RTL names changed), this just
# #    prints a warning and moves on instead of killing the whole run.
# set out_regs [get_cells -hier -filter {NAME =~ *output_rdata_reg* || NAME =~ *output_valid_reg*}]
# if {[llength $out_regs] > 0} {
#     puts "INFO: IOB-packing [llength $out_regs] output register cell(s)"
#     set_property IOB TRUE $out_regs
# } else {
#     puts "WARNING: no output_rdata_reg/output_valid_reg cells found -- skipping IOB TRUE"
# }

# safe_run "write_checkpoint post_synth.dcp" {write_checkpoint -force $OUT_DIR/post_synth.dcp}
# safe_run "report_utilization (post-synth)" {report_utilization -file $OUT_DIR/util_post_synth.rpt}
# safe_run "report_timing_summary (post-synth)" {report_timing_summary -file $OUT_DIR/timing_post_synth.rpt}

# # 5) Implement -- stronger directives to push harder on timing closure
# puts "INFO: Running opt_design / place_design / route_design (aggressive directives)"
# safe_run "opt_design"        {opt_design -directive Explore}
# safe_run "place_design"      {place_design -directive ExtraTimingOpt}
# safe_run "phys_opt_design"   {phys_opt_design -directive AggressiveExplore}
# safe_run "route_design"      {route_design -directive Explore}

# safe_run "write_checkpoint post_route.dcp" {write_checkpoint -force $OUT_DIR/post_route.dcp}

# # 6) Full failing-path dump (all violations, not just the worst one)
# safe_run "report_timing (all_violations.rpt)" \
#     {report_timing -sort_by group -max_paths 50 -path_type full -file $OUT_DIR/all_violations.rpt}

# # 7) Post-route reports (utilization, timing, default/vectorless power)
# #    -- these are the required deliverables, each generated independently
# #    so one failing doesn't block the others.
# safe_run "report_utilization (post-route)"    {report_utilization    -file $OUT_DIR/util_post_route.rpt}
# safe_run "report_timing_summary (post-route)" {report_timing_summary -file $OUT_DIR/timing_post_route.rpt}
# safe_run "report_power (default)"             {report_power          -file $OUT_DIR/power_default.rpt}

# # 8) Export a post-implementation timing-annotated Verilog netlist + SDF,
# #    so your gate-level SAIF simulation reflects real routed timing/glitches.
# #    Guarded -- this can be slow/finicky and must never block the reports above.
# safe_run "write_verilog (timesim netlist)" \
#     {write_verilog -force -mode timesim -sdf_anno true $OUT_DIR/netlist_timesim.v}
# safe_run "write_sdf" {write_sdf -force $OUT_DIR/netlist_timesim.sdf}

# # report_utilization -hierarchical -hierarchical_depth 4 -file impl_out/util_deep.rpt
# report_utilization -hierarchical -file impl_out/util_hierarchical.rpt
# report_utilization -cells -file impl_out/util_cells.rpt

# puts "=============================================================="
# puts "DONE. Reports written to $OUT_DIR (any WARNING above marks a"
# puts "step that failed but did NOT block the rest of the script):"
# puts "  util_post_synth.rpt   util_post_route.rpt"
# puts "  timing_post_synth.rpt timing_post_route.rpt"
# puts "  power_default.rpt     all_violations.rpt"
# puts ""
# puts "Next steps:"
# puts "  1) Simulate netlist_timesim.v (+ SDF) in xsim with real stimulus"
# puts "     using gen_saif.tcl to produce $OUT_DIR/power_activity.saif"
# puts "  2) Run report_power_saif.tcl to get the SAIF-based power number"
# puts "  3) Run calc_fom.py to combine timing/area/power into your FoM"
# puts "=============================================================="




#==============================================================================
# run_impl_and_power.tcl
#
# Usage (from the repo root, e.g. C:\Users\alah\Desktop\cnn_conv_acc):
#   vivado -mode batch -source run_impl_and_power.tcl
#
# What it does:
#   1. Reads ./include/*.sv packages, then ./dut/*.sv sources
#   2. Reads constraints.xdc
#   3. Synthesizes accelerator_top with your chosen generics
#   4. IOB-packs output_rdata_reg/output_valid_reg if they exist (guarded)
#   5. Implements with stronger PnR directives to push harder on timing
#   6. Writes a post-route checkpoint (needed for SAIF-based power later)
#   7. Dumps ALL failing paths to all_violations.rpt
#   8. Reports baseline (default/vectorless) power, timing, utilization
#   9. Writes a hierarchical utilization report + a per-cell-type
#      breakdown for u_addr_manager specifically
#
# Every report-generation step below is guarded with `catch` (via safe_run)
# so a failure in one optional step can NEVER stop the rest of the script
# from running. This version fixes a real bug from before: `report_utilization
# -cells` is not a valid flag in Vivado 2018.2 and was silently killing the
# script (unguarded) before it reached the final DONE banner.
#==============================================================================

# ----------------------------- USER SETTINGS --------------------------------
set PART           "xc7z020clg400-1"   ;# <-- change to your actual target part
set DUT_DIR         "./dut"
set INCLUDE_DIR     "./include"
set OUT_DIR         "./impl_out"
set TOP_MODULE      "accelerator_top"

# RTL generics (must match accelerator_top's parameters that have no default)
set GEN_N           3
set GEN_PROD_W      17
set GEN_IMG_WIDTH   32
set GEN_IMG_HEIGHT  32
set GEN_ACC_W       24
set GEN_OUT_W       16
# ------------------------------------------------------------------------------

file mkdir $OUT_DIR

# Small helper: run a command, report success/failure, but NEVER let a
# failure here stop the rest of the script.
proc safe_run {desc cmd} {
    if {[catch {uplevel 1 $cmd} err]} {
        puts "WARNING: $desc failed -- $err"
        return 0
    } else {
        puts "INFO: $desc OK"
        return 1
    }
}

# 1) Read packages, then RTL
puts "INFO: Reading packages from $INCLUDE_DIR"
set pkg_files [glob -nocomplain $INCLUDE_DIR/*.sv]
if {[llength $pkg_files] == 0} {
    puts "WARNING: No .sv files found in $INCLUDE_DIR"
} else {
    read_verilog -sv $pkg_files
}

puts "INFO: Reading RTL from $DUT_DIR"
read_verilog -sv [glob -nocomplain $DUT_DIR/*.sv]

# 2) Read constraints
puts "INFO: Reading constraints.xdc"
read_xdc constraints.xdc

# 3) Synthesize (this one is NOT guarded -- if synthesis itself fails,
#    nothing downstream can produce meaningful reports anyway, so we
#    want the script to stop here and show the real synthesis error)
puts "INFO: Running synth_design on $TOP_MODULE (part=$PART)"
synth_design -top $TOP_MODULE -part $PART \
    -generic N=$GEN_N -generic PROD_W=$GEN_PROD_W \
    -generic IMG_WIDTH=$GEN_IMG_WIDTH -generic IMG_HEIGHT=$GEN_IMG_HEIGHT \
    -generic ACC_W=$GEN_ACC_W -generic OUT_W=$GEN_OUT_W

# 4) IOB-pack the output pipeline registers IF they exist under this name.
#    Guarded: if nothing matches (e.g. RTL names changed), this just
#    prints a warning and moves on instead of killing the whole run.
set out_regs [get_cells -hier -filter {NAME =~ *output_rdata_reg* || NAME =~ *output_valid_reg*}]
if {[llength $out_regs] > 0} {
    puts "INFO: IOB-packing [llength $out_regs] output register cell(s)"
    set_property IOB TRUE $out_regs
} else {
    puts "WARNING: no output_rdata_reg/output_valid_reg cells found -- skipping IOB TRUE"
}

safe_run "write_checkpoint post_synth.dcp" {write_checkpoint -force $OUT_DIR/post_synth.dcp}
safe_run "report_utilization (post-synth)" {report_utilization -file $OUT_DIR/util_post_synth.rpt}
safe_run "report_timing_summary (post-synth)" {report_timing_summary -file $OUT_DIR/timing_post_synth.rpt}

# 5) Implement -- stronger directives to push harder on timing closure
puts "INFO: Running opt_design / place_design / route_design (aggressive directives)"
safe_run "opt_design"        {opt_design -directive Explore}
safe_run "place_design"      {place_design -directive ExtraTimingOpt}
safe_run "phys_opt_design"   {phys_opt_design -directive AggressiveExplore}
safe_run "route_design"      {route_design -directive Explore}

safe_run "write_checkpoint post_route.dcp" {write_checkpoint -force $OUT_DIR/post_route.dcp}

# 6) Full failing-path dump (all violations, not just the worst one)
safe_run "report_timing (all_violations.rpt)" \
    {report_timing -sort_by group -max_paths 50 -path_type full -file $OUT_DIR/all_violations.rpt}

# 7) Post-route reports (utilization, timing, default/vectorless power)
#    -- these are the required deliverables, each generated independently
#    so one failing doesn't block the others.
safe_run "report_utilization (post-route)"    {report_utilization    -file $OUT_DIR/util_post_route.rpt}
safe_run "report_timing_summary (post-route)" {report_timing_summary -file $OUT_DIR/timing_post_route.rpt}
safe_run "report_power (default)"             {report_power          -file $OUT_DIR/power_default.rpt}

# 8) Export a post-implementation timing-annotated Verilog netlist + SDF,
#    so your gate-level SAIF simulation reflects real routed timing/glitches.
#    Guarded -- this can be slow/finicky and must never block the reports above.
safe_run "write_verilog (timesim netlist)" \
    {write_verilog -force -mode timesim -sdf_anno true $OUT_DIR/netlist_timesim.v}
safe_run "write_sdf" {write_sdf -force $OUT_DIR/netlist_timesim.sdf}

# 9) Hierarchical utilization report (per-module LUT/FF/DSP/BRAM totals)
safe_run "report_utilization -hierarchical" \
    {report_utilization -hierarchical -file $OUT_DIR/util_hierarchical.rpt}

# 9b) Per-cell-type breakdown for u_addr_manager specifically.
#     NOTE: "report_utilization -cells" is NOT a valid flag in Vivado
#     2018.2 (this used to be here, unguarded, and was silently killing
#     the whole script before it reached the DONE banner). There is no
#     single-command equivalent -- this walks get_cells manually instead
#     and tallies by REF_NAME (LUT6, LUT3, FDRE, CARRY4, etc.).
safe_run "u_addr_manager cell breakdown" {
    set f [open $OUT_DIR/addr_mgr_cells.rpt w]
    set cells [get_cells -hierarchical -filter {NAME =~ "*u_addr_manager*"}]
    puts $f "Total cells under u_addr_manager: [llength $cells]"
    puts $f ""
    array unset counts
    array set counts {}
    foreach c $cells {
        set ref [get_property REF_NAME $c]
        if {![info exists counts($ref)]} { set counts($ref) 0 }
        incr counts($ref)
    }
    puts $f "--- Count by cell type ---"
    foreach ref [lsort [array names counts]] {
        puts $f "$ref : $counts($ref)"
    }
    puts $f ""
    puts $f "--- Full cell list ---"
    foreach c $cells {
        puts $f "[get_property REF_NAME $c]\t$c"
    }
    close $f
}

puts "=============================================================="
puts "DONE. Reports written to $OUT_DIR (any WARNING above marks a"
puts "step that failed but did NOT block the rest of the script):"
puts "  util_post_synth.rpt     util_post_route.rpt"
puts "  timing_post_synth.rpt   timing_post_route.rpt"
puts "  power_default.rpt       all_violations.rpt"
puts "  util_hierarchical.rpt   addr_mgr_cells.rpt"
puts ""
puts "Next steps:"
puts "  1) Simulate netlist_timesim.v (+ SDF) in xsim with real stimulus"
puts "     using gen_saif.tcl to produce $OUT_DIR/power_activity.saif"
puts "  2) Run report_power_saif.tcl to get the SAIF-based power number"
puts "  3) Run calc_fom.py to combine timing/area/power into your FoM"
puts "=============================================================="