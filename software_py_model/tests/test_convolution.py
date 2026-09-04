import numpy as np
import pytest

from model.arithmetic import saturate_signed, wrap_signed
from model.convolution import (
    AccelConfig,
    clog2,
    convolve,
    mac_array_rtl_accumulator_width,
    output_dims,
    validate_image,
    validate_kernel,
)


class TestOutputDims:
    def test_default_32x32_n5(self):
        assert output_dims(32, 32, 5) == (28, 28)

    def test_square_minimum(self):
        assert output_dims(5, 5, 5) == (1, 1)

    def test_n_larger_than_image_raises(self):
        with pytest.raises(ValueError):
            output_dims(4, 32, 5)


class TestValidation:
    def test_image_out_of_range_rejected(self):
        config = AccelConfig(kernel_size=3)
        bad = np.array([[256, 0, 0], [0, 0, 0], [0, 0, 0]])
        with pytest.raises(ValueError):
            validate_image(bad, config)

    def test_image_negative_rejected(self):
        config = AccelConfig(kernel_size=3)
        bad = np.array([[-1, 0, 0], [0, 0, 0], [0, 0, 0]])
        with pytest.raises(ValueError):
            validate_image(bad, config)

    def test_kernel_out_of_signed_range_rejected(self):
        config = AccelConfig(kernel_size=3)
        bad = np.array([[128, 0, 0], [0, 0, 0], [0, 0, 0]])
        with pytest.raises(ValueError):
            validate_kernel(bad, config)

    def test_kernel_wrong_shape_rejected(self):
        config = AccelConfig(kernel_size=3)
        bad = np.zeros((2, 2))
        with pytest.raises(ValueError):
            validate_kernel(bad, config)

    def test_kernel_size_not_hardcoded(self):
        # N != 5 must work without special-casing
        for n in (1, 2, 3, 4, 6, 7):
            config = AccelConfig(kernel_size=n)
            image = np.zeros((max(n, 8), max(n, 8)))
            kernel = np.zeros((n, n))
            out = convolve(image, kernel, config)
            assert out.shape == output_dims(image.shape[0], image.shape[1], n)


class TestKnownAnswers:
    def test_all_zero_image_gives_zero_output(self):
        config = AccelConfig(kernel_size=3)
        image = np.zeros((5, 5))
        kernel = np.full((3, 3), 5)
        out = convolve(image, kernel, config)
        assert np.all(out == 0)

    def test_all_zero_kernel_gives_zero_output(self):
        config = AccelConfig(kernel_size=3)
        image = np.full((5, 5), 200)
        kernel = np.zeros((3, 3))
        out = convolve(image, kernel, config)
        assert np.all(out == 0)

    def test_identity_like_kernel_known_answer(self):
        # 1x1 kernel with weight 1 => output == input (after ReLU/saturation, all in range)
        config = AccelConfig(kernel_size=1)
        image = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        kernel = np.array([[1]])
        out = convolve(image, kernel, config)
        np.testing.assert_array_equal(out, image)

    def test_hand_computed_3x3_case(self):
        config = AccelConfig(kernel_size=2, apply_relu=False)
        image = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        kernel = np.array([[1, 0], [0, -1]])
        # output[0][0] = 1*1 + 2*0 + 4*0 + 5*(-1) = 1 - 5 = -4
        # output[0][1] = 2*1 + 3*0 + 5*0 + 6*(-1) = 2 - 6 = -4
        # output[1][0] = 4*1 + 5*0 + 7*0 + 8*(-1) = 4 - 8 = -4
        # output[1][1] = 5*1 + 6*0 + 8*0 + 9*(-1) = 5 - 9 = -4
        out = convolve(image, kernel, config)
        expected = np.array([[-4, -4], [-4, -4]])
        np.testing.assert_array_equal(out, expected)


class TestReLU:
    def test_negative_accumulation_clipped_to_zero(self):
        config = AccelConfig(kernel_size=2, apply_relu=True)
        image = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        kernel = np.array([[1, 0], [0, -1]])
        out = convolve(image, kernel, config)
        assert np.all(out >= 0)
        assert np.all(out == 0)  # all hand-computed values above were negative

    def test_relu_disabled_allows_negative(self):
        config = AccelConfig(kernel_size=2, apply_relu=False)
        image = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        kernel = np.array([[1, 0], [0, -1]])
        out = convolve(image, kernel, config)
        assert np.any(out < 0)


class TestSaturation:
    def test_output_saturates_to_16_bit_max(self):
        # Max input (255) x max kernel (127) x many taps should exceed 16-bit range
        # and must saturate rather than wrap.
        config = AccelConfig(kernel_size=5, apply_relu=True)
        image = np.full((5, 5), 255)
        kernel = np.full((5, 5), 127)
        out = convolve(image, kernel, config)
        # raw sum = 25 * 255 * 127 = 809625, which exceeds int16 max (32767)
        assert out[0, 0] == 32767

    def test_saturate_signed_boundary_matches_output(self):
        assert saturate_signed(40000, 16) == 32767
        assert saturate_signed(-40000, 16) == -32768


