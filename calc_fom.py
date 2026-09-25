#!/usr/bin/env python3
"""
calc_fom.py

Parses Vivado's post-route reports (power_saif.rpt or power_default.rpt,
util_post_route.rpt, timing_post_route.rpt) and computes:

  1) Achievable Fmax, from the timing report:
         Fmax (MHz) = 1000 / (constraint_period_ns - WNS_ns)
     (WNS >= 0 means timing met, so Fmax > constrained frequency;
      WNS < 0 means timing failed, so Fmax < constrained frequency --
      NOT a valid sign-off number in that case.)

  2) The Figure of Merit exactly as defined by the
     IEEE SSCS Egypt Chapter 2026 Student Design Competition:

                          Throughput
     FoM = -----------------------------------------
           Power x (LUTs + 50*DSPs + 100*BRAMs)

     - Throughput is measured in OUTPUT PIXELS PER CYCLE.
     - Power is in Watts (Total On-Chip Power, as reported by Vivado).
     - A HIGHER FoM indicates a MORE efficient design.

Usage examples
--------------
python calc_fom.py --impl-dir ./impl_out --throughput-px-per-cycle 1
python calc_fom.py --impl-dir ./impl_out --output-pixels 900 --total-cycles 5400
"""

import argparse
import re
import os


def parse_power_report(path):
    """Extract Total On-Chip Power / Dynamic / Static (W) from a Vivado
    report_power .rpt file."""
    if not os.path.isfile(path):
        print(f"WARNING: power report not found: {path}")
        return {}

    text = open(path, "r", errors="ignore").read()
    metrics = {}

    m = re.search(r"Total On-Chip Power \(W\)\s*\|\s*([\d.]+)", text)
    if m:
        metrics["total_power_w"] = float(m.group(1))

    m = re.search(r"Dynamic \(W\)\s*\|\s*([\d.]+)", text)
    if m:
        metrics["dynamic_power_w"] = float(m.group(1))

    m = re.search(r"Device Static \(W\)\s*\|\s*([\d.]+)", text)
    if m:
        metrics["static_power_w"] = float(m.group(1))

    return metrics


def parse_utilization_report(path):
    """Extract LUT / FF / DSP / BRAM used counts from report_utilization."""
    if not os.path.isfile(path):
        print(f"WARNING: utilization report not found: {path}")
        return {}

    text = open(path, "r", errors="ignore").read()
    metrics = {}

    patterns = {
        "luts_used": r"Slice LUTs\D*\|\s*(\d+)",
        "ff_used": r"Slice Registers\D*\|\s*(\d+)",
        "dsp_used": r"DSPs\D*\|\s*(\d+)",
        # can be fractional (e.g. 0.5 for a half-used 36Kb BRAM)
        "bram_used": r"Block RAM Tile\D*\|\s*([\d.]+)",
    }
    for key, pat in patterns.items():
        m = re.search(pat, text)
        if m:
            metrics[key] = float(m.group(1))

    return metrics


def parse_timing_report(path):
    """Extract WNS/TNS and the constrained clock period/frequency from
    report_timing_summary, so we can compute the achievable Fmax."""
    if not os.path.isfile(path):
        print(f"WARNING: timing report not found: {path}")
        return {}

    text = open(path, "r", errors="ignore").read()
    metrics = {}

    m = re.search(
        r"WNS\(ns\)\s+TNS\(ns\).*?\n\s*(-?[\d.]+)\s+(-?[\d.]+)",
        text,
        re.DOTALL,
    )
    if m:
        metrics["wns_ns"] = float(m.group(1))
        metrics["tns_ns"] = float(m.group(2))

    metrics["timing_met"] = "All user specified timing constraints are met." in text

    # Clock Summary table, e.g.:
    #   clk    {0.000 7.500}      15.000          66.667
    m = re.search(
        r"^\S+\s+\{[\d.]+\s+[\d.]+\}\s+([\d.]+)\s+([\d.]+)\s*$",
        text,
        re.MULTILINE,
    )
    if m:
        metrics["constraint_period_ns"] = float(m.group(1))
        metrics["constraint_freq_mhz"] = float(m.group(2))

    return metrics


