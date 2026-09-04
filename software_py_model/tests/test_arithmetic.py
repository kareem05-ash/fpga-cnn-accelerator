import pytest

from model.arithmetic import (
    in_signed_range,
    in_unsigned_range,
    saturate_signed,
    saturate_unsigned,
    validate_signed,
    validate_unsigned,
    wrap_signed,
    wrap_unsigned,
)


class TestWrapSigned:
    def test_in_range_values_unchanged(self):
        assert wrap_signed(0, 8) == 0
        assert wrap_signed(127, 8) == 127
        assert wrap_signed(-128, 8) == -128

    def test_positive_overflow_wraps_negative(self):
        # 8-bit signed: 128 -> -128 (wraps around)
        assert wrap_signed(128, 8) == -128
        assert wrap_signed(255, 8) == -1
        assert wrap_signed(256, 8) == 0

    def test_negative_overflow_wraps_positive(self):
        assert wrap_signed(-129, 8) == 127
        assert wrap_signed(-256, 8) == 0

    def test_24_bit_accumulator_wrap(self):
        max_24 = (1 << 23) - 1
        assert wrap_signed(max_24, 24) == max_24
        assert wrap_signed(max_24 + 1, 24) == -(1 << 23)


class TestWrapUnsigned:
    def test_in_range(self):
        assert wrap_unsigned(0, 8) == 0
        assert wrap_unsigned(255, 8) == 255

    def test_overflow_wraps(self):
        assert wrap_unsigned(256, 8) == 0
        assert wrap_unsigned(257, 8) == 1

    def test_negative_wraps(self):
        assert wrap_unsigned(-1, 8) == 255


class TestSaturateSigned:
    def test_in_range_unchanged(self):
        assert saturate_signed(0, 16) == 0
        assert saturate_signed(100, 16) == 100

    def test_clamps_high(self):
        assert saturate_signed(40000, 16) == 32767

    def test_clamps_low(self):
        assert saturate_signed(-40000, 16) == -32768

    def test_boundary_exact(self):
        assert saturate_signed(32767, 16) == 32767
        assert saturate_signed(-32768, 16) == -32768
        assert saturate_signed(32768, 16) == 32767
        assert saturate_signed(-32769, 16) == -32768


class TestSaturateUnsigned:
    def test_clamps_high(self):
        assert saturate_unsigned(300, 8) == 255

    def test_clamps_low(self):
        assert saturate_unsigned(-5, 8) == 0


class TestRangeChecks:
    def test_in_signed_range(self):
        assert in_signed_range(127, 8) is True
        assert in_signed_range(128, 8) is False
        assert in_signed_range(-128, 8) is True
        assert in_signed_range(-129, 8) is False

    def test_in_unsigned_range(self):
        assert in_unsigned_range(255, 8) is True
        assert in_unsigned_range(256, 8) is False
        assert in_unsigned_range(-1, 8) is False


class TestValidators:
    def test_validate_unsigned_raises_on_out_of_range(self):
        validate_unsigned(255, 8)  # should not raise
        with pytest.raises(ValueError):
            validate_unsigned(256, 8)
        with pytest.raises(ValueError):
            validate_unsigned(-1, 8)

    def test_validate_signed_raises_on_out_of_range(self):
        validate_signed(-128, 8)
        validate_signed(127, 8)
        with pytest.raises(ValueError):
            validate_signed(128, 8)
        with pytest.raises(ValueError):
            validate_signed(-129, 8)
