# CNN Accelerator — Python Golden Reference Model

Bit-accurate software reference model for the single-channel 2D CNN
convolution accelerator (`accelerator_top`), used to generate deterministic
expected-output vectors for the UVM verification environment.

> **RTL status:** `processing_element.sv` and `MAC_array.sv` have been
> reviewed and confirm the arithmetic modeled here, including a fixed
> 24-bit accumulator (confirmed directly, overriding `MAC_array.sv`'s own
> default `ACC_W` formula) and wrap-on-overflow accumulator behavior.
> `accelerator_top`, `relu`, `output_formatter`, `sliding_window`, and
> `kernel_mem` have not been reviewed directly, though the output-stage
> double-sided saturation behavior has been confirmed. See **RTL/model
> mismatches** below for what's fully resolved vs. still open.

## What this is (and isn't)

This model reproduces the accelerator's **numerical/arithmetic result**,
not its microarchitecture. It does not implement a sliding window buffer,
MAC-array pipeline, or FSM control — it computes the same answer those
structures are meant to produce, using an equivalent but independent
algorithm (per the task's design principle: "do not reproduce the RTL's
sliding-window, FSM, buffering, or pipeline architecture").

## Project layout

```
python/
├── model/
│   ├── arithmetic.py     # fixed-width wrap/saturate/validate helpers
│   ├── convolution.py    # AccelConfig + bit-accurate convolve()
│   ├── relu.py           # ReLU stage
│   └── io_utils.py       # text file I/O, separate from the model core
├── generators/
│   ├── image_generator.py    # deterministic + random image generators
│   ├── kernel_generator.py   # deterministic + random kernel generators
│   └── vector_suite.py       # orchestrates full test-vector generation
├── tests/
│   ├── test_arithmetic.py
│   ├── test_convolution.py
│   └── test_vectors.py
├── vectors/               # generated test-vector output (example run included)
├── run_model.py           # CLI entry point
├── visualize.py           # optional matplotlib debug viewer (not a core dependency)
└── conftest.py            # pytest sys.path setup
```

## Supported inputs

| Field  | Type            | Range          | Notes                          |
|--------|-----------------|----------------|---------------------------------|
| Image  | unsigned 8-bit  | 0 – 255        | any H×W with H,W ≥ N (32×32 minimum recommended, larger sizes supported) |
| Kernel | signed 8-bit    | -128 – +127    | N×N, N is configurable (not hard-coded to 5) |

Values outside these ranges raise `ValueError` with a descriptive message
(`model.convolution.validate_image` / `validate_kernel`).

## Arithmetic widths (`AccelConfig` defaults)

```
input_width          = 8   (unsigned)
kernel_width          = 8   (signed)
product_width         = 17  (signed)
accumulator_width     = 24  (signed)
output_width          = 16  (signed)
apply_relu            = True
accumulator_overflow_mode = "wrap"   # confirmed by MAC_array.sv, see RTL/model mismatches below
```

`accumulator_width=24` is fixed regardless of `kernel_size` (confirmed:
`accelerator_top` overrides `MAC_array.sv`'s own `ACC_W` parameter formula
to a constant 24, while `N` itself is programmable). See mismatch #1
below for what that formula would have given instead, kept only for
reference.

Pipeline per output pixel (`model/convolution.py: convolve`):

1. **Product**: `pixel (unsigned) * weight (signed)`, truncated to
   `product_width` signed bits via two's-complement wraparound
   (`arithmetic.wrap_signed`). For the spec's default widths (8u×8s→17s)
   this truncation is provably a no-op — the true product always fits —
   see `TestProductWrapModeling` in `test_convolution.py`. It's still
   modeled explicitly so the behavior is correct if widths change.
2. **Accumulate**: sum all N×N products into a `accumulator_width`-bit
   signed register, either wrapping (two's-complement truncation) or
   saturating on overflow, per `AccelConfig.accumulator_overflow_mode`.
3. **ReLU**: `out = max(0, acc)` — always applied (per RTL spec, not
   configurable in the RTL; the model exposes `apply_relu=False` only for
   testing/debugging purposes).
4. **Output formatter**: double-sided saturation of the ReLU result into
   `output_width` signed bits (`arithmetic.saturate_signed`), per the
   spec's explicit statement that the RTL uses double-sided saturation
   for the 16-bit output.

## RTL/model mismatches found

1. **Accumulator width: RESOLVED, confirmed fixed 24 bits.**
   `MAC_array.sv`'s own default parameter formula is
   `ACC_W = PROD_W + $clog2(N)` (`N` = kernel dimension), which computes
   to `17 + $clog2(5) = 20` bits for the documented default `N=5` — not
   24. This looked like a real discrepancy, but it's resolved: confirmed
   directly that **`accelerator_top` overrides `ACC_W` to a fixed 24 bits
   regardless of `N`** (`N` is programmable, `ACC_W` is not). So
   `MAC_array.sv`'s own formula is simply unused/superseded at the top
   level, not a bug.

   `AccelConfig()`'s default `accumulator_width=24`, independent of
   `kernel_size`, is therefore the RTL-accurate setting and is used
   everywhere in this codebase by default. `mac_array_rtl_accumulator_width`
   and `AccelConfig.matching_mac_array_rtl(...)` are kept only for
   reference/regression-testing against the module's own (unused) default
   formula — **do not use them to generate real expected-output vectors.**
   `TestMacArrayRtlAccumulatorWidth` in `test_convolution.py` documents
   both the module-default formula and the confirmed real (fixed-24) width,
   and proves they'd diverge on worst-case inputs if the override weren't
   there.

2. **Accumulator overflow behavior: confirmed by RTL, not just assumed.**
   `MAC_array.sv` accumulates via
   `always_comb ... conv_result += product[i]` into a plain fixed-width
   signed register, with no saturation logic anywhere in that module.
   That structurally confirms overflow during accumulation **wraps**
   (two's-complement truncation) rather than saturates —
   `AccelConfig.accumulator_overflow_mode = "wrap"` is therefore the
   RTL-accurate default, not a guess. `"saturate"` remains available only
   for experimentation/comparison.

3. **Product stage: confirmed, matches, no truncation.**
   `processing_element.sv` zero-extends the unsigned 8-bit pixel to a
   9-bit signed value, multiplies by the 8-bit signed kernel coefficient,
   and assigns the exact result into the 17-bit signed product register.
   This is mathematically identical to `pixel × weight` computed exactly
   (`TestProductWrapModeling` confirms the 17-bit truncation this model
   applies is a no-op for these widths, matching the RTL, which also
   never truncates here).

4. **Output-formatter saturation: confirmed by you directly** — double-
   sided saturation is applied to the accumulated result to produce the
   16-bit output, matching what this model already implements
   (`arithmetic.saturate_signed(relu_out, output_width)`).

5. **File format for test vectors** (`image.txt` / `kernel.txt` /
   `expected.txt`): a simple placeholder text format was invented since
   no existing UVM vector format was available to match against.
   **If the repository already has an established vector format, replace
   `model/io_utils.py` accordingly** — called out as preferred in the
   task spec's design principles.

6. Not yet confirmed: whether ReLU (in the not-yet-reviewed `relu`
   module) operates on the full accumulator width or some other
   intermediate width. The model applies it directly to the raw
   accumulator result, matching the stated data path
   (`MAC Array → ReLU → Output Formatter`).

I'm not fully certain mismatch #6 (ReLU's operating width) matters —
please share the `relu`/`output_formatter` sources when convenient to
close it out, but it doesn't block using this model as-is for the
confirmed default configuration.

## File format

Simple, human-readable text format, one file per array:

```
<height> <width>
<value 1>
<value 2>
...
<value H*W>          (row-major, row 0 first)
```

Each test case lives in its own directory:

```
vectors/
└── positive_kernel/
    ├── image.txt
    ├── kernel.txt
    └── expected.txt
```

See "Assumptions" #3 — swap this for the UVM environment's established
format if one already exists.

## How to run the model

```bash
cd python

# Convolve an existing image/kernel file pair, write expected.txt
python3 run_model.py run \
    --image path/to/image.txt \
    --kernel path/to/kernel.txt \
    --out path/to/expected.txt \
    --n 5 \
    [--no-relu] \
    [--accumulator-overflow wrap|saturate]

# Generate the full deterministic + random test-vector suite
python3 run_model.py generate \
    --out vectors/ \
    --img-h 32 --img-w 32 \
    --n 5 \
    --random 10
```

Programmatic use:

```python
from model.convolution import AccelConfig, convolve

config = AccelConfig(kernel_size=5)
output = convolve(image, kernel, config)  # image, kernel: numpy arrays
```

## How to generate test vectors

`generators/vector_suite.py` provides:

- `deterministic_cases(config, img_h, img_w)` — the spec's named cases:
  all-zero image, all-zero kernel, all-one image, positive kernel,
  negative kernel, mixed-sign kernel, max input values, min/max kernel
  values, and a small known-answer (identity-like) kernel.
- `random_cases(config, count, img_h_range, img_w_range, n_range, seed)` —
  randomized images, kernels, and (optionally) randomized supported
  kernel sizes / image dimensions, seeded for reproducibility.
- `generate_all(output_dir, config, img_h, img_w, n_random)` — writes
  every case above to `output_dir/<case_name>/{image,kernel,expected}.txt`.

An example generated suite (5×5 kernel, 32×32 images, 5 random cases) is
checked into `vectors/` for reference.

## Debug / visualization

`visualize.py` is **not** imported by anything in `model/` or
`generators/` — it's an optional helper you import explicitly when you
want to look at a failing case:

```python
from visualize import show_test_case_from_dir
show_test_case_from_dir("vectors/positive_kernel", rtl_output_path="path/to/actual_rtl_output.txt")
```

Requires `matplotlib` (not a dependency of the core model — install
separately with `pip install matplotlib --break-system-packages` if you
want to use it).

## Running the self-tests

```bash
cd python
python3 -m pytest tests/ -v
```

49 tests covering: fixed-width wrap/saturate arithmetic boundary cases,
output-dimension calculation, input/kernel range validation, hand-computed
known-answer convolutions, ReLU clipping, output saturation, the
wrap-vs-saturate accumulator-overflow divergence case, the confirmed
`MAC_array.sv` accumulator-width formula and its divergence from the
spec's stated 24-bit width, configurable N (non-hard-coded), image sizes
at and above the 32×32 minimum, I/O round-trips, and the full
generator/vector-suite pipeline.

All 49 tests pass as of this writing.
