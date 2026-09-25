#!/usr/bin/env python3
"""
Terminal-friendly wrapper around visualize.py: saves a PNG instead of
popping up an interactive window, so it works over SSH / in a plain
terminal with no display.

Usage:
    # One test case -> one PNG
    python3 visualize_cli.py vectors/positive_kernel --out positive_kernel.png

    # One test case, compared against an actual RTL/DUT output file
    python3 visualize_cli.py vectors/positive_kernel \\
        --rtl-output path/to/rtl_output.txt --out positive_kernel_vs_rtl.png

    # Every case under vectors/ -> one PNG per case, into previews/
    python3 visualize_cli.py --all vectors --out-dir previews
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from visualize import show_test_case_from_dir


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Save a PNG preview of a test-vector case")
    parser.add_argument("case_dir", nargs="?", help="Path to a single test case directory")
    parser.add_argument("--rtl-output", help="Optional path to an actual RTL/DUT output file to compare against")
    parser.add_argument("--out", default=None, help="Output PNG path (default: <case_name>.png in cwd)")
    parser.add_argument("--all", metavar="VECTORS_DIR", help="Render every case under VECTORS_DIR instead of a single case")
    parser.add_argument("--out-dir", default="previews", help="Output directory when using --all (default: previews)")
    args = parser.parse_args(argv)

    if args.all:
        vectors_dir = Path(args.all)
        out_dir = Path(args.out_dir)
        out_dir.mkdir(parents=True, exist_ok=True)
        case_dirs = sorted(p for p in vectors_dir.iterdir() if p.is_dir() and (p / "expected.txt").exists())
        if not case_dirs:
            print(f"No test cases found under {vectors_dir}", file=sys.stderr)
            return 1
        for case_dir in case_dirs:
            out_path = out_dir / f"{case_dir.name}.png"
            show_test_case_from_dir(case_dir, save_path=out_path)
            print(f"Wrote {out_path}")
        return 0

    if not args.case_dir:
        parser.error("provide a case_dir, or use --all VECTORS_DIR")

    case_dir = Path(args.case_dir)
    out_path = Path(args.out) if args.out else Path(f"{case_dir.name}.png")
    show_test_case_from_dir(case_dir, rtl_output_path=args.rtl_output, save_path=out_path)
    print(f"Wrote {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