class TestAccumulatorOverflowModes:
    def test_wrap_vs_saturate_can_diverge(self):
        # Construct a case designed to overflow the 24-bit accumulator so the
        # two overflow modes give different raw (pre-ReLU) results. This
        # documents the assumption called out in arithmetic.py / README:
        # verify against real RTL which mode (if either) is correct.
        config_wrap = AccelConfig(kernel_size=5, accumulator_width=8, apply_relu=False,
                                   accumulator_overflow_mode="wrap")
        config_sat = AccelConfig(kernel_size=5, accumulator_width=8, apply_relu=False,
                                  accumulator_overflow_mode="saturate")
        image = np.full((5, 5), 100)
        kernel = np.full((5, 5), 100)  # kernel_width default 8-bit signed max is 127, 100 ok
        out_wrap = convolve(image, kernel, config_wrap)
        out_sat = convolve(image, kernel, config_sat)
        assert out_wrap[0, 0] != out_sat[0, 0]


class TestImageSizes:
    def test_minimum_32x32_supported(self):
        config = AccelConfig(kernel_size=5)
        image = np.zeros((32, 32))
        kernel = np.zeros((5, 5))
        out = convolve(image, kernel, config)
        assert out.shape == (28, 28)

    def test_larger_than_32x32_supported(self):
        config = AccelConfig(kernel_size=5)
        image = np.zeros((64, 48))
        kernel = np.zeros((5, 5))
        out = convolve(image, kernel, config)
        assert out.shape == (60, 44)


class TestClog2:
    def test_matches_systemverilog_clog2_definition(self):
        # $clog2(1) = 0, $clog2(2) = 1, $clog2(3) = 2, $clog2(4) = 2,
        # $clog2(5) = 3, $clog2(8) = 3, $clog2(9) = 4 (IEEE 1800 semantics)
        assert clog2(1) == 0
        assert clog2(2) == 1
        assert clog2(3) == 2
        assert clog2(4) == 2
        assert clog2(5) == 3
        assert clog2(8) == 3
        assert clog2(9) == 4


class TestMacArrayRtlAccumulatorWidth:
    def test_default_n5_gives_20_not_24(self):
        # MAC_array.sv's own default ACC_W = PROD_W + $clog2(N) formula
        # gives 20 bits for N=5, PROD_W=17. This is NOT what's actually
        # synthesized -- accelerator_top confirmed it overrides ACC_W to
        # a fixed 24 regardless of N -- but the formula itself is pinned
        # down here for documentation/regression purposes.
        assert mac_array_rtl_accumulator_width(product_width=17, kernel_size=5) == 20

    def test_default_config_uses_confirmed_fixed_24_bit_accumulator(self):
        # This is the RTL-accurate default: accelerator_top overrides
        # ACC_W to a fixed 24 regardless of kernel_size (N is programmable,
        # ACC_W is not).
        for n in (1, 3, 5, 7):
            assert AccelConfig(kernel_size=n).accumulator_width == 24

    def test_matching_mac_array_rtl_helper_reflects_unused_module_default(self):
        # Kept only for reference -- does not reflect the real synthesized
        # design (see the classmethod's docstring).
        config = AccelConfig.matching_mac_array_rtl(kernel_size=5)
        assert config.accumulator_width == 20
        assert config.accumulator_overflow_mode == "wrap"

    def test_module_default_formula_diverges_from_confirmed_real_width(self):
        # Worst-case 5x5 window: max unsigned pixel (255) x max-magnitude
        # signed kernel weight (-128) on every tap.
        image = np.full((5, 5), 255)
        kernel = np.full((5, 5), -128)

        real_config = AccelConfig(kernel_size=5, apply_relu=False)  # confirmed real: fixed 24-bit accumulator
        unused_module_default = AccelConfig.matching_mac_array_rtl(kernel_size=5)  # module's own 20-bit default
        unused_module_default = AccelConfig(
            kernel_size=5,
            accumulator_width=unused_module_default.accumulator_width,
            apply_relu=False,
            accumulator_overflow_mode="wrap",
        )

        out_real_24bit = convolve(image, kernel, real_config)
        out_unused_20bit = convolve(image, kernel, unused_module_default)

        # With the confirmed real 24-bit accumulator, the true sum fits and
        # no accumulator-level wrap occurs (only the final 16-bit output
        # saturation clips it). With MAC_array.sv's own unused 20-bit
        # default, the same true sum would have wrapped mid-accumulation --
        # this proves the override to 24 bits is functionally significant,
        # not cosmetic.
        assert out_real_24bit[0, 0] != out_unused_20bit[0, 0]



class TestProductWrapModeling:
    def test_product_wrap_is_identity_for_spec_widths(self):
        # For the spec's default widths (8u x 8s -> 17s), the true product
        # always fits, so wrap_signed must be a no-op here -- this test
        # guards against silently breaking that invariant.
        for pixel in (0, 1, 255):
            for weight in (-128, -1, 0, 1, 127):
                product = pixel * weight
                assert wrap_signed(product, 17) == product
