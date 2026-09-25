# ============================================================================
# report_fom.tcl
#
# General, reusable POST-IMPLEMENTATION METRICS / REPORTING script.
# Vivado 2018.2 Tcl (Zynq-7000 / general).
#
# This script only MEASURES and REPORTS. It never modifies RTL, constraints,
# clocks, or synthesis/implementation settings, and never decides "good" vs
# "bad" beyond stating the Vivado-reported PASS/FAIL timing status.
#
# Usage (from the Vivado Tcl console, after implementation):
#
#     open_run impl_1
#     source report_fom.tcl
#
# Nothing here is hardcoded to today's numbers: every value is re-extracted
# from report_utilization / report_timing_summary / report_power each time
# you source it, so it is safe to rerun after every RTL/constraint change.
#
# All console output is also mirrored to a log file (see section 0b),
# so after sourcing this script you'll have both the console printout
# and a saved copy in report_fom_output.txt.
# ============================================================================

# ----------------------------------------------------------------------------
# 0. CONFIGURATION
# ----------------------------------------------------------------------------

# Architectural throughput assumption, in OUTPUTS PER CYCLE (not per second).
# Change this if your architecture's throughput differs.
set OUTPUTS_PER_CYCLE 1.0

# Temporary report file names (created in the current working directory).
set UTIL_FILE    "utilization_tmp.rpt"
set TIMING_FILE  "timing_tmp.rpt"
set POWER_FILE   "power_tmp.rpt"

# Set to 1 to delete the temporary report files after the summary is printed.
set DELETE_TEMP_REPORTS 0

# Number of significant digits used when printing the FoM in "Ne-X" form.
set FOM_SIG_DIGITS 4


# ----------------------------------------------------------------------------
# 0b. TEE ALL STDOUT TO A LOG FILE
# ----------------------------------------------------------------------------
set REPORT_LOG_FILE "report_fom_output.txt"
set report_log_fh [open $REPORT_LOG_FILE w]

# Save the real puts under a new name, then replace puts with a tee version.
rename puts _real_puts

proc puts {args} {
    global report_log_fh

    set nonewline 0
    if {[lindex $args 0] eq "-nonewline"} {
        set nonewline 1
        set args [lrange $args 1 end]
    }

    if {[llength $args] == 1} {
        # Plain "puts text" (or "puts -nonewline text") -> goes to console AND file
        set text [lindex $args 0]
        if {$nonewline} {
            _real_puts -nonewline $text
            _real_puts -nonewline $report_log_fh $text
        } else {
            _real_puts $text
            _real_puts $report_log_fh $text
        }
    } else {
        # An explicit channel was given (e.g. "puts $fh ...") - pass through untouched
        if {$nonewline} {
            eval _real_puts -nonewline $args
        } else {
            eval _real_puts $args
        }
    }
}


# ----------------------------------------------------------------------------
# HELPERS
# ----------------------------------------------------------------------------

# Format a value for printing, passing "N/A" straight through instead of
# crashing [format] on a non-numeric string.
proc safe_fmt {value fmt} {
    if {$value eq "N/A"} { return "N/A" }
    return [format $fmt $value]
}

# Formats a number as "{integer mantissa}e{exponent}" with the given number
# of significant digits, e.g. 0.001656 -> "1656e-6" (4 sig figs).
# Passes "N/A" straight through like safe_fmt does.
proc format_sci_int {value {sig_digits 4}} {
    if {$value eq "N/A"} { return "N/A" }
    set value [expr {double($value)}]
    if {$value == 0.0} { return "0e0" }

    set sign ""
    if {$value < 0} { set sign "-"; set value [expr {-$value}] }

    set exp [expr {int(floor(log10($value)))}]
    set scale [expr {$exp - ($sig_digits - 1)}]
    set mantissa [expr {round($value / pow(10, $scale))}]

    # Handle rounding carrying over an extra digit, e.g. 9999.6 -> 10000
    set max_mantissa [expr {int(pow(10, $sig_digits))}]
    if {$mantissa >= $max_mantissa} {
        set mantissa [expr {$mantissa / 10}]
        incr scale
    }

    return "${sign}${mantissa}e${scale}"
}

