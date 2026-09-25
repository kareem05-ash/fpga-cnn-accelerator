"""
Optional debug visualization for a failed test case.

This module is intentionally NOT imported by anything under `model/` or
`generators/` -- the core golden model must stay usable headless. Import
this module only when you actually want a plot (e.g. from a notebook,
a debug script, or interactively).

Requires matplotlib, which is NOT a dependency of the core model.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np

try:
    import matplotlib.pyplot as plt
except ImportError as exc:  # pragma: no cover - optional dependency
    raise ImportError(
        "visualize.py requires matplotlib (`pip install matplotlib --break-system-packages`). "
        "The core golden model does not depend on this module."
    ) from exc


def show_test_case(
    image: np.ndarray,
    kernel: np.ndarray,
    expected: np.ndarray,
    rtl_output: np.ndarray | None = None,
    title: str = "Test case",
    save_path: str | Path | None = None,
) -> None:
    """
    Visualize a test case: input image, kernel, expected output, and
    optionally the actual RTL output plus the difference map.

    If save_path is provided, save the figure as a PNG instead of
    displaying it interactively.
    """
    panels = [("Image", image), ("Kernel", kernel), ("Expected", expected)]

    if rtl_output is not None:
        diff = expected.astype(np.int64) - rtl_output.astype(np.int64)
        panels.append(("RTL output", rtl_output))
        panels.append(("Difference (expected - RTL)", diff))

    fig, axes = plt.subplots(
        1,
        len(panels),
        figsize=(4 * len(panels), 4),
    )

    if len(panels) == 1:
        axes = [axes]

    for ax, (label, data) in zip(axes, panels):
        im = ax.imshow(data, cmap="viridis")
        ax.set_title(label)
        ax.set_xticks([])
        ax.set_yticks([])
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    fig.suptitle(title)
    fig.tight_layout()

    if save_path is not None:
        save_path = Path(save_path)
        save_path.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(save_path, dpi=150, bbox_inches="tight")
        plt.close(fig)
    else:
        plt.show()


def show_test_case_from_dir(
    directory: str | Path,
    rtl_output_path: str | Path | None = None,
    save_path: str | Path | None = None,
) -> None:
    """Load a test-vector directory and visualize it."""
    from model.io_utils import read_array

    directory = Path(directory)

    image = read_array(directory / "image.txt")
    kernel = read_array(directory / "kernel.txt")
    expected = read_array(directory / "expected.txt")

    rtl_output = (
        read_array(rtl_output_path)
        if rtl_output_path
        else None
    )

    show_test_case(
        image,
        kernel,
        expected,
        rtl_output,
        title=str(directory.name),
        save_path=save_path,
    )