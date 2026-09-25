"""
Core bit-accurate 2D convolution golden model.

This module models the accelerator's *numerical* behavior only:

    input (unsigned) x kernel (signed) -> product -> accumulate -> ReLU
    -> saturate to output width

It deliberately does NOT model the RTL's sliding-window buffering, MAC
array pipeline structure, or FSM control -- only the arithmetic result
those structures are meant to produce (see design principle #12 in the
task spec: "Do not reproduce the RTL's sliding-window, FSM, buffering,
or pipeline architecture").
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from .arithmetic import saturate_signed, validate_signed, validate_unsigned, wrap_signed
from .relu import relu


def clog2(n: int) -> int:
    """
    Python equivalent of SystemVerilog's $clog2(n): ceil(log2(n)), with
    $clog2(0) = $clog2(1) = 0 per the IEEE 1800 definition.
    """
    if n <= 1:
        return 0
    return (n - 1).bit_length()


def mac_array_rtl_accumulator_width(product_width: int, kernel_size: int) -> int:
    """
    Reproduce `MAC_array.sv`'s own default accumulator-width parameter
    formula:

        ACC_W = PROD_W + $clog2(N)

    where, in that module, `N` is the kernel dimension (the module operates
    on an N*N-element window/kernel, but the width formula only adds
    $clog2(N) bits, not $clog2(N*N)).

    RESOLVED (confirmed directly): `accelerator_top` overrides `ACC_W` to
    a fixed 24 bits regardless of `N` (`N` is programmable, `ACC_W` is
    not) when it instantiates `MAC_array`. So this formula is NOT what
    actually gets synthesized -- it's `MAC_array.sv`'s own unused default,
    superseded by the top-level override. `AccelConfig()`'s default
    `accumulator_width=24`, independent of `kernel_size`, is therefore
    the RTL-accurate setting, not this formula. This function and
    `AccelConfig.matching_mac_array_rtl` are kept only for reference /
    regression-testing against the (unused) module default -- do not use
    them to generate real expected-output vectors.
    """
    return product_width + clog2(kernel_size)


@dataclass(frozen=True)
class AccelConfig:
    """
    Bit-width / behavior configuration for the golden model.

    Defaults match the confirmed RTL: a fixed 24-bit accumulator
    (`accelerator_top` overrides `MAC_array.sv`'s own `ACC_W` parameter
    to 24 regardless of `N`) and a programmable kernel_size (N). `N` is
    intentionally a free parameter, not hard-coded, per design principle #3.

    `AccelConfig.matching_mac_array_rtl(...)` sizes the accumulator using
    `MAC_array.sv`'s own (unused, superseded) default formula instead --
    kept only for reference/regression testing, not for generating real
    expected-output vectors; see `mac_array_rtl_accumulator_width`.
    """

    kernel_size: int = 5
    input_width: int = 8            # unsigned
    kernel_width: int = 8            # signed
    product_width: int = 17          # signed
    accumulator_width: int = 24      # signed
    output_width: int = 16           # signed
    apply_relu: bool = True
    # CONFIRMED by MAC_array.sv: conv_result is accumulated via
    # `always_comb ... conv_result += product[i]` into a plain fixed-width
    # signed register with no saturation logic anywhere in that module --
    # i.e. overflow during accumulation wraps (two's-complement
    # truncation). "wrap" is therefore the RTL-accurate default, not a
    # guess. "saturate" is kept only as an option for experimentation.
    accumulator_overflow_mode: str = "wrap"  # "wrap" or "saturate"

    def __post_init__(self) -> None:
        if self.kernel_size < 1:
            raise ValueError(f"kernel_size must be >= 1, got {self.kernel_size}")
        if self.accumulator_overflow_mode not in ("wrap", "saturate"):
            raise ValueError(
                "accumulator_overflow_mode must be 'wrap' or 'saturate', "
                f"got {self.accumulator_overflow_mode!r}"
            )

    @classmethod
    def matching_mac_array_rtl(
        cls,
        kernel_size: int = 5,
        input_width: int = 8,
        kernel_width: int = 8,
        product_width: int = 17,
        output_width: int = 16,
        apply_relu: bool = True,
    ) -> "AccelConfig":
        """
        NOT for generating real expected-output vectors -- accelerator_top
        confirmed overrides ACC_W to a fixed 24 regardless of N, so this
        does NOT match the actual synthesized design. Builds a config
        using MAC_array.sv's own (unused, superseded) default accumulator
        formula (PROD_W + $clog2(N)) instead, kept only so the divergence
        from the real 24-bit accumulator stays testable/documented; see
        `mac_array_rtl_accumulator_width`.
        """
        acc_w = mac_array_rtl_accumulator_width(product_width, kernel_size)
        return cls(
            kernel_size=kernel_size,
            input_width=input_width,
            kernel_width=kernel_width,
            product_width=product_width,
            accumulator_width=acc_w,
            output_width=output_width,
            apply_relu=apply_relu,
            accumulator_overflow_mode="wrap",
        )


def output_dims(img_height: int, img_width: int, n: int) -> tuple[int, int]:
    """Return (out_height, out_width) for a valid (no-padding, stride-1) convolution."""
    if n > img_height or n > img_width:
        raise ValueError(
            f"kernel_size N={n} must be <= image dimensions "
            f"(got {img_height}x{img_width})"
        )
    return img_height - n + 1, img_width - n + 1


def validate_image(image: np.ndarray, config: AccelConfig) -> np.ndarray:
    """Validate an image array against the unsigned input width and return it as int64."""
    if image.ndim != 2:
        raise ValueError(f"image must be 2D, got shape {image.shape}")
    if image.shape[0] < config.kernel_size or image.shape[1] < config.kernel_size:
        raise ValueError(
            f"image shape {image.shape} smaller than kernel_size {config.kernel_size}"
        )
    arr = image.astype(np.int64)
    lo, hi = 0, (1 << config.input_width) - 1
    if arr.min() < lo or arr.max() > hi:
        raise ValueError(
            f"image values out of range for unsigned {config.input_width}-bit "
            f"input [{lo}, {hi}]: min={arr.min()}, max={arr.max()}"
        )
    return arr


def validate_kernel(kernel: np.ndarray, config: AccelConfig) -> np.ndarray:
    """Validate a kernel array against the signed kernel width and N x N shape."""
    if kernel.ndim != 2:
        raise ValueError(f"kernel must be 2D, got shape {kernel.shape}")
    if kernel.shape != (config.kernel_size, config.kernel_size):
        raise ValueError(
            f"kernel shape {kernel.shape} does not match "
            f"configured kernel_size {config.kernel_size} "
            f"(expected {(config.kernel_size, config.kernel_size)})"
        )
    arr = kernel.astype(np.int64)
    lo, hi = -(1 << (config.kernel_width - 1)), (1 << (config.kernel_width - 1)) - 1
    if arr.min() < lo or arr.max() > hi:
        raise ValueError(
            f"kernel values out of range for signed {config.kernel_width}-bit "
            f"field [{lo}, {hi}]: min={arr.min()}, max={arr.max()}"
        )
    return arr


def _mac_window(
    image_window: np.ndarray, kernel: np.ndarray, config: AccelConfig
) -> int:
    """
    Compute one output pixel's raw accumulator value (post-accumulate,
    pre-ReLU, pre-output-saturation), applying explicit fixed-width
    product and accumulator behavior element-by-element (not vectorized),
    so overflow/wraparound is modeled faithfully rather than hidden by
    a single wide numpy reduction.
    """
    acc = 0
    for r in range(config.kernel_size):
        for c in range(config.kernel_size):
            pixel = int(image_window[r, c])   # unsigned 8-bit value
            weight = int(kernel[r, c])         # signed 8-bit value
            product = pixel * weight
            # Model the fixed-width signed product register.
            product = wrap_signed(product, config.product_width)
            if config.accumulator_overflow_mode == "wrap":
                acc = wrap_signed(acc + product, config.accumulator_width)
            else:
                acc = saturate_signed(acc + product, config.accumulator_width)
    return acc


def convolve(
    image: np.ndarray,
    kernel: np.ndarray,
    config: AccelConfig | None = None,
) -> np.ndarray:
    """
    Run the bit-accurate golden-model convolution.

    Pipeline per output pixel, matching the RTL's intended arithmetic:
        1. product = image_pixel (unsigned) * kernel_weight (signed),
           truncated to `product_width` signed bits.
        2. accumulate all N*N products into a `accumulator_width`-bit
           signed register (wrap or saturate on overflow, per config).
        3. ReLU: out = max(0, acc)  [always applied per RTL spec]
        4. Output formatter: double-sided saturation of the ReLU result
           into `output_width` signed bits.

    Returns an int64 numpy array of shape (out_height, out_width) holding
    values already saturated to fit in `output_width` signed bits.
    """
    if config is None:
        config = AccelConfig()

    img = validate_image(image, config)
    ker = validate_kernel(kernel, config)

    n = config.kernel_size
    out_h, out_w = output_dims(img.shape[0], img.shape[1], n)
    raw_acc = np.empty((out_h, out_w), dtype=np.int64)

    for i in range(out_h):
        for j in range(out_w):
            window = img[i : i + n, j : j + n]
            raw_acc[i, j] = _mac_window(window, ker, config)

    relu_out = relu(raw_acc) if config.apply_relu else raw_acc

    # Output formatter: double-sided saturation to output_width signed bits.
    saturated = np.vectorize(lambda v: saturate_signed(int(v), config.output_width))(
        relu_out
    )
    return saturated.astype(np.int64)