# Generic single-value extractor for Vivado's "| Label | value | ... |"
# report tables. Returns "N/A" if the label is not found (extraction
# failure), never a fabricated 0. `pattern` controls what counts as the
# value (e.g. {[0-9]+} for integer utilization counts, {[0-9]+\.[0-9]+}
# for decimal power values). `label` is plain text (parens/etc. are
# escaped automatically) - do not pre-escape it yourself.
proc get_table_value {data label pattern} {
    set safe_label [regsub -all {[\\^$.|?*+()\[\]{}]} $label {\\&}]
    set re "^\\|\\s*${safe_label}\\s*\\|\\s*(${pattern})\\s*\\|"
    foreach line [split $data "\n"] {
        if {[regexp $re $line -> value]} {
            return $value
        }
    }
    return "N/A"
}


# ----------------------------------------------------------------------------
# 1. CHECK IMPLEMENTATION STATE
# ----------------------------------------------------------------------------

proc check_design_open {} {
    if {[catch {current_design} err]} {
        puts "ERROR: No design is currently open in Vivado."
        puts "       Run 'open_run <impl_run>' (e.g. 'open_run impl_1')"
        puts "       and then source this script again."
        return 0
    }
    return 1
}

if {![check_design_open]} {
    return
}

# Best-effort design/device identification (never hardcoded).
set TOP_MODULE "N/A"
catch {set TOP_MODULE [get_property TOP [current_design]]}

set DEVICE_PART "N/A"
catch {set DEVICE_PART [get_property PART [current_design]]}

set IMPL_RUN "N/A"
catch {set IMPL_RUN [get_property PARENT.RUN_TYPE [current_run]]}
if {$IMPL_RUN eq "N/A"} {
    catch {set IMPL_RUN [current_run]}
}


# ----------------------------------------------------------------------------
# 2. GENERATE REPORTS
# ----------------------------------------------------------------------------

set have_util 0
if {![catch {report_utilization -file $UTIL_FILE} err]} {
    set have_util 1
} else {
    puts "WARNING: report_utilization failed: $err"
}

set have_timing 0
if {![catch {report_timing_summary -delay_type max -report_unconstrained \
        -file $TIMING_FILE} err]} {
    set have_timing 1
} else {
    puts "WARNING: report_timing_summary failed: $err"
}

set have_power 0
if {![catch {report_power -file $POWER_FILE} err]} {
    set have_power 1
} else {
    puts "WARNING: report_power failed: $err"
}


# ----------------------------------------------------------------------------
# 3. PARSE UTILIZATION
# ----------------------------------------------------------------------------

proc parse_utilization {file} {
    if {![file exists $file]} {
        return [list "N/A" "N/A" "N/A" "N/A" "N/A" "N/A" "N/A" "N/A"]
    }
    set fh [open $file r]
    set data [read $fh]
    close $fh

    set luts        [get_table_value $data "Slice LUTs"        {[0-9]+}]
    set lut_logic    [get_table_value $data "LUT as Logic"      {[0-9]+}]
    set lut_mem      [get_table_value $data "LUT as Memory"     {[0-9]+}]
    set ffs          [get_table_value $data "Slice Registers"   {[0-9]+}]
    set brams        [get_table_value $data "Block RAM Tile"    {[0-9]+}]
    set dsps         [get_table_value $data "DSPs"              {[0-9]+}]
    set slices       [get_table_value $data "Slice"              {[0-9]+}]
    set iobs         [get_table_value $data "Bonded IOB"        {[0-9]+}]

    return [list $luts $ffs $brams $dsps $slices $iobs $lut_logic $lut_mem]
}

if {$have_util} {
    lassign [parse_utilization $UTIL_FILE] \
        LUTS FFS BRAMS DSPS SLICES IOBS LUT_LOGIC LUT_MEM
} else {
    set LUTS "N/A"; set FFS "N/A"; set BRAMS "N/A"; set DSPS "N/A"
    set SLICES "N/A"; set IOBS "N/A"; set LUT_LOGIC "N/A"; set LUT_MEM "N/A"
}


# ----------------------------------------------------------------------------
# 4. PARSE TIMING
# ----------------------------------------------------------------------------

