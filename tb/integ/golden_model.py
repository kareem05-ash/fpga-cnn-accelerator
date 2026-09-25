#!/usr/bin/env python3

"""
Golden reference model for the FPGA CNN accelerator.

Inputs:
    input.txt
    kernel.txt

Output:
    golden_output.txt

Example:
    python3 golden_model.py --n 8 --img-w 32 --img-h 32

Input format:
    One integer per line, row-major order.

Kernel:
    N x N signed 8-bit coefficients, one coefficient per line.

Output:
    One integer per line, row-major order.

Processing:
    1. Valid 2-D cross-correlation
    2. Stride = 1
    3. No padding
    4. MAC accumulation
    5. ReLU
    6. Double-sided saturation
"""


import argparse
from pathlib import Path


# ============================================================================
# File I/O
# ============================================================================

def read_values(file_path):
    """
    Read integer values from a text file.

    Each non-empty line must contain one integer.
    """

    path = Path(file_path)

    if not path.exists():
        raise FileNotFoundError(
            f"File not found: {path}"
        )

    values = []

    with path.open("r") as file:
        for line_number, line in enumerate(file, start=1):
            line = line.strip()

            if not line:
                continue

            try:
                value = int(line)
            except ValueError as exc:
                raise ValueError(
                    f"Invalid integer in {path} at line "
                    f"{line_number}: {line!r}"
                ) from exc

            values.append(value)

    return values


def write_values(file_path, values):
    """
    Write integer values to a text file.

    One value per line.
    """

    path = Path(file_path)

    with path.open("w") as file:
        for value in values:
            file.write(f"{value}\n")


# ============================================================================
# Validation
# ============================================================================

def validate_input(values, img_w, img_h):
    """
    Validate input image size and pixel range.
    """

    expected_size = img_w * img_h

    if len(values) != expected_size:
        raise ValueError(
            f"Invalid input image size: "
            f"expected {expected_size} values "
            f"({img_h}x{img_w}), "
            f"got {len(values)}"
        )

    for index, value in enumerate(values):
        if not 0 <= value <= 255:
            raise ValueError(
                f"Invalid input pixel at index {index}: "
                f"{value}. Expected [0, 255]."
            )


def validate_kernel(kernel, n):
    """
    Validate kernel size and signed 8-bit coefficient range.
    """

    expected_size = n * n

    if len(kernel) != expected_size:
        raise ValueError(
            f"Invalid kernel size: "
            f"expected {expected_size} values "
            f"({n}x{n}), "
            f"got {len(kernel)}"
        )

    for index, value in enumerate(kernel):
        if not -128 <= value <= 127:
            raise ValueError(
                f"Invalid kernel coefficient at index {index}: "
                f"{value}. Expected [-128, 127]."
            )


# ============================================================================
# Data conversion
# ============================================================================

def reshape_image(values, img_w, img_h):
    """
    Convert flat image data into a 2-D matrix.

    Data is interpreted as row-major.
    """

    return [
        values[row * img_w:(row + 1) * img_w]
        for row in range(img_h)
    ]


def reshape_kernel(values, n):
    """
    Convert flat kernel data into a 2-D matrix.

    Data is interpreted as row-major.
    """

    return [
        values[row * n:(row + 1) * n]
        for row in range(n)
    ]


# ============================================================================
# Accelerator post-processing
# ============================================================================

def apply_relu(value):
    """
    Apply ReLU activation.

        ReLU(x) = max(x, 0)
    """

    return max(value, 0)


def saturate(value, out_w=16):
    """
    Apply double-sided saturation to a signed output.

    For a signed OUT_W-bit output:

        MIN = -2^(OUT_W-1)
        MAX =  2^(OUT_W-1) - 1
    """

    min_value = -(1 << (out_w - 1))
    max_value = (1 << (out_w - 1)) - 1

    if value > max_value:
        return max_value

    if value < min_value:
        return min_value

    return value


def format_output(accumulator, out_w=16):
    """
    Apply the DUT output-formatting pipeline.

        accumulator
            |
            v
          ReLU
            |
            v
        saturation
            |
            v
        final output
    """

    value = apply_relu(accumulator)
    value = saturate(value, out_w)

    return value


# ============================================================================
# Convolution / MAC
# ============================================================================

