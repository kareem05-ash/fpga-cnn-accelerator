"""Image / feature-map generators for verification vectors."""

from __future__ import annotations

import numpy as np


def zeros(height: int, width: int) -> np.ndarray:
    """All-zero image."""
    return np.zeros((height, width), dtype=np.int64)


def ones(height: int, width: int) -> np.ndarray:
    """All-one image."""
    return np.ones((height, width), dtype=np.int64)


def constant(height: int, width: int, value: int) -> np.ndarray:
    """Uniform image of a given constant value."""
    return np.full((height, width), value, dtype=np.int64)


def max_value(height: int, width: int, input_width: int = 8) -> np.ndarray:
    """Image filled with the maximum representable unsigned value (e.g. 255)."""
    return constant(height, width, (1 << input_width) - 1)


def ramp(height: int, width: int, input_width: int = 8) -> np.ndarray:
    """Deterministic, non-uniform pattern (row-major ramp, wrapped to input range)."""
    max_val = (1 << input_width) - 1
    values = np.arange(height * width, dtype=np.int64) % (max_val + 1)
    return values.reshape(height, width)


def checkerboard(height: int, width: int, low: int = 0, high: int = 255) -> np.ndarray:
    """Alternating low/high checkerboard pattern."""
    rows = np.arange(height).reshape(-1, 1)
    cols = np.arange(width).reshape(1, -1)
    pattern = (rows + cols) % 2
    return np.where(pattern == 0, low, high).astype(np.int64)


def random_image(
    height: int,
    width: int,
    input_width: int = 8,
    rng: np.random.Generator | None = None,
) -> np.ndarray:
    """Random image with values uniformly distributed across the valid unsigned range."""
    if rng is None:
        rng = np.random.default_rng()
    high = 1 << input_width
    return rng.integers(low=0, high=high, size=(height, width), dtype=np.int64)