# Extracts WNS / TNS / Failing Endpoints / Total Endpoints from the
# "Design Timing Summary" table. Locates the table by its header first,
# so it is not confused by the structurally identical per-clock rows in
# the "Intra Clock Table" further down the report.
proc parse_design_timing_summary {data} {
    set lines [split $data "\n"]
    set n [llength $lines]
    for {set i 0} {$i < $n} {incr i} {
        set line [lindex $lines $i]
        if {[regexp {^\s*WNS\(ns\)\s+TNS\(ns\)} $line]} {
            for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
                set dline [lindex $lines $j]
                if {[regexp {^\s*(-?[0-9]+\.[0-9]+)\s+(-?[0-9]+\.[0-9]+)\s+([0-9]+)\s+([0-9]+)\s+(-?[0-9]+\.[0-9]+)\s+(-?[0-9]+\.[0-9]+)} \
                        $dline -> wns tns failing total wpws tpws]} {
                    return [list $wns $tns $failing $total]
                }
            }
        }
    }
    return [list "N/A" "N/A" "N/A" "N/A"]
}

# PASS/FAIL comes straight from Vivado's own verdict text when present;
# falls back to the sign of WNS only if that text can't be found.
proc parse_timing_status {data wns} {
    if {[regexp {All user specified timing constraints are met} $data]} {
        return "PASS"
    }
    if {[regexp {Timing constraints are not met} $data]} {
        return "FAIL"
    }
    if {$wns ne "N/A"} {
        if {[expr {double($wns)}] >= 0} { return "PASS" } else { return "FAIL" }
    }
    return "N/A"
}

# Extracts every clock in the "Clock Summary" table: {name period_ns freq_MHz}
# for each. Does NOT assume a clock named "clk" and handles multiple clocks.
proc parse_clock_summary {data} {
    set clocks {}
    set lines [split $data "\n"]
    set n [llength $lines]
    set capturing 0
    for {set i 0} {$i < $n} {incr i} {
        set line [lindex $lines $i]
        if {[regexp {^Clock\s+Waveform\(ns\)} $line]} {
            set capturing 1
            continue
        }
        if {$capturing} {
            if {[string trim $line] eq ""} { break }
            if {[regexp {^-+\s} $line]} { continue }
            if {[regexp {^(\S+)\s+\{[^\}]*\}\s+([0-9]+\.[0-9]+)\s+([0-9]+\.[0-9]+)} \
                    $line -> cname cperiod cfreq]} {
                lappend clocks [list $cname $cperiod $cfreq]
            }
        }
    }
    return $clocks
}

set WNS "N/A"; set TNS "N/A"; set FAILING_EPS "N/A"; set TOTAL_EPS "N/A"
set TIMING_STATUS "N/A"
set CLOCKS {}

if {$have_timing} {
    set fh [open $TIMING_FILE r]
    set timing_data [read $fh]
    close $fh

    lassign [parse_design_timing_summary $timing_data] WNS TNS FAILING_EPS TOTAL_EPS
    set TIMING_STATUS [parse_timing_status $timing_data $WNS]
    set CLOCKS [parse_clock_summary $timing_data]

    if {$WNS eq "N/A"} {
        puts "WARNING: Could not extract WNS/TNS from timing report."
        puts "         Implementation may be incomplete, or the report format differs."
    }
    if {[llength $CLOCKS] == 0} {
        puts "WARNING: Could not extract any clock from the Clock Summary table."
    }
} else {
    puts "WARNING: No timing report available - is implementation complete?"
}

# ------------------------------------------------------------------
# Estimated Fmax
#
# Fmax is DERIVED, not directly reported by Vivado. It uses the
# PRIMARY clock (the first clock listed in the Clock Summary table)
# together with the design's worst-case WNS:
#
#   critical_period = primary_clock_period - WNS
#   Estimated Fmax  = 1000 / critical_period   (MHz, period in ns)
#
# If WNS >= 0 (timing met), critical_period < primary_clock_period,
# so Estimated Fmax is reported as >= the constrained frequency -
# i.e. "at least this fast", not a claim of the exact ceiling.
#
# NOTE for multi-clock designs: WNS above is the worst slack across
# ALL clocks in the design, so this estimate is only a rough,
# single-number approximation when more than one clock is present.
# All detected clocks and their own constrained frequencies are
# still printed individually below.
# ------------------------------------------------------------------

set PRIMARY_CLOCK_NAME   "N/A"
set PRIMARY_CLOCK_PERIOD "N/A"
set PRIMARY_CLOCK_FREQ   "N/A"
set FMAX "N/A"

if {[llength $CLOCKS] > 0} {
    lassign [lindex $CLOCKS 0] PRIMARY_CLOCK_NAME PRIMARY_CLOCK_PERIOD PRIMARY_CLOCK_FREQ
}

