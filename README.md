# FPGA Edge-AI CNN Convolution Accelerator

A parameterized, streaming **N×N single-channel CNN convolution accelerator** implemented in SystemVerilog for the **IEEE Solid-State Circuits Society (SSCS) Egypt Chapter 2026 Student Design Competition**.

The design targets FPGA-based Edge-AI workloads and combines a streaming line-buffer architecture with a fully parallel MAC array, hardware ReLU activation, output saturation, and a self-checking UVM verification environment backed by an independent bit-accurate Python golden model.

## Overview

The accelerator accepts an 8-bit unsigned grayscale pixel stream and an 8-bit signed programmable convolution kernel. It generates an N×N sliding window, performs the complete convolution using **N² parallel processing elements**, applies ReLU, saturates the result, and stores the final 16-bit signed output.

### Key characteristics

- Parameterized **N×N convolution kernel**
- 8-bit unsigned pixel input
- 8-bit signed kernel coefficients
- Stride-1 convolution
- Streaming pixel processing
- Line-buffer-based sliding-window generation
- Fully parallel **N² MAC datapath**
- FPGA DSP-based multiplication
- 24-bit signed accumulation
- Hardware ReLU activation
- 16-bit signed saturated output
- Parameterized image dimensions
- No full-frame image buffer required
- System-level UVM verification
- Independent Python golden reference model
- FPGA synthesis, place-and-route, timing, and power analysis

## Target Platform

The reported implementation targets the Xilinx Zynq-7000 FPGA family using:

- **Device:** `XC7Z020`
- **Package:** `CLG400`
- **Speed grade:** `-1`
- **Vivado:** 2018.2
- **Top module:** `accelerator_top`

The implementation results reported below are for the **N=3 synthesis configuration**.

## Architecture

The accelerator is organized as a streaming datapath surrounded by configuration and control logic.

```text
                  ┌─────────────────────┐
                  │     input_if        │
                  │ Pixel Registration  │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │   sliding_window    │
                  │                     │
                  │ ┌─────────────────┐ │
                  │ │ sw_addr_manager │ │
                  │ ├─────────────────┤ │
                  │ │ window_valid_gen│ │
                  │ ├─────────────────┤ │
                  │ │window_extractor │ │
                  │ └─────────────────┘ │
                  └──────────┬──────────┘
                             │ N×N window
                             ▼
                  ┌─────────────────────┐
                  │     MAC_array       │
                  │                     │
                  │ N² Processing       │
                  │ Elements + Adder    │
                  │ Tree                │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │        ReLU         │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ output_formatter    │
                  │ Saturation / Format │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │     output_mem      │
                  └─────────────────────┘

        ┌────────────────┐
        │   kernel_mem   │
        │ N² × 8-bit     │
        └───────┬────────┘
                │
                ▼
           MAC_array

        ┌────────────────┐
        │  global_ctrl   │
        │ IDLE → PROCESS │
        │       → DONE   │
        └────────────────┘
```

### Main RTL modules

| Module | Responsibility |
|---|---|
| `accelerator_top` | Top-level integration and external interface |
| `input_if` | Registers incoming pixels and handles input qualifiers |
| `global_ctrl` | Controls accelerator operating states |
| `kernel_mem` | Stores programmable N×N signed kernel coefficients |
| `sliding_window` | Generates convolution windows from the pixel stream |
| `sw_addr_manager` | Tracks row/column position and line-buffer addressing |
| `sw_window_valid_gen` | Determines when a complete valid window exists |
| `sw_window_extractor` | Extracts the current N×N window |
| `processing_element` | Performs one pixel × kernel multiplication |
| `MAC_array` | Instantiates N² processing elements and reduces their products |
| `relu` | Clamps negative convolution results to zero |
| `output_formatter` | Performs output-width conversion and saturation |
| `output_ctrl` | Controls output addressing and frame completion |
| `output_mem` | Stores final output pixels for read-back |

## Dataflow

For every valid convolution position:

1. `input_if` receives and registers an input pixel.
2. `sliding_window` updates its line buffers and tracks the current image position.
3. Once enough pixels have arrived, an N×N window becomes valid.
4. `MAC_array` multiplies every pixel by its corresponding kernel coefficient in parallel.
5. The products are reduced through the MAC adder tree.
6. `relu` clamps negative results to zero.
7. `output_formatter` saturates the result to the 16-bit signed output range.
8. `output_ctrl` writes the result into `output_mem`.
9. After the final output pixel is written, `done` is asserted for one clock cycle.

Once the pipeline is primed, the architecture targets **one completed convolution output per cycle**.

## Control FSM

```text
        start
 IDLE ─────────────► PROCESSING
  ▲                       │
  │                       │ last output
  │                       ▼
  └──────────────────── DONE
             one cycle
```

### `IDLE`

- Accelerator is inactive.
- Kernel coefficients may be written.
- Processing registers remain stable.
- A one-cycle `start` pulse begins processing.

### `PROCESSING`

