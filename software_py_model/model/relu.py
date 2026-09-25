"""ReLU stage of the golden model, matching the always-on RTL ReLU stage."""

from __future__ import annotations

import numpy as np


def relu(accumulator_values: np.ndarray) -> np.ndarray:
    """
    Apply ReLU: output = max(0, x).

    Per the RTL spec, ReLU is always enabled (not configurable) and is
    applied directly to the accumulator's signed result, before the
    output formatter's saturation stage.
    """
    return np.maximum(accumulator_values, 0)