if {$WNS ne "N/A" && $PRIMARY_CLOCK_PERIOD ne "N/A"} {
    set critical_period [expr {double($PRIMARY_CLOCK_PERIOD) - double($WNS)}]
    if {$critical_period > 0} {
        set FMAX [expr {1000.0 / $critical_period}]
    }
}


# ----------------------------------------------------------------------------
# 5. PARSE POWER
# ----------------------------------------------------------------------------

proc parse_power {file} {
    if {![file exists $file]} {
        return [list "N/A" "N/A" "N/A" "N/A"]
    }
    set fh [open $file r]
    set data [read $fh]
    close $fh

    set total      [get_table_value $data "Total On-Chip Power (W)" {[0-9]+\.[0-9]+}]
    set dynamic    [get_table_value $data "Dynamic (W)"             {[0-9]+\.[0-9]+}]
    set static     [get_table_value $data "Device Static (W)"       {[0-9]+\.[0-9]+}]
    set confidence [get_table_value $data "Confidence Level"        {[A-Za-z]+}]

    return [list $total $dynamic $static $confidence]
}

if {$have_power} {
    lassign [parse_power $POWER_FILE] TOTAL_POWER DYNAMIC_POWER STATIC_POWER POWER_CONFIDENCE
    if {$TOTAL_POWER eq "N/A"} {
        puts "WARNING: Could not extract Total On-Chip Power from power report."
    }
} else {
    set TOTAL_POWER "N/A"; set DYNAMIC_POWER "N/A"; set STATIC_POWER "N/A"
    set POWER_CONFIDENCE "N/A"
}


# ----------------------------------------------------------------------------
# 6. CALCULATE DERIVED METRICS: Hardware Cost / FoM
# ----------------------------------------------------------------------------

# Throughput, made explicit: this is OUTPUTS PER CYCLE, not outputs/second.
# If your FoM definition needs outputs/second instead, multiply by an
# achieved-frequency estimate (e.g. $FMAX) - do that explicitly at the
# point of use rather than silently mixing units here.
set THROUGHPUT_OUTPUTS_PER_CYCLE $OUTPUTS_PER_CYCLE

proc calculate_hardware_cost {luts dsps brams} {
    if {$luts eq "N/A" || $dsps eq "N/A" || $brams eq "N/A"} { return "N/A" }
    return [expr {double($luts) + 50.0 * double($dsps) + 100.0 * double($brams)}]
}

proc calculate_fom {throughput power hw_cost} {
    if {$power eq "N/A" || $hw_cost eq "N/A"} { return "N/A" }
    if {double($power) == 0.0 || double($hw_cost) == 0.0} { return "N/A" }
    return [expr {$throughput / (double($power) * double($hw_cost))}]
}

set HARDWARE_COST [calculate_hardware_cost $LUTS $DSPS $BRAMS]
set FOM [calculate_fom $THROUGHPUT_OUTPUTS_PER_CYCLE $TOTAL_POWER $HARDWARE_COST]


# ----------------------------------------------------------------------------
# 7. PRINT REPORT
# ----------------------------------------------------------------------------