- Pixel stream is consumed.
- Sliding windows are generated.
- MAC, ReLU, and saturation datapath is active.
- Kernel writes are blocked.
- Output memory is populated.

### `DONE`

- `done` is asserted for one clock cycle.
- The accelerator automatically returns to `IDLE`.

## Numerical Format

| Datapath element | Width | Format |
|---|---:|---|
| Input pixel | 8 bits | Unsigned Q8.0 |
| Kernel coefficient | 8 bits | Signed Q8.0 |
| Product | 17 bits | Signed |
| Accumulator | 24 bits | Signed |
| Final output | 16 bits | Signed |

The 17-bit product width preserves the complete result of an 8-bit unsigned pixel multiplied by an 8-bit signed coefficient.

The top-level design intentionally uses a **fixed 24-bit accumulator**, regardless of N. This simplifies downstream interfaces and provides additional numerical headroom for the reported configurations.

## Memory Organization

The architecture avoids storing the complete input frame on-chip.

### Kernel memory

The kernel requires:

```text
N² × 8 bits
```

Examples:

- N=5 → 25 coefficients → 200 bits / 25 bytes
- N=3 → 9 coefficients → 72 bits / 9 bytes

The kernel storage is implemented without using block RAM in the reported implementation.

### Sliding-window line buffer

The sliding-window storage keeps only N image rows:

```text
N × IMG_WIDTH × 8 bits
```

Storage therefore scales with kernel size and image width rather than total image area.

### Output memory

The final convolution results are stored in `output_mem` for external read-back.

For a 32×32 image with a 5×5 kernel and stride 1:

```text
Output dimensions = 28 × 28
                  = 784 pixels
```

## Verification

The verification strategy uses two levels.

### 1. Unit-level verification

Major RTL blocks are tested independently using directed SystemVerilog testbenches. The verified blocks include the input/control logic, kernel memory, sliding-window subsystem, processing elements, MAC array, ReLU, output formatting/control, and output memory.

### 2. System-level UVM verification

The integrated `accelerator_top` is verified using a layered UVM environment containing:

- Agent
- Driver
- Monitor
- Sequencer
- Scoreboard
- Coverage collector
- Reusable sequences
- Top-level test

The scoreboard compares hardware output against an independently implemented, **bit-accurate Python golden model**.

### Latest reported regression

Configuration:

- Input image: **32×32**
- Kernel: **5×5**
- Stride: **1**
- Padding: **None**
- Expected output: **28×28 = 784 pixels**

| Metric | Result |
|---|---:|
| Output pixels checked | 784 |
| Matching outputs | 784 |
| Mismatches | 0 |
| UVM warnings | 0 |
| UVM errors | 0 |
| UVM fatals | 0 |
| `UVM_INFO` messages | 22,661 |
| Status | **PASS** |

## FPGA Implementation Results

The following results are from the post-route implementation of `accelerator_top` using **N=3**.

| Resource / Metric | Result |
|---|---:|
| LUTs | 444 |
| Flip-Flops | 897 |
| DSP48 slices | 9 |
| RAMB18 | 1 |
| BRAM usage | 0.5 tile |
| Fmax | 95.129 MHz |
| Timing constraint | 95.03 MHz |
| WNS | +0.011 ns |
| Timing status | **MET** |
| Total on-chip power | 130 mW |

### Resource breakdown

| Instance | LUTs | FFs | RAMB18 | DSP48 |
|---|---:|---:|---:|---:|
| `accelerator_top` | 444 | 897 | 1 | 9 |
| `input_if` | 1 | 0 | 0 | 0 |
| `MAC_array` | 106 | 21 | 0 | 9 |
| `processing_element` × 9 | 4* | 0 | 0 | 9 |
| `sliding_window` | 300 | 833 | 0 | 0 |
| `sw_addr_manager` | 299 | 769 | 0 | 0 |
| `sw_window_extractor` | 0 | 48 | 0 | 0 |
| `sw_window_valid_gen` | 1 | 1 | 0 | 0 |
| `global_ctrl` | 14 | 4 | 0 | 0 |
| `output_mem` | 0 | 1 | 1 | 0 |
| `output_formatter` | 1 | 18 | 0 | 0 |
| `output_ctrl` | 12 | 10 | 0 | 0 |

> *Hierarchical LUT attribution can differ from the flat top-level resource count because of synthesis optimizations and cross-hierarchy LUT combining.*

The 9 DSP48 slices correspond exactly to:

```text
N² = 3² = 9
```

confirming the intended fully parallel MAC architecture.

## Timing

Post-route timing closed at the reported constraint:

```text
Clock constraint  : 95.03 MHz
Constrained period : 10.523 ns
WNS                : +0.011 ns
Fmax               : 95.129 MHz
Status             : MET
```

## Power

Power was estimated using the FPGA vendor's default **vectorless** power analysis.

| Component | Estimate |
|---|---:|
| Dynamic power | 25 mW |
| Static power | 105 mW |
| Total power | **130 mW** |