def compute_fmax_mhz(constraint_period_ns, wns_ns):
    """
    Achievable Fmax = 1 / (constraint_period - WNS)
    WNS >= 0 -> Fmax higher than the constrained frequency (there was slack)
    WNS <  0 -> design does NOT actually meet the constrained frequency;
                this number is only a projection, not a signed-off result.
    """
    if constraint_period_ns is None or wns_ns is None:
        return None
    min_period_ns = constraint_period_ns - wns_ns
    if min_period_ns <= 0:
        return None
    return 1000.0 / min_period_ns


def compute_fom(power_w, luts, dsps, brams, throughput_px_per_cycle):
    """
    FoM = Throughput / (Power * (LUTs + 50*DSPs + 100*BRAMs))
    per IEEE SSCS Egypt Chapter 2026 Student Design Competition spec.
    Higher is better.
    """
    denom_resources = luts + 50.0 * dsps + 100.0 * brams
    denom = power_w * denom_resources
    if denom == 0:
        return None, denom_resources
    return throughput_px_per_cycle / denom, denom_resources


def main():
    ap = argparse.ArgumentParser(
        description="Compute achievable Fmax and the IEEE SSCS Egypt 2026 "
                     "FoM = Throughput / (Power * (LUTs + 50*DSPs + 100*BRAMs))")
    ap.add_argument("--impl-dir", default="./impl_out",
                     help="Directory containing Vivado reports")
    ap.add_argument("--power-report", default=None,
                     help="Override path to power report "
                          "(defaults to power_saif.rpt, falls back to "
                          "power_default.rpt if not found)")

    ap.add_argument("--throughput-px-per-cycle", type=float, default=None,
                     help="Output pixels produced per clock cycle in "
                          "steady state")
    ap.add_argument("--output-pixels", type=float, default=None,
                     help="Total output pixels produced (alternative to "
                          "--throughput-px-per-cycle, used with --total-cycles)")
    ap.add_argument("--total-cycles", type=float, default=None,
                     help="Total clock cycles to produce --output-pixels")

    ap.add_argument("--power-w", type=float, default=None,
                     help="Override: total power in Watts")
    ap.add_argument("--luts", type=float, default=None,
                     help="Override: LUTs used")
    ap.add_argument("--dsps", type=float, default=None,
                     help="Override: DSPs used")
    ap.add_argument("--brams", type=float, default=None,
                     help="Override: BRAM tiles used")

    args = ap.parse_args()
    impl_dir = args.impl_dir

    # ---- Power ----
    power_path = args.power_report
    if power_path is None:
        saif_rpt = os.path.join(impl_dir, "power_saif.rpt")
        default_rpt = os.path.join(impl_dir, "power_default.rpt")
        if os.path.isfile(saif_rpt):
            power_path = saif_rpt
            power_source = "SAIF-based (power_saif.rpt)"
        else:
            power_path = default_rpt
            power_source = "vectorless/default estimate (power_default.rpt)"
            print("WARNING: power_saif.rpt not found -- falling back to "
                  "power_default.rpt (vectorless estimate). Run gen_saif.tcl "
                  "+ report_power_saif.tcl first for an accurate FoM.")
    else:
        power_source = f"manual override ({power_path})"

    power_metrics = parse_power_report(power_path)
    util_metrics = parse_utilization_report(
        os.path.join(impl_dir, "util_post_route.rpt"))
    timing_metrics = parse_timing_report(
        os.path.join(impl_dir, "timing_post_route.rpt"))

    power_w = args.power_w if args.power_w is not None \
        else power_metrics.get("total_power_w")
    luts = args.luts if args.luts is not None \
        else util_metrics.get("luts_used")
    dsps = args.dsps if args.dsps is not None \
        else util_metrics.get("dsp_used")
    brams = args.brams if args.brams is not None \
        else util_metrics.get("bram_used")
    ffs = util_metrics.get("ff_used")

    # ---- Throughput ----
    if args.throughput_px_per_cycle is not None:
        throughput = args.throughput_px_per_cycle
    elif args.output_pixels is not None and args.total_cycles is not None:
        throughput = args.output_pixels / args.total_cycles
    else:
        throughput = None

    # ---- Fmax ----
    fmax_mhz = compute_fmax_mhz(
        timing_metrics.get("constraint_period_ns"),
        timing_metrics.get("wns_ns"))

    # ================= REPORT =================
    print("\n" + "=" * 66)
    print(" FPGA RESOURCE UTILIZATION (post-route)")
    print("=" * 66)
    print(f"  {'LUTs used':<25}: {luts}")
    print(f"  {'FFs used':<25}: {ffs}")
    print(f"  {'DSPs used':<25}: {dsps}")
    print(f"  {'BRAM tiles used':<25}: {brams}")

    print("\n" + "=" * 66)
    print(f" POWER  (source: {power_source})")
    print("=" * 66)
    print(f"  {'Total On-Chip Power (W)':<25}: {power_w}")
    if "dynamic_power_w" in power_metrics:
        print(f"  {'Dynamic Power (W)':<25}: {power_metrics['dynamic_power_w']}")
    if "static_power_w" in power_metrics:
        print(f"  {'Static Power (W)':<25}: {power_metrics['static_power_w']}")

    print("\n" + "=" * 66)
    print(" TIMING")
    print("=" * 66)
    cp = timing_metrics.get("constraint_period_ns")
    cf = timing_metrics.get("constraint_freq_mhz")
    wns = timing_metrics.get("wns_ns")
    print(f"  {'Constrained period (ns)':<25}: {cp}")
    print(f"  {'Constrained frequency (MHz)':<25}: {cf}")
    print(f"  {'WNS (ns)':<25}: {wns}")
    print(f"  {'Timing status':<25}: "
          f"{'MET' if timing_metrics.get('timing_met') else 'NOT MET / check WNS'}")
    if fmax_mhz is not None:
        note = "" if (wns is not None and wns >= 0) else \
            "  (NOTE: WNS negative -> projected only, not a valid sign-off Fmax)"
        print(f"  {'Achievable Fmax (MHz)':<25}: {fmax_mhz:.3f}{note}")
    else:
        print(f"  {'Achievable Fmax (MHz)':<25}: could not compute "
              f"(missing period or WNS)")

    print("\n" + "=" * 66)
    print(" THROUGHPUT")
    print("=" * 66)
    print(f"  {'Throughput (px/cycle)':<25}: {throughput}")

    # ================= FoM =================
    missing = [name for name, val in
               [("power_w", power_w), ("luts", luts), ("dsps", dsps),
                ("brams", brams), ("throughput", throughput)]
               if val is None]

    print("\n" + "=" * 66)
    print(" FIGURE OF MERIT")
    print("=" * 66)
    if missing:
        print(f"  ERROR: missing required value(s): {', '.join(missing)}")
        print("  Supply via CLI overrides (--power-w/--luts/--dsps/--brams/"
              "--throughput-px-per-cycle) or make sure the report files "
              "exist and parse correctly.")
        return

    fom, denom_resources = compute_fom(power_w, luts, dsps, brams, throughput)
    print(f"  Resource term (LUTs + 50*DSPs + 100*BRAMs) = "
          f"{luts:.0f} + 50*{dsps:.0f} + 100*{brams:.1f} = {denom_resources:.2f}")
    print(f"  FoM = Throughput / (Power * Resource term)")
    print(f"  FoM = {throughput} / ({power_w} * {denom_resources:.2f})")
    print(f"\n  >>> FoM = {fom:.6e}   (higher is better)\n")


if __name__ == "__main__":
    main()