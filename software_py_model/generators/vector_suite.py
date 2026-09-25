"""
Orchestrates generation of deterministic and random test vectors,
each as a `tests/<name>/{image,kernel,expected}.txt` directory,
per the required file layout in the task spec.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np

from generators import image_generator as img_gen
from generators import kernel_generator as ker_gen
from model.convolution import AccelConfig, convolve
from model.io_utils import write_test_vector


def deterministic_cases(config: AccelConfig, img_h: int, img_w: int) -> dict[str, tuple]:
    """
    Build the deterministic (image, kernel) pairs called out in the spec:
    all-zero image, all-zero kernel, all-one image, positive/negative/
    mixed-sign kernel, max input values, min/max kernel values, a small
    known-answer kernel.
    """
    n = config.kernel_size
    cases: dict[str, tuple] = {}

    cases["all_zero_image"] = (img_gen.zeros(img_h, img_w), ker_gen.all_positive(n, 1))
    cases["all_zero_kernel"] = (img_gen.random_image(img_h, img_w, config.input_width,
                                                       rng=np.random.default_rng(0)),
                                 ker_gen.zeros(n))
    cases["all_one_image"] = (img_gen.ones(img_h, img_w), ker_gen.all_positive(n, 1))
    cases["positive_kernel"] = (img_gen.ramp(img_h, img_w, config.input_width),
                                 ker_gen.all_positive(n, 3))
    cases["negative_kernel"] = (img_gen.ramp(img_h, img_w, config.input_width),
                                 ker_gen.all_negative(n, -3))
    cases["mixed_sign_kernel"] = (img_gen.checkerboard(img_h, img_w),
                                   ker_gen.mixed_sign(n, config.kernel_width))
    cases["max_input_values"] = (img_gen.max_value(img_h, img_w, config.input_width),
                                  ker_gen.min_max_extremes(n, config.kernel_width))
    cases["min_max_kernel"] = (img_gen.ramp(img_h, img_w, config.input_width),
                                ker_gen.min_max_extremes(n, config.kernel_width))
    cases["identity_kernel"] = (img_gen.ramp(img_h, img_w, config.input_width),
                                 ker_gen.identity_like(n, 1))
    return cases


def random_cases(
    config: AccelConfig,
    count: int,
    img_h_range: tuple[int, int] = (8, 32),
    img_w_range: tuple[int, int] = (8, 32),
    n_range: tuple[int, int] | None = None,
    seed: int = 42,
) -> dict[str, tuple]:
    """
    Build `count` randomized (image, kernel, per_case_config) triples with
    randomized supported image dimensions and, optionally, randomized
    supported kernel sizes (n_range). If n_range is None, uses
    config.kernel_size for every case.
    """
    rng = np.random.default_rng(seed)
    cases: dict[str, tuple] = {}
    for i in range(count):
        n = config.kernel_size if n_range is None else int(rng.integers(n_range[0], n_range[1] + 1))
        h = int(rng.integers(max(img_h_range[0], n), img_h_range[1] + 1))
        w = int(rng.integers(max(img_w_range[0], n), img_w_range[1] + 1))
        image = img_gen.random_image(h, w, config.input_width, rng=rng)
        kernel = ker_gen.random_kernel(n, config.kernel_width, rng=rng)
        case_config = AccelConfig(
            kernel_size=n,
            input_width=config.input_width,
            kernel_width=config.kernel_width,
            product_width=config.product_width,
            accumulator_width=config.accumulator_width,
            output_width=config.output_width,
            apply_relu=config.apply_relu,
            accumulator_overflow_mode=config.accumulator_overflow_mode,
        )
        cases[f"random_{i:03d}"] = (image, kernel, case_config)
    return cases


def generate_all(
    output_dir: str | Path,
    config: AccelConfig | None = None,
    img_h: int = 32,
    img_w: int = 32,
    n_random: int = 10,
) -> list[str]:
    """
    Generate the full deterministic + random suite into `output_dir`,
    one subdirectory per test case, each containing image.txt, kernel.txt,
    expected.txt. Returns the list of generated case names.
    """
    if config is None:
        config = AccelConfig()
    output_dir = Path(output_dir)
    generated: list[str] = []

    for name, (image, kernel) in deterministic_cases(config, img_h, img_w).items():
        expected = convolve(image, kernel, config)
        write_test_vector(output_dir / name, image, kernel, expected)
        generated.append(name)

    for name, (image, kernel, case_config) in random_cases(config, n_random).items():
        expected = convolve(image, kernel, case_config)
        write_test_vector(output_dir / name, image, kernel, expected)
        generated.append(name)

    return generated
