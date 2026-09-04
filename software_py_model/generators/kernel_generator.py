"""Kernel generators for verification vectors."""

from __future__ import annotations

import numpy as np


def zeros(n: int) -> np.ndarray:
    """All-zero N x N kernel."""
    return np.zeros((n, n), dtype=np.int64)


def constant(n: int, value: int) -> np.ndarray:
    """Uniform N x N kernel of a given constant value."""
    return np.full((n, n), value, dtype=np.int64)


def all_positive(n: int, value: int = 1) -> np.ndarray:
    """N x N kernel with all-positive weights."""
    if value <= 0:
        raise ValueError("all_positive requires value > 0")
    return constant(n, value)


def all_negative(n: int, value: int = -1) -> np.ndarray:
    """N x N kernel with all-negative weights."""
    if value >= 0:
        raise ValueError("all_negative requires value < 0")
    return constant(n, value)


def mixed_sign(n: int, kernel_width: int = 8) -> np.ndarray:
    """
    Deterministic mixed-sign checkerboard kernel: alternating
    +max and -max-ish values (max magnitude for the given signed width).
    """
    high = (1 << (kernel_width - 1)) - 1   # e.g. 127
    low = -(1 << (kernel_width - 1))       # e.g. -128
    rows = np.arange(n).reshape(-1, 1)
    cols = np.arange(n).reshape(1, -1)
    pattern = (rows + cols) % 2
    return np.where(pattern == 0, high, low).astype(np.int64)


def identity_like(n: int, value: int = 1) -> np.ndarray:
    """Kernel with `value` on the center-ish diagonal, 0 elsewhere (simple, known-answer kernel)."""
    k = np.zeros((n, n), dtype=np.int64)
    np.fill_diagonal(k, value)
    return k


def min_max_extremes(n: int, kernel_width: int = 8) -> np.ndarray:
    """Kernel alternating between the min and max signed representable values."""
    return mixed_sign(n, kernel_width)


def random_kernel(
    n: int,
    kernel_width: int = 8,
    rng: np.random.Generator | None = None,
) -> np.ndarray:
    """Random N x N kernel with values uniformly distributed across the valid signed range."""
    if rng is None:
        rng = np.random.default_rng()
    low = -(1 << (kernel_width - 1))
    high = (1 << (kernel_width - 1))  # exclusive upper bound for integers()
    return rng.integers(low=low, high=high, size=(n, n), dtype=np.int64)