def convolve(image, kernel, img_w, img_h, n, out_w=16):
    """
    Perform valid 2-D cross-correlation.

    This follows the typical CNN hardware implementation:

        accumulator += pixel * kernel

    No kernel flipping is performed.

    Output dimensions:

        OUT_W = IMG_W - N + 1
        OUT_H = IMG_H - N + 1

    Every accumulator result is passed through:

        ReLU -> saturation
    """

    output_width = img_w - n + 1
    output_height = img_h - n + 1

    if output_width <= 0 or output_height <= 0:
        raise ValueError(
            f"Kernel size N={n} is larger than "
            f"the input image {img_h}x{img_w}"
        )

    output = []

    for out_y in range(output_height):
        for out_x in range(output_width):

            accumulator = 0

            for ky in range(n):
                for kx in range(n):

                    pixel = image[out_y + ky][out_x + kx]
                    coefficient = kernel[ky][kx]

                    accumulator += pixel * coefficient

            formatted_output = format_output(
                accumulator,
                out_w
            )

            output.append(formatted_output)

    return output


# ============================================================================
# Command-line interface
# ============================================================================

def parse_arguments():
    """
    Parse command-line arguments.
    """

    parser = argparse.ArgumentParser(
        description="FPGA CNN accelerator golden reference model"
    )

    parser.add_argument(
        "--n",
        type=int,
        required=True,
        help="Kernel dimension N (N x N)"
    )

    parser.add_argument(
        "--img-w",
        type=int,
        required=True,
        help="Input image width"
    )

    parser.add_argument(
        "--img-h",
        type=int,
        required=True,
        help="Input image height"
    )

    parser.add_argument(
        "--out-w",
        type=int,
        default=16,
        help="Output width in bits (default: 16)"
    )

    parser.add_argument(
        "--input",
        default="input.txt",
        help="Input image file (default: input.txt)"
    )

    parser.add_argument(
        "--kernel",
        default="kernel.txt",
        help="Kernel file (default: kernel.txt)"
    )

    parser.add_argument(
        "--output",
        default="golden_output.txt",
        help="Golden output file (default: golden_output.txt)"
    )

    return parser.parse_args()


# ============================================================================
# Main
# ============================================================================

def main():

    args = parse_arguments()

    # ------------------------------------------------------------------------
    # Validate configuration
    # ------------------------------------------------------------------------

    if args.n <= 0:
        raise ValueError("N must be greater than zero")

    if args.img_w <= 0 or args.img_h <= 0:
        raise ValueError(
            "Image dimensions must be greater than zero"
        )

    if args.out_w <= 0:
        raise ValueError(
            "Output width must be greater than zero"
        )

    if args.n > args.img_w or args.n > args.img_h:
        raise ValueError(
            f"Kernel size N={args.n} cannot be larger than "
            f"image dimensions {args.img_h}x{args.img_w}"
        )

    # ------------------------------------------------------------------------
    # Read files
    # ------------------------------------------------------------------------

    input_values = read_values(args.input)
    kernel_values = read_values(args.kernel)

    # ------------------------------------------------------------------------
    # Validate input data
    # ------------------------------------------------------------------------

    validate_input(
        input_values,
        args.img_w,
        args.img_h
    )

    validate_kernel(
        kernel_values,
        args.n
    )

    # ------------------------------------------------------------------------
    # Convert to matrices
    # ------------------------------------------------------------------------

    image = reshape_image(
        input_values,
        args.img_w,
        args.img_h
    )

    kernel = reshape_kernel(
        kernel_values,
        args.n
    )

    # ------------------------------------------------------------------------
    # Generate golden output
    # ------------------------------------------------------------------------

    output = convolve(
        image,
        kernel,
        args.img_w,
        args.img_h,
        args.n,
        args.out_w
    )

    # ------------------------------------------------------------------------
    # Write output
    # ------------------------------------------------------------------------

    write_values(
        args.output,
        output
    )

    # ------------------------------------------------------------------------
    # Report
    # ------------------------------------------------------------------------

    output_width = args.img_w - args.n + 1
    output_height = args.img_h - args.n + 1

    print("Golden model configuration:")
    print(f"  Input       : {args.input}")
    print(f"  Kernel      : {args.kernel}")
    print(f"  Output      : {args.output}")
    print(f"  Image       : {args.img_h}x{args.img_w}")
    print(f"  Kernel      : {args.n}x{args.n}")
    print(f"  Output      : {output_height}x{output_width}")
    print(f"  Stride      : 1")
    print(f"  Padding     : 0")
    print(f"  Output bits : {args.out_w}")
    print(f"  ReLU        : enabled")
    print(f"  Saturation  : enabled")
    print(f"  Samples     : {len(output)}")
    print()
    print(f"Golden output generated: {args.output}")


if __name__ == "__main__":
    main()