No SAIF/VCD activity annotation was used for this estimate. Therefore, the reported value should be interpreted as a vendor-default implementation estimate rather than an activity-annotated workload measurement.

## Figure of Merit

Using the competition resource weighting:

```text
Resource term = LUTs + 50×DSPs + 100×BRAM

              = 444 + 50×9 + 100×0.5

              = 944
```

With:

```text
Throughput = 1 output/cycle
Power      = 0.130 W
```

the reported Figure of Merit is:

```text
FOM = 1 / (0.130 × 944)

    = 8.148631 × 10⁻³
```

### Reported FOM

**`8.148631 × 10⁻³`**

The fully parallel DSP array is the dominant contributor to the resource-weighted denominator.

## Design Trade-offs

### Fully parallel MAC array

Each kernel tap has its own processing element:

```text
Number of DSPs = N²
```

This supports the one-output-per-cycle steady-state target at the cost of increased DSP utilization.

### Line-buffered streaming architecture

Only N rows are stored instead of the entire image.

Advantages:

- Low memory requirement
- Scales with image width instead of frame area
- Supports larger images
- Enables continuous streaming

Trade-off:

- Pixels must arrive in raster order.
- There is no input-side back-pressure interface.

### Fixed 24-bit accumulator

A fixed accumulator width simplifies the downstream datapath and interfaces.

Trade-off:

- The width is not optimized for every possible N.
- Larger kernel sizes require re-evaluation of the numerical range.

### ReLU implementation

ReLU is implemented directly in hardware.

Trade-off:

- The current implementation cannot bypass ReLU.
- Signed negative convolution outputs cannot currently be exposed directly without an RTL modification.

## Bonus Features

Two optional features were implemented:

### Hardware ReLU

Negative accumulated values are clamped to zero directly in the hardware datapath.

### Runtime-programmable, size-configurable kernel

The kernel is loaded through `kernel_mem` before processing begins and is parameterized by N.

## Assumptions

The implementation makes the following assumptions documented in the final design report:

- Input pixels arrive in raster order.
- The upstream source does not require back-pressure.
- Kernel coefficients are loaded before processing starts.
- Kernel writes are not allowed while the accelerator is busy.
- Reset is synchronous and active-low.
- The top-level accumulator width is fixed at 24 bits.
- ReLU is always active in the current implementation.

## Limitations and Future Work

Current limitations include:

- No input back-pressure interface.
- ReLU cannot currently be bypassed.
- The reported system-level verification evidence covers the complete 32×32 / 5×5 regression; the report does not claim that every listed deterministic/randomized vector has been demonstrated in the supplied evidence.
- Power is based on a vendor-default vectorless estimate rather than activity-annotated simulation.
- The fixed 24-bit accumulator is not automatically optimized for every kernel size.

Potential future improvements include:

- Activity-based power estimation using VCD/SAIF data.
- Additional randomized and corner-case regression coverage.
- Optional ReLU bypass.
- Input-side flow control/back-pressure.
- Further optimization of sliding-window address-management logic.
- Evaluation of alternative MAC architectures and resource/throughput trade-offs.
- Application-level demonstrations such as edge detection or industrial inspection.

## Repository Structure

The repository separates RTL, unit-level verification, system-level UVM verification, and Python reference-model tooling.

```text
fpga-cnn-accelerator/
├── rtl/
│   └── accelerator_top.sv
│
├── tb/
│   ├── unit/
│   └── integ/
│
├── ...
└── README.md
```

The complete repository also contains the supporting RTL modules, verification environment, golden-model/vector-generation tooling, and project documentation.

## Project Repository

**GitHub:** https://github.com/kareem05-ash/fpga-cnn-accelerator

## Technology Stack

- **SystemVerilog** — RTL implementation
- **UVM** — system-level verification
- **Python** — bit-accurate golden model and verification support
- **Xilinx Vivado 2018.2** — synthesis, implementation, timing, and power analysis
- **Xilinx Zynq-7000 XC7Z020** — target FPGA

## Final Status

| Area | Status |
|---|---|
| Mandatory convolution functionality | **Implemented** |
| Parameterized kernel/image dimensions | **Implemented** |
| Streaming sliding-window architecture | **Implemented** |
| Parallel MAC datapath | **Implemented** |
| ReLU bonus feature | **Implemented** |
| Runtime kernel programming | **Implemented** |
| Unit-level verification | **Implemented** |
| UVM system-level verification | **PASS** |
| Python golden-model comparison | **784/784 PASS** |
| Post-route timing | **MET** |
| FPGA implementation | **Completed** |
| Power estimation | **Completed** |
| Competition FOM | **8.148631 × 10⁻³** |

## Acknowledgment

Developed by **Nexus Team** for the **IEEE Solid-State Circuits Society (SSCS) Egypt Chapter 2026 Student Design Competition**.

The architecture, verification methodology, implementation results, assumptions, and limitations documented here are based on the project's final technical report.
