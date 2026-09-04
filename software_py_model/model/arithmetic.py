"""
Bit-accurate fixed-width arithmetic helpers.

Python integers are arbitrary precision, which silently hides overflow,
truncation, and two's-complement wraparound behavior that a fixed-width
RTL datapath actually exhibits. This module makes that behavior explicit
so the golden model reproduces it on purpose rather than by accident.

Two behaviors are modeled, and they are NOT the same thing:

1. Wraparound / truncation (``wrap_signed`` / ``wrap_unsigned``):
   what a fixed-width register or adder does when a value does not fit --
   it keeps only the low N bits (two's-complement wraparound for signed
   registers). This is what a MAC accumulator register typically does
   internally on overflow, unless the RTL explicitly guards against it.

2. Saturation (``saturate_signed`` / ``saturate_unsigned``):
   clamping a value to the min/max representable value in N bits instead
   of wrapping. This is what a saturating output-formatter stage does.

ASSUMPTION (flagged, unverified against RTL): this project's spec states
the accelerator's *output* stage explicitly implements "double-sided
saturation" to produce the 16-bit output. The spec does NOT state whether
the 24-bit accumulator itself saturates or wraps internally on overflow.
This model treats the accumulator as a plain fixed-width two's-complement
register that WRAPS on overflow (the common case for a MAC accumulator
without an explicit saturation guard), and treats only the final
output-formatter stage as saturating. If the real RTL accumulator also
saturates (or clips) internally, this assumption is wrong and must be
corrected once the actual `MAC_array` / accumulator RTL is inspected --
see the README "RTL/model mismatches" section.
"""

from __future__ import annotations


def _bit_bounds_signed(width: int) -> tuple[int, int]:
    if width < 1:
        raise ValueError(f"width must be >= 1, got {width}")
    low = -(1 << (width - 1))
    high = (1 << (width - 1)) - 1
    return low, high


def _bit_bounds_unsigned(width: int) -> tuple[int, int]:
    if width < 1:
        raise ValueError(f"width must be >= 1, got {width}")
    return 0, (1 << width) - 1


def in_signed_range(value: int, width: int) -> bool:
    """True if `value` fits in a `width`-bit two's-complement signed field."""
    low, high = _bit_bounds_signed(width)
    return low <= value <= high


def in_unsigned_range(value: int, width: int) -> bool:
    """True if `value` fits in a `width`-bit unsigned field."""
    low, high = _bit_bounds_unsigned(width)
    return low <= value <= high


def wrap_signed(value: int, width: int) -> int:
    """
    Truncate `value` to `width` bits and reinterpret as two's-complement
    signed, exactly as a fixed-width signed register/adder would store it
    on overflow (silent wraparound, no saturation).
    """
    if width < 1:
        raise ValueError(f"width must be >= 1, got {width}")
    mask = (1 << width) - 1
    truncated = value & mask
    sign_bit = 1 << (width - 1)
    if truncated & sign_bit:
        truncated -= 1 << width
    return truncated


def wrap_unsigned(value: int, width: int) -> int:
    """Truncate `value` to `width` bits, unsigned (modulo 2**width)."""
    if width < 1:
        raise ValueError(f"width must be >= 1, got {width}")
    return value & ((1 << width) - 1)


def saturate_signed(value: int, width: int) -> int:
    """Clamp `value` into the representable range of a `width`-bit signed field."""
    low, high = _bit_bounds_signed(width)
    if value < low:
        return low
    if value > high:
        return high
    return value


def saturate_unsigned(value: int, width: int) -> int:
    """Clamp `value` into the representable range of a `width`-bit unsigned field."""
    low, high = _bit_bounds_unsigned(width)
    if value < low:
        return low
    if value > high:
        return high
    return value


def validate_unsigned(value: int, width: int, name: str = "value") -> int:
    """Raise ValueError if `value` is not a valid width-bit unsigned integer."""
    low, high = _bit_bounds_unsigned(width)
    if not (low <= value <= high):
        raise ValueError(
            f"{name}={value} out of range for unsigned {width}-bit field "
            f"[{low}, {high}]"
        )
    return value


def validate_signed(value: int, width: int, name: str = "value") -> int:
    """Raise ValueError if `value` is not a valid width-bit signed integer."""
    low, high = _bit_bounds_signed(width)
    if not (low <= value <= high):
        raise ValueError(
            f"{name}={value} out of range for signed {width}-bit field "
            f"[{low}, {high}]"
        )
    return value
