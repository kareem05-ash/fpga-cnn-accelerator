import numpy as np
import pytest

from generators import image_generator as img_gen
from generators import kernel_generator as ker_gen
from generators.vector_suite import deterministic_cases, generate_all, random_cases
from model.convolution import AccelConfig, convolve
from model.io_utils import read_array, read_test_vector, write_array, write_test_vector


class TestIORoundTrip:
    def test_array_round_trip(self, tmp_path):
        arr = np.array([[1, -2, 3], [4, 5, -6]])
        path = tmp_path / "arr.txt"
        write_array(path, arr)
        loaded = read_array(path)
        np.testing.assert_array_equal(arr, loaded)

    def test_test_vector_round_trip(self, tmp_path):
        image = img_gen.random_image(8, 8, rng=np.random.default_rng(1))
        kernel = ker_gen.random_kernel(3, rng=np.random.default_rng(2))
        config = AccelConfig(kernel_size=3)
        expected = convolve(image, kernel, config)

        write_test_vector(tmp_path / "case_a", image, kernel, expected)
        loaded_image, loaded_kernel, loaded_expected = read_test_vector(tmp_path / "case_a")

        np.testing.assert_array_equal(image, loaded_image)
        np.testing.assert_array_equal(kernel, loaded_kernel)
        np.testing.assert_array_equal(expected, loaded_expected)


class TestGenerators:
    def test_image_generators_respect_input_width(self):
        for gen_fn in (
            lambda: img_gen.random_image(16, 16, input_width=8, rng=np.random.default_rng(3)),
            lambda: img_gen.max_value(16, 16, input_width=8),
            lambda: img_gen.checkerboard(16, 16),
        ):
            arr = gen_fn()
            assert arr.min() >= 0
            assert arr.max() <= 255

    def test_kernel_generators_respect_kernel_width(self):
        for gen_fn in (
            lambda: ker_gen.random_kernel(5, kernel_width=8, rng=np.random.default_rng(4)),
            lambda: ker_gen.min_max_extremes(5, kernel_width=8),
        ):
            arr = gen_fn()
            assert arr.min() >= -128
            assert arr.max() <= 127

    def test_random_cases_supports_random_kernel_sizes(self):
        config = AccelConfig(kernel_size=5)
        cases = random_cases(config, count=5, n_range=(2, 7), seed=7)
        sizes = {kernel.shape[0] for (_, kernel, _) in cases.values()}
        assert len(cases) == 5
        # not asserting variety strictly (seeded), just that shapes are self-consistent
        for image, kernel, case_config in cases.values():
            assert kernel.shape == (case_config.kernel_size, case_config.kernel_size)
            assert image.shape[0] >= case_config.kernel_size
            assert image.shape[1] >= case_config.kernel_size


class TestDeterministicCases:
    def test_all_named_cases_present(self):
        config = AccelConfig(kernel_size=5)
        cases = deterministic_cases(config, 32, 32)
        expected_names = {
            "all_zero_image", "all_zero_kernel", "all_one_image",
            "positive_kernel", "negative_kernel", "mixed_sign_kernel",
            "max_input_values", "min_max_kernel", "identity_kernel",
        }
        assert expected_names.issubset(cases.keys())

    def test_each_case_convolves_without_error(self):
        config = AccelConfig(kernel_size=5)
        for name, (image, kernel) in deterministic_cases(config, 32, 32).items():
            out = convolve(image, kernel, config)
            assert out.shape[0] > 0 and out.shape[1] > 0, name


class TestGenerateAll:
    def test_generate_all_writes_all_vectors(self, tmp_path):
        config = AccelConfig(kernel_size=5)
        names = generate_all(tmp_path, config=config, img_h=32, img_w=32, n_random=3)
        assert len(names) > 0
        for name in names:
            case_dir = tmp_path / name
            assert (case_dir / "image.txt").exists()
            assert (case_dir / "kernel.txt").exists()
            assert (case_dir / "expected.txt").exists()
            # sanity: expected file loads and matches shape expectations
            image, kernel, expected = read_test_vector(case_dir)
            recomputed = convolve(image, kernel, config if not name.startswith("random_") else
                                   AccelConfig(kernel_size=kernel.shape[0]))
            np.testing.assert_array_equal(expected, recomputed)
