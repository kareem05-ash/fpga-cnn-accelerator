"""
File I/O for the golden model, deliberately kept separate from the
convolution model itself (design principle #5).

File format (simple, text-based, one value per line, row-major order):

    line 1:            <height> <width>
    lines 2..(1+h*w):  one integer per line, row-major (row 0 first)

This keeps the UVM file-sequence side trivial to parse (read a header,
then stream N integers) without requiring a binary format up front. If
the repository already has an established vector format for the UVM
environment, prefer that format instead -- this one is a placeholder
until that's confirmed (see README).
"""

from __future__ import annotations

from pathlib import Path

import numpy as np


def write_array(path: str | Path, array: np.ndarray) -> None:
    """Write a 2D int array to a simple text format: header line + values."""
    array = np.asarray(array)
    if array.ndim != 2:
        raise ValueError(f"expected a 2D array, got shape {array.shape}")
    h, w = array.shape
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as f:
        f.write(f"{h} {w}\n")
        for value in array.flatten(order="C"):
            f.write(f"{int(value)}\n")


def read_array(path: str | Path) -> np.ndarray:
    """Read a 2D int array written by `write_array`."""
    path = Path(path)
    with path.open("r") as f:
        header = f.readline().split()
        if len(header) != 2:
            raise ValueError(f"{path}: malformed header {header!r}")
        h, w = int(header[0]), int(header[1])
        values = [int(f.readline()) for _ in range(h * w)]
    return np.array(values, dtype=np.int64).reshape(h, w)


def write_test_vector(
    directory: str | Path,
    image: np.ndarray,
    kernel: np.ndarray,
    expected: np.ndarray,
) -> None:
    """Write image.txt, kernel.txt, expected.txt into `directory`."""
    directory = Path(directory)
    write_array(directory / "image.txt", image)
    write_array(directory / "kernel.txt", kernel)
    write_array(directory / "expected.txt", expected)


def read_test_vector(directory: str | Path) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Read (image, kernel, expected) from a directory written by `write_test_vector`."""
    directory = Path(directory)
    image = read_array(directory / "image.txt")
    kernel = read_array(directory / "kernel.txt")
    expected = read_array(directory / "expected.txt")
    return image, kernel, expected
