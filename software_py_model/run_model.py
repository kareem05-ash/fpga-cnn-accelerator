#!/usr/bin/env python3
"""
CLI entry point for the golden model.

Usage:
    # Run convolution on an existing image.txt / kernel.txt, write expected.txt
    python run_model.py run --image path/to/image.txt --kernel path/to/kernel.txt \\
        --out path/to/expected.txt [--n 5] [--accumulator-overflow wrap|saturate]

    # Generate the full deterministic + random test-vector suite
    python run_model.py generate --out vectors/ [--img-h 32] [--img-w 32] [--n 5] [--random 10]
"""

from __future__ import annotations

import argparse
import sys

from generators.vector_suite import generate_all
from model.convolution import AccelConfig, convolve
from model.io_utils import read_array, write_array


def cmd_run(args: argparse.Namespace) -> None:
    config = AccelConfig(
        kernel_size=args.n,
        apply_relu=not args.no_relu,
        accumulator_overflow_mode=args.accumulator_overflow,
    )
    image = read_array(args.image)
    kernel = read_array(args.kernel)
    expected = convolve(image, kernel, config)
    write_array(args.out, expected)
    print(f"Wrote {expected.shape[0]}x{expected.shape[1]} expected output to {args.out}")


def cmd_generate(args: argparse.Namespace) -> None:
    config = AccelConfig(kernel_size=args.n)
    generated = generate_all(
        args.out, config=config, img_h=args.img_h, img_w=args.img_w, n_random=args.random
    )
    print(f"Generated {len(generated)} test vectors under {args.out}:")
    for name in generated:
        print(f"  - {name}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="CNN accelerator golden model")
    sub = parser.add_subparsers(dest="command", required=True)

    p_run = sub.add_parser("run", help="Run convolution on an image/kernel file pair")
    p_run.add_argument("--image", required=True)
    p_run.add_argument("--kernel", required=True)
    p_run.add_argument("--out", required=True)
    p_run.add_argument("--n", type=int, default=5, help="kernel size N (default: 5)")
    p_run.add_argument("--no-relu", action="store_true", help="disable ReLU stage")
    p_run.add_argument(
        "--accumulator-overflow",
        choices=["wrap", "saturate"],
        default="wrap",
        help="accumulator overflow behavior (default: wrap; see README assumptions)",
    )
    p_run.set_defaults(func=cmd_run)

    p_gen = sub.add_parser("generate", help="Generate the full deterministic + random test suite")
    p_gen.add_argument("--out", required=True)
    p_gen.add_argument("--img-h", type=int, default=32)
    p_gen.add_argument("--img-w", type=int, default=32)
    p_gen.add_argument("--n", type=int, default=5)
    p_gen.add_argument("--random", type=int, default=10, help="number of random cases")
    p_gen.set_defaults(func=cmd_generate)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    args.func(args)
    return 0


if __name__ == "__main__":
    sys.exit(main())