proc print_report {} {
    upvar 1 TOP_MODULE TOP_MODULE
    upvar 1 DEVICE_PART DEVICE_PART
    upvar 1 IMPL_RUN IMPL_RUN
    upvar 1 LUTS LUTS
    upvar 1 LUT_LOGIC LUT_LOGIC
    upvar 1 LUT_MEM LUT_MEM
    upvar 1 FFS FFS
    upvar 1 BRAMS BRAMS
    upvar 1 DSPS DSPS
    upvar 1 SLICES SLICES
    upvar 1 IOBS IOBS
    upvar 1 CLOCKS CLOCKS
    upvar 1 WNS WNS
    upvar 1 TNS TNS
    upvar 1 FAILING_EPS FAILING_EPS
    upvar 1 TOTAL_EPS TOTAL_EPS
    upvar 1 TIMING_STATUS TIMING_STATUS
    upvar 1 PRIMARY_CLOCK_NAME PRIMARY_CLOCK_NAME
    upvar 1 FMAX FMAX
    upvar 1 TOTAL_POWER TOTAL_POWER
    upvar 1 DYNAMIC_POWER DYNAMIC_POWER
    upvar 1 STATIC_POWER STATIC_POWER
    upvar 1 POWER_CONFIDENCE POWER_CONFIDENCE
    upvar 1 THROUGHPUT_OUTPUTS_PER_CYCLE THROUGHPUT_OUTPUTS_PER_CYCLE
    upvar 1 HARDWARE_COST HARDWARE_COST
    upvar 1 FOM FOM
    upvar 1 FOM_SIG_DIGITS FOM_SIG_DIGITS

    puts ""
    puts "============================================================"
    puts "                 FPGA IMPLEMENTATION REPORT"
    puts "============================================================"

    puts ""
    puts "DESIGN"
    puts "------------------------------------------------------------"
    puts [format "%-30s : %s" "Top Module" $TOP_MODULE]
    puts [format "%-30s : %s" "Device" $DEVICE_PART]
    puts [format "%-30s : %s" "Implementation Run" $IMPL_RUN]

    puts ""
    puts "RESOURCE UTILIZATION (measured)"
    puts "------------------------------------------------------------"
    puts [format "%-30s : %s" "Slice LUTs" $LUTS]
    puts [format "%-30s : %s" "  LUT as Logic" $LUT_LOGIC]
    puts [format "%-30s : %s" "  LUT as Memory" $LUT_MEM]
    puts [format "%-30s : %s" "Slice Registers (FFs)" $FFS]
    puts [format "%-30s : %s" "Block RAM Tiles" $BRAMS]
    puts [format "%-30s : %s" "DSPs" $DSPS]
    puts [format "%-30s : %s" "Occupied Slices" $SLICES]
    puts [format "%-30s : %s" "Bonded IOBs" $IOBS]

    puts ""
    puts "TIMING (measured)"
    puts "------------------------------------------------------------"
    if {[llength $CLOCKS] == 0} {
        puts "  No clocks extracted from timing report."
    } else {
        foreach c $CLOCKS {
            lassign $c cname cperiod cfreq
            puts [format "%-30s : %s ns  (%s MHz)" "Clock '$cname' Period" $cperiod $cfreq]
        }
    }
    puts [format "%-30s : %s ns" "WNS" $WNS]
    puts [format "%-30s : %s ns" "TNS" $TNS]
    puts [format "%-30s : %s" "Failing Endpoints" $FAILING_EPS]
    puts [format "%-30s : %s" "Total Endpoints" $TOTAL_EPS]
    puts [format "%-30s : %s" "Timing Status" $TIMING_STATUS]

    puts ""
    puts "POWER (measured)"
    puts "------------------------------------------------------------"
    puts [format "%-30s : %s W" "Total On-Chip Power" $TOTAL_POWER]
    puts [format "%-30s : %s W" "Dynamic Power" $DYNAMIC_POWER]
    puts [format "%-30s : %s W" "Device Static Power" $STATIC_POWER]
    puts [format "%-30s : %s" "Confidence Level" $POWER_CONFIDENCE]

    puts ""
    puts "DERIVED METRICS"
    puts "------------------------------------------------------------"
    if {[llength $CLOCKS] > 0} {
        puts [format "%-30s : %s" "Fmax based on clock" $PRIMARY_CLOCK_NAME]
    }
    puts [format "%-30s : %s MHz" "Estimated Fmax" [safe_fmt $FMAX {%.3f}]]
    puts [format "%-30s : %s outputs/cycle" "Throughput" $THROUGHPUT_OUTPUTS_PER_CYCLE]
    puts [format "%-30s : %s" "Hardware Cost (LUT+50*DSP+100*BRAM)" [safe_fmt $HARDWARE_COST {%.0f}]]
    puts [format "%-30s : %s" "FoM (Throughput / (Power*Cost))" [format_sci_int $FOM $FOM_SIG_DIGITS]]

    puts ""
    puts "============================================================"
}

print_report


# ----------------------------------------------------------------------------
# 8. OPTIONAL CLEANUP
# ----------------------------------------------------------------------------

if {$DELETE_TEMP_REPORTS} {
    catch {file delete -force $UTIL_FILE}
    catch {file delete -force $TIMING_FILE}
    catch {file delete -force $POWER_FILE}
}


# ----------------------------------------------------------------------------
# 9. RESTORE PUTS / CLOSE LOG FILE
# ----------------------------------------------------------------------------
flush $report_log_fh
close $report_log_fh
rename puts {}
rename _real_puts puts