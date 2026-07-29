# FPGA-Based Edge-AI Vision Accelerator
## Detailed Design Specification
 
---
# Table of Contents
 
- [Part 1: Introduction](#part-1)
  - [5. Accelerator Overview](#part-1-s1)
  - [6. Target FPGA](#part-1-s2)
  - [7. Naming Conventions](#part-1-s3)
  - [8. Frozen Architecture](#part-1-s4)
- [Part 2: Competition Requirements & System-Level Functional Specification](#part-2)
  - [2. Functional Requirements](#part-2-s1)
  - [3. Design Goals](#part-2-s2)
  - [4. Design Constraints](#part-2-s3)
  - [5. System-Level Processing Sequence](#part-2-s4)
  - [6. Chapter Summary](#part-2-s5)
- [Part 3: High-Level Architecture](#part-3)
  - [2. Top-Level Architecture](#part-3-s1)
  - [3. Data Path](#part-3-s2)
  - [4. Control Path](#part-3-s3)
  - [5. Configuration Path](#part-3-s4)
  - [6. Module List](#part-3-s5)
  - [7. Responsibilities of Each Module](#part-3-s6)
  - [8. Datapath Philosophy](#part-3-s7)
  - [9. Parameterization Strategy](#part-3-s8)
  - [10. Data Lifetime](#part-3-s9)
  - [11. Design Principles](#part-3-s10)
- [Part 4: Global Accelerator Operation](#part-4)
  - [2. Accelerator Life Cycle](#part-4-s1)
  - [3. Phase 1 — Configuration](#part-4-s2)
  - [4. Phase 2 — Processing](#part-4-s3)
  - [5. Phase 3 — Completion](#part-4-s4)
  - [6. Global FSM](#part-4-s5)
  - [7. State Descriptions](#part-4-s6)
  - [8. Module Activation Timeline](#part-4-s7)
  - [9. Startup Latency](#part-4-s8)
  - [10. Steady-State Operation](#part-4-s9)
  - [11. Accelerator Restart](#part-4-s10)
  - [12. Responsibilities of the Global Controller](#part-4-s11)
  - [13. Design Notes](#part-4-s12)
- [Part 5: Module Specification — cfg.sv](#part-5)
  - [5. Configuration Registers](#part-5-s1)
  - [6. Future Expansion](#part-5-s2)
  - [7. Module Interface](#part-5-s3)
  - [8. Reset Behavior](#part-5-s4)
  - [9. Timing](#part-5-s5)
  - [10. Interaction with Global Controller](#part-5-s6)
  - [11. Design Rules](#part-5-s7)
  - [12. Verification Checklist](#part-5-s8)
  - [13. RTL Notes](#part-5-s9)
- [Part 6: Top-Level Module Specification — dut_top.sv](#part-6)
  - [2. Top-Level Architecture](#part-6-s1)
  - [3. Internal Module Hierarchy](#part-6-s2)
  - [4. External Interface](#part-6-s3)
  - [5. Internal Connectivity](#part-6-s4)
  - [6. Top-Level Responsibilities](#part-6-s5)
  - [7. Non-Responsibilities](#part-6-s6)
  - [8. Design Rules](#part-6-s7)
  - [9. Verification Checklist](#part-6-s8)
  - [10. RTL Notes](#part-6-s9)
- [Part 7: Module Specification — global_ctrl.sv](#part-7)
  - [2. Position in the Architecture](#part-7-s1)
  - [3. Responsibilities](#part-7-s2)
  - [4. Non-Responsibilities](#part-7-s3)
  - [5. Inputs](#part-7-s4)
  - [6. Outputs](#part-7-s5)
  - [7. FSM](#part-7-s6)
  - [8. State Description](#part-7-s7)
  - [9. Timing Diagram](#part-7-s8)
  - [10. State Transition Table](#part-7-s9)
  - [11. Reset Behavior](#part-7-s10)
  - [12. Interaction with Other Modules](#part-7-s11)
  - [13. Corner Cases](#part-7-s12)
  - [14. Verification Checklist](#part-7-s13)
  - [15. RTL Implementation Notes](#part-7-s14)
  - [16. Future Extensions](#part-7-s15)
- [Part 8: Module Specification — input_if.sv](#part-8)
  - [2. Position in the Architecture](#part-8-s1)
  - [3. Responsibilities](#part-8-s2)
  - [4. Non-Responsibilities](#part-8-s3)
  - [5. Internal Streaming Protocol](#part-8-s4)
  - [6. Inputs](#part-8-s5)
  - [7. Outputs](#part-8-s6)
  - [8. Functional Description](#part-8-s7)
  - [9. Timing](#part-8-s8)
  - [10. Reset Behavior](#part-8-s9)
  - [11. Design Rules](#part-8-s10)
  - [12. Future Extensions](#part-8-s11)
  - [13. Verification Checklist](#part-8-s12)
  - [14. RTL Implementation Notes](#part-8-s13)
  - [15. Design Philosophy](#part-8-s14)
- [Part 9: Module Specification — input_ctrl.sv](#part-9)
  - [2. Position in the Architecture](#part-9-s1)
  - [3. Responsibilities](#part-9-s2)
  - [4. Non-Responsibilities](#part-9-s3)
  - [5. Inputs](#part-9-s4)
  - [6. Outputs](#part-9-s5)
  - [7. Internal Registers](#part-9-s6)
  - [8. Functional Description](#part-9-s7)
  - [9. Timing](#part-9-s8)
  - [10. Reset Behavior](#part-9-s9)
  - [11. Interaction with Other Modules](#part-9-s10)
  - [12. Design Rules](#part-9-s11)
  - [13. Corner Cases](#part-9-s12)
  - [14. Verification Checklist](#part-9-s13)
  - [15. RTL Implementation Notes](#part-9-s14)
  - [16. Future Extensions](#part-9-s15)
- [Part 10: Module Specification — kernel_mem.sv](#part-10)
  - [2. Position in the Architecture](#part-10-s1)
  - [3. Responsibilities](#part-10-s2)
  - [4. Non-Responsibilities](#part-10-s3)
  - [5. Kernel Organization](#part-10-s4)
  - [6. Parameters](#part-10-s5)
  - [7. Inputs](#part-10-s6)
  - [8. Outputs](#part-10-s7)
  - [9. Internal Memory](#part-10-s8)
  - [10. Functional Description](#part-10-s9)
  - [11. Read Strategy](#part-10-s10)
  - [12. Reset Behavior](#part-10-s11)
  - [13. Interaction with Other Modules](#part-10-s12)
  - [14. Design Rules](#part-10-s13)
  - [15. Corner Cases](#part-10-s14)
  - [16. Verification Checklist](#part-10-s15)
  - [17. RTL Notes](#part-10-s16)
  - [18. Design Rationale](#part-10-s17)
- [Part 11: Module Specification — sliding_window.sv](#part-11)
  - [2. Position in the Architecture](#part-11-s1)
  - [3. Responsibilities](#part-11-s2)
  - [4. Non-Responsibilities](#part-11-s3)
  - [5. Design Philosophy](#part-11-s4)
  - [6. Internal Architecture](#part-11-s5)
  - [7. Line Buffers](#part-11-s6)
  - [8. Window Generator](#part-11-s7)
  - [9. Inputs](#part-11-s8)
  - [10. Outputs](#part-11-s9)
  - [11. Internal Storage](#part-11-s10)
  - [12. Startup Behavior](#part-11-s11)
  - [13. Steady-State Operation](#part-11-s12)
  - [14. Reset Behavior](#part-11-s13)
  - [15. Interaction with Other Modules](#part-11-s14)
  - [16. Design Rules](#part-11-s15)
  - [17. Corner Cases](#part-11-s16)
  - [18. Verification Checklist](#part-11-s17)
  - [19. RTL Implementation Notes](#part-11-s18)
  - [20. Design Rationale](#part-11-s19)
- [Part 12: Module Specification — processing_element.sv](#part-12)
  - [2. Position in the Architecture](#part-12-s1)
  - [3. Responsibilities](#part-12-s2)
  - [4. Non-Responsibilities](#part-12-s3)
  - [5. Mathematical Operation](#part-12-s4)
  - [6. Input Data Types](#part-12-s5)
  - [7. Output Data Type](#part-12-s6)
  - [8. Inputs](#part-12-s7)
  - [9. Outputs](#part-12-s8)
  - [10. Functional Description](#part-12-s9)
  - [11. Signed Arithmetic](#part-12-s10)
  - [12. DSP Inference](#part-12-s11)
  - [13. Pipeline Considerations](#part-12-s12)
  - [14. Reset Behavior](#part-12-s13)
  - [15. Interaction with Other Modules](#part-12-s14)
  - [16. Design Rules](#part-12-s15)
  - [17. Corner Cases](#part-12-s16)
  - [18. Verification Checklist](#part-12-s17)
  - [19. RTL Implementation Notes](#part-12-s18)
  - [20. Design Rationale](#part-12-s19)
- [Part 13: Module Specification — MAC_array.sv](#part-13)
  - [2. Position in the Architecture](#part-13-s1)
  - [3. Internal Architecture](#part-13-s2)
  - [4. Responsibilities](#part-13-s3)
  - [5. Non-Responsibilities](#part-13-s4)
  - [6. Inputs](#part-13-s5)
  - [7. Outputs](#part-13-s6)
  - [8. Processing Element Organization](#part-13-s7)
  - [9. Row Reduction](#part-13-s8)
  - [10. Partial Sum Width](#part-13-s9)
  - [11. Functional Description](#part-13-s10)
  - [12. Timing](#part-13-s11)
  - [13. Reset Behavior](#part-13-s12)
  - [14. Interaction with Other Modules](#part-13-s13)
  - [15. Design Rules](#part-13-s14)
  - [16. Corner Cases](#part-13-s15)
  - [17. Verification Checklist](#part-13-s16)
  - [18. RTL Implementation Notes](#part-13-s17)
  - [19. Design Rationale](#part-13-s18)
  - [20. Resource Considerations](#part-13-s19)
- [Part 14: Module Specification — accumulator.sv](#part-14)
  - [2. Position in the Architecture](#part-14-s1)
  - [3. Responsibilities](#part-14-s2)
  - [4. Non-Responsibilities](#part-14-s3)
  - [5. Inputs](#part-14-s4)
  - [6. Outputs](#part-14-s5)
  - [7. Datapath](#part-14-s6)
  - [8. Arithmetic Operation](#part-14-s7)
  - [9. Output Width](#part-14-s8)
  - [10. Functional Description](#part-14-s9)
  - [11. Timing](#part-14-s10)
  - [12. Reset Behavior](#part-14-s11)
  - [13. Interaction with Other Modules](#part-14-s12)
  - [14. Design Rules](#part-14-s13)
  - [15. Corner Cases](#part-14-s14)
  - [16. Verification Checklist](#part-14-s15)
  - [17. RTL Implementation Notes](#part-14-s16)
  - [18. Design Rationale](#part-14-s17)
  - [19. Resource Considerations](#part-14-s18)
- [Part 15: Module Specification — relu.sv](#part-15)
  - [2. Position in the Architecture](#part-15-s1)
  - [3. Responsibilities](#part-15-s2)
  - [4. Non-Responsibilities](#part-15-s3)
  - [5. Mathematical Operation](#part-15-s4)
  - [6. Inputs](#part-15-s5)
  - [7. Outputs](#part-15-s6)
  - [8. Functional Description](#part-15-s7)
  - [9. Timing](#part-15-s8)
  - [10. Reset Behavior](#part-15-s9)
  - [11. Interaction with Other Modules](#part-15-s10)
  - [12. Design Rules](#part-15-s11)
  - [13. Corner Cases](#part-15-s12)
  - [14. Verification Checklist](#part-15-s13)
  - [15. RTL Implementation Notes](#part-15-s14)
  - [16. Design Rationale](#part-15-s15)
  - [17. Resource Considerations](#part-15-s16)
- [Part 16: Module Specification — output_formatter.sv](#part-16)
  - [2. Position in the Architecture](#part-16-s1)
  - [3. Responsibilities](#part-16-s2)
  - [4. Non-Responsibilities](#part-16-s3)
  - [5. Processing Pipeline](#part-16-s4)
  - [6. Inputs](#part-16-s5)
  - [7. Outputs](#part-16-s6)
  - [8. Stage 1 — Scaling](#part-16-s7)
  - [9. Stage 2 — Optional Rounding](#part-16-s8)
  - [10. Stage 3 — Saturation](#part-16-s9)
  - [11. Functional Description](#part-16-s10)
  - [12. Timing](#part-16-s11)
  - [13. Reset Behavior](#part-16-s12)
  - [14. Interaction with Other Modules](#part-16-s13)
  - [15. Design Rules](#part-16-s14)
  - [16. Corner Cases](#part-16-s15)
  - [17. Verification Checklist](#part-16-s16)
  - [18. RTL Implementation Notes](#part-16-s17)
  - [19. Design Rationale](#part-16-s18)
  - [20. Resource Considerations](#part-16-s19)
- [Part 17: Module Specification — output_ctrl.sv](#part-17)
  - [2. Position in the Architecture](#part-17-s1)
  - [3. Responsibilities](#part-17-s2)
  - [4. Non-Responsibilities](#part-17-s3)
  - [5. Inputs](#part-17-s4)
  - [6. Outputs](#part-17-s5)
  - [7. Internal Registers](#part-17-s6)
  - [8. Functional Description](#part-17-s7)
  - [9. Completion Detection](#part-17-s8)
  - [10. Timing](#part-17-s9)
  - [11. Reset Behavior](#part-17-s10)
  - [12. Interaction with Other Modules](#part-17-s11)
  - [13. Design Rules](#part-17-s12)
  - [14. Corner Cases](#part-17-s13)
  - [15. Verification Checklist](#part-17-s14)
  - [16. RTL Implementation Notes](#part-17-s15)
  - [17. Design Rationale](#part-17-s16)
  - [18. Resource Considerations](#part-17-s17)
- [Part 18: Module Specification — global_ctrl.sv  ⚠️ duplicate of Part 7 (global_ctrl.sv specified twice)](#part-18)
  - [2. Position in the Architecture](#part-18-s1)
  - [3. Responsibilities](#part-18-s2)
  - [4. Non-Responsibilities](#part-18-s3)
  - [5. Inputs](#part-18-s4)
  - [6. Outputs](#part-18-s5)
  - [7. FSM States](#part-18-s6)
  - [8. State Descriptions](#part-18-s7)
  - [9. Reset Behavior](#part-18-s8)
  - [10. Verification Checklist](#part-18-s9)
  - [11. RTL Notes](#part-18-s10)
  - [12. Design Philosophy](#part-18-s11)
- [Appended Section: Module Specification — dut_top.sv  ⚠️ duplicate of Part 6 (dut_top.sv specified twice; not numbered as a Part in the source)](#part-18-s12)
  - [2. Instantiated Modules](#part-18-s13)
  - [3. Interconnection](#part-18-s14)
  - [4. Top-Level Responsibilities](#part-18-s15)
  - [5. Non-Responsibilities](#part-18-s16)
  - [6. Coding Guidelines](#part-18-s17)
  - [7. Verification Checklist](#part-18-s18)
  - [8. Final Frozen RTL Files](#part-18-s19)
  - [9. Final Architecture Summary](#part-18-s20)
- [End of Detailed Specification](#end-of-spec)
---
 
<a id="part-1"></a>
# Part 1 / 18
# Introduction
 
## 1. Purpose
 
This document defines the complete architecture and RTL implementation specification of the FPGA-Based Edge-AI Vision Accelerator developed for the **IEEE SSCS Egypt Chapter 2026 Student Design Competition**.
 
Unlike the competition specification, which describes **what** the accelerator must accomplish, this document describes **how** the accelerator shall be implemented.
 
Its primary objective is to serve as the single source of truth for every team member throughout the project lifecycle.
 
Every RTL module, interface, parameter, controller, memory block, and datapath described in this document shall be considered the official implementation reference.
 
No architectural decision should be made during RTL coding unless this document is updated accordingly.
 
---
 
## 2. Document Objectives
 
This specification has the following objectives:
 
- Define the complete accelerator architecture before RTL implementation.
- Freeze all major architectural decisions.
- Eliminate ambiguity between team members.
- Define every RTL module responsibilities.
- Define all module interfaces.
- Define dataflow throughout the accelerator.
- Define the interaction between datapath and control path.
- Reduce integration issues during development.
- Simplify verification planning.
- Improve maintainability and readability.
After this document is completed, every RTL module should be implementable directly from its corresponding specification chapter without requiring additional architectural discussions.
 
---
 
## 3. Scope
 
This document covers every hardware component implemented inside the accelerator including:
 
- Global controller
- Configuration registers
- Input interface
- Input controller
- Kernel memory
- Sliding Window subsystem
- Processing Elements
- MAC Array
- Accumulator
- ReLU
- Output Formatter
- Output Controller
- Output Memory
- Top-level integration
Verification methodology is discussed only at the architectural level. The complete verification plan is provided in a separate document.
 
---
 
## 4. Design Philosophy
 
The accelerator follows four major design principles.
 
### 4.1 Streaming Architecture
 
The accelerator processes pixels while they are arriving instead of waiting for the entire image.
 
Advantages:
 
- Lower latency
- Better throughput
- Reduced memory requirements
- Improved FPGA resource utilization
---
 
### 4.2 Modular Design
 
Every hardware block performs one clearly defined task.
 
Each module owns a single responsibility and communicates with other modules only through well-defined interfaces.
 
This improves:
 
- readability
- verification
- debugging
- scalability
- reuse
---
 
### 4.3 Parameterized RTL
 
Whenever changing a design parameter affects the hardware structure, that parameter shall be implemented as a compile-time parameter.
 
Examples include:
 
- Kernel size (N)
Runtime configuration registers are reserved only for values that naturally change between accelerator executions, such as:
 
- Image width
- Image height
- Kernel coefficients
- ReLU enable
- Output formatter configuration
---
 
### 4.4 Resource-Aware Design
 
The competition Figure of Merit heavily penalizes DSP and BRAM utilization.
 
Therefore, every architectural decision shall consider its effect on:
 
- Throughput
- LUT utilization
- DSP utilization
- BRAM utilization
- Estimated power consumption
Performance improvements that significantly increase FPGA resource utilization should be avoided unless they provide a clear Figure-of-Merit advantage.
 
---
 
<a id="part-1-s1"></a>
# 5. Accelerator Overview
 
The accelerator performs programmable two-dimensional convolution on a single-channel grayscale image or feature map.
 
The processing pipeline consists of:
 
1. Receiving image pixels.
2. Constructing valid sliding windows.
3. Multiplying image pixels by programmable kernel coefficients.
4. Accumulating partial products.
5. Applying an optional ReLU activation.
6. Formatting the output.
7. Storing the output feature map.
The accelerator is fully controlled by a centralized Global Controller that coordinates every processing stage.
 
---
 
<a id="part-1-s2"></a>
# 6. Target FPGA
 
The RTL shall remain FPGA-vendor independent whenever possible.
 
Vendor-specific IPs shall be avoided unless required by synthesis or implementation constraints.
 
Arithmetic operations should infer FPGA DSP resources automatically through synthesis.
 
Similarly, memory structures should infer FPGA Block RAM whenever appropriate.
 
---
 
<a id="part-1-s3"></a>
# 7. Naming Conventions
 
The following naming conventions shall be used throughout the project.
 
| Item | Convention | Example |
|-------|------------|---------|
| Modules | snake_case | `global_ctrl.sv` |
| Parameters | UPPER_CASE | `parameter N = 5` |
| Local Parameters | UPPER_CASE | `localparam IDLE = 0` |
| Signals | snake_case | `window_valid` |
| Registers | snake_case | `pixel_counter` |
| FSM States | UPPER_CASE | `PROCESSING` |
| Constants | UPPER_CASE | `MAX_PIXEL_VALUE` |
 
---
 
<a id="part-1-s4"></a>
# 8. Frozen Architecture
 
The following architectural decisions have been officially frozen.
 
## AD-001
 
Streaming architecture.
 
Entire input images shall **not** be buffered before processing.
 
---
 
## AD-002
 
Input image dimensions shall be runtime configurable through configuration registers.
 
---
 
## AD-003
 
Kernel coefficients shall be runtime programmable through Kernel Memory.
 
---
 
## AD-004
 
Kernel dimension shall be implemented as a compile-time RTL parameter.
 
```systemverilog
parameter int N = 5;
```
 
---
 
## AD-005
 
The accelerator shall support only single-channel grayscale images.
 
---
 
## AD-006
 
Input pixels shall use 8-bit unsigned integer representation.
 
---
 
## AD-007
 
Kernel coefficients shall use 8-bit signed integer representation.
 
---
 
## AD-008
 
Stride is fixed to one.
 
No runtime or compile-time stride configuration shall be supported.
 
---
 
## AD-009
 
ReLU shall be implemented as an optional hardware block controlled by configuration registers.
 
---
 
## AD-010
 
The output formatter shall support configurable output shifting, optional rounding, and saturation before producing the final 16-bit signed output.
 
---
 
<a id="part-2"></a>
# Part 2 / 18
# Competition Requirements & System-Level Functional Specification
 
## 1. Introduction
 
This chapter translates the official competition requirements into concrete implementation requirements for the RTL design.
 
The objective is to eliminate ambiguity before implementation begins. Every requirement listed in this chapter has already been analyzed and its architectural decision has been frozen.
 
---
 
<a id="part-2-s1"></a>
# 2. Functional Requirements
 
## FR-001 — Input Image
 
The accelerator shall process a single-channel grayscale image (or feature map).
 
### Implementation Decision
 
- Number of channels = 1
- RGB images are not supported.
- Multi-channel convolution is outside the scope of this project.
---
 
## FR-002 — Image Dimensions
 
The accelerator shall support images with dimensions of at least:
 
- 32 × 32 pixels
Larger image dimensions shall also be supported.
 
### Implementation Decision
 
Image dimensions shall be programmable at runtime through configuration registers.
 
The following configuration registers shall exist:
 
| Register | Description |
|----------|-------------|
| IMG_WIDTH | Width of the input image |
| IMG_HEIGHT | Height of the input image |
 
These registers shall be written before asserting the START signal.
 
---
 
## FR-003 — Input Data Type
 
Each input pixel shall be represented as:
 
- Unsigned integer
- 8 bits
### Representation
 
```text
U8.0
```
 
Valid range:
 
```text
0 ... 255
```
 
---
 
## FR-004 — Kernel
 
The accelerator shall perform N × N convolution.
 
### Implementation Decision
 
Kernel dimension shall be a compile-time RTL parameter.
 
Example:
 
```systemverilog
parameter int N = 5;
```
 
Changing N requires RTL resynthesis.
 
---
 
## FR-005 — Kernel Coefficients
 
Kernel coefficients shall be programmable.
 
### Implementation Decision
 
Kernel coefficients shall be stored inside `kernel_mem.sv`.
 
The kernel shall be loaded before processing begins.
 
The accelerator shall never modify kernel coefficients internally.
 
---
 
## FR-006 — Kernel Precision
 
Each kernel coefficient shall use:
 
- Signed integer
- 8 bits
Representation:
 
```text
S8.0
```
 
Valid range:
 
```text
-128 ... +127
```
 
---
 
## FR-007 — Stride
 
Stride is fixed to:
 
```text
1
```
 
### Implementation Decision
 
Stride is not configurable.
 
Neither compile-time nor runtime stride modification is supported.
 
---
 
## FR-008 — Output Precision
 
The accelerator output shall be:
 
- Signed
- Minimum 16 bits
### Implementation Decision
 
Final output width:
 
```text
16 bits
```
 
Internal computation width may exceed 16 bits.
 
---
 
## FR-009 — ReLU
 
ReLU is considered an optional feature by the competition.
 
### Implementation Decision
 
ReLU shall be implemented.
 
The block shall be enabled or disabled through a configuration register.
 
When disabled:
 
```text
Input = Output
```
 
When enabled:
 
```text
Output = max(0, Input)
```
 
---
 
## FR-010 — Verification
 
Hardware results shall be compared against a software golden model.
 
### Implementation Decision
 
Golden model language:
 
```text
Python
```
 
Comparison shall be automatic.
 
Expected output shall exactly match RTL output.
 
---
 
## FR-011 — FPGA Implementation
 
The RTL shall be synthesizable.
 
Implementation results shall include:
 
- LUT utilization
- FF utilization
- DSP utilization
- BRAM utilization
- Maximum operating frequency
- Timing status
- Estimated power
---
 
## FR-012 — Figure of Merit
 
The competition evaluates the accelerator using
 
```text
FoM =
Throughput
──────────────────────────────────────────────
Power × ( LUT + 50 × DSP + 100 × BRAM )
```
 
where
 
Throughput is measured as
 
```text
Output Pixels / Clock Cycle
```
 
---
 
<a id="part-2-s2"></a>
# 3. Design Goals
 
The project shall optimize the following objectives.
 
## Primary Goals
 
- Functional correctness
- Modular architecture
- Clean RTL implementation
- Parameterized design
- Low FPGA resource utilization
- High Figure of Merit
---
 
## Secondary Goals
 
- Readable RTL
- Easy verification
- Easy debugging
- Vendor-independent implementation
- Future extensibility
---
 
<a id="part-2-s3"></a>
# 4. Design Constraints
 
The following constraints shall be respected during development.
 
## C-001
 
Streaming architecture shall be used.
 
Entire images shall not be buffered before processing.
 
---
 
## C-002
 
Every RTL module shall have a single responsibility.
 
No module shall perform unrelated tasks.
 
---
 
## C-003
 
Compile-time parameters shall only be used when changing their value modifies hardware structure.
 
Examples:
 
- Kernel dimension
Runtime registers shall only configure execution.
 
Examples:
 
- Image width
- Image height
- Kernel coefficients
- ReLU enable
- Output formatter options
---
 
## C-004
 
All arithmetic shall infer FPGA DSP blocks whenever possible.
 
No vendor-specific multiplier IP shall be instantiated unless required.
 
---
 
## C-005
 
Memory structures shall infer FPGA BRAM whenever appropriate.
 
---
 
<a id="part-2-s4"></a>
# 5. System-Level Processing Sequence
 
One complete accelerator execution shall follow the sequence below.
 
```text
1. Configuration registers are written.
 
2. Kernel coefficients are loaded.
 
3. START signal is asserted.
 
4. Global Controller enters PROCESSING state.
 
5. Input Interface begins receiving pixels.
 
6. Input Controller forwards pixels to Sliding Window.
 
7. Sliding Window generates valid windows.
 
8. MAC Array computes partial products.
 
9. Accumulator generates convolution result.
 
10. Optional ReLU is applied.
 
11. Output Formatter performs:
    • Optional right shift
    • Optional rounding
    • Saturation
    • Width conversion
 
12. Output Controller stores output pixels.
 
13. DONE signal is asserted.
 
14. Global Controller returns to IDLE.
```
 
---
 
<a id="part-2-s5"></a>
# 6. Chapter Summary
 
At this point, every competition requirement has been translated into a concrete architectural requirement.
 
The remaining chapters define how these requirements are realized by the accelerator architecture.
 
---
 
<a id="part-3"></a>
# Part 3 / 18
# High-Level Architecture
 
## 1. Introduction
 
This chapter defines the complete accelerator architecture at the system level.
 
The purpose of this chapter is to answer three questions before any RTL implementation begins:
 
1. What are the RTL modules?
2. How do they communicate?
3. How does one input pixel become one output pixel?
After this chapter, every team member should understand the accelerator without looking at the RTL.
 
---
 
<a id="part-3-s1"></a>
# 2. Top-Level Architecture
 
The accelerator consists of three major subsystems:
 
1. Control Path
2. Data Path
3. Configuration Path
```text
                    +----------------+
                    |    cfg.sv      |
                    +-------+--------+
                            |
                            |
                            v
                    +----------------+
                    | global_ctrl.sv |
                    +-------+--------+
                            |
          -----------------------------------------
          |                   |                  |
          |                   |                  |
          v                   v                  v
     input_ctrl         output_ctrl        kernel_mem
```
 
The configuration path provides runtime configuration.
 
The control path coordinates module operation.
 
The data path performs convolution.
 
---
 
<a id="part-3-s2"></a>
# 3. Data Path
 
The complete processing pipeline is shown below.
 
```text
                Input Pixels
                     │
                     ▼
              +---------------+
              |   input_if     |
              +---------------+
                     │
                     ▼
              +---------------+
              |  input_ctrl    |
              +---------------+
                     │
                     ▼
        +-----------------------------+
        |     sliding_window          |
        |-----------------------------|
        | Line Buffers                |
        | Window Generator            |
        +-----------------------------+
                     │
                     │ Window
                     ▼
              +---------------+
              |   MAC_array   |
              +---------------+
                     │
              Partial Products
                     │
                     ▼
              +---------------+
              | accumulator   |
              +---------------+
                     │
             Convolution Result
                     │
                     ▼
              +---------------+
              |     relu      |
              +---------------+
                     │
                     ▼
          +----------------------+
          | output_formatter     |
          +----------------------+
                     │
                     ▼
              +---------------+
              | output_ctrl   |
              +---------------+
                     │
                     ▼
              +---------------+
              | output_mem    |
              +---------------+
                     │
                     ▼
              Output Feature Map
```
 
---
 
<a id="part-3-s3"></a>
# 4. Control Path
 
Unlike the datapath, which transports pixel values, the control path transports commands and status signals.
 
The Global Controller is the only module responsible for controlling accelerator execution.
 
```text
                    START
                      │
                      ▼
             +----------------+
             | global_ctrl    |
             +----------------+
                      │
      ---------------------------------------
      │          │          │               │
      ▼          ▼          ▼               ▼
 input_ctrl  sliding_window MAC_array  output_ctrl
```
 
Every processing stage begins only after being enabled by the Global Controller.
 
No datapath module shall autonomously start or stop the accelerator.
 
---
 
<a id="part-3-s4"></a>
# 5. Configuration Path
 
Runtime configuration is provided through configuration registers.
 
```text
                Software
                   │
                   ▼
              +----------+
              | cfg.sv   |
              +----------+
                   │
       ----------------------------
       │            │             │
       ▼            ▼             ▼
 Image Size    ReLU Enable   Output Format
```
 
Configuration registers shall be written before START is asserted.
 
Configuration values remain constant during processing.
 
Changing configuration while the accelerator is busy is not supported.
 
---
 
<a id="part-3-s5"></a>
# 6. Module List
 
The accelerator consists of the following RTL modules.
 
| Module | Category | Purpose |
|---------|----------|---------|
| `dut_top.sv` | Top-Level | Integrates the entire accelerator |
| `cfg.sv` | Configuration | Stores runtime configuration registers |
| `global_ctrl.sv` | Controller | Controls accelerator execution |
| `input_if.sv` | Interface | Receives external image data |
| `input_ctrl.sv` | Controller | Controls pixel flow |
| `kernel_mem.sv` | Memory | Stores programmable kernel coefficients |
| `sliding_window.sv` | Datapath | Generates N×N windows |
| `processing_element.sv` | Datapath | Performs one signed multiplication |
| `MAC_array.sv` | Datapath | Computes row partial products |
| `accumulator.sv` | Datapath | Accumulates partial sums |
| `relu.sv` | Datapath | Optional activation function |
| `output_formatter.sv` | Datapath | Shift, rounding, saturation, width conversion |
| `output_ctrl.sv` | Controller | Controls output generation |
| `output_mem.sv` | Memory | Stores output feature map |
 
---
 
<a id="part-3-s6"></a>
# 7. Responsibilities of Each Module
 
To avoid duplicated functionality, every RTL module owns exactly one primary responsibility.
 
| Module | Primary Responsibility |
|---------|------------------------|
| cfg | Store configuration |
| global_ctrl | Sequence accelerator execution |
| input_if | Interface with external source |
| input_ctrl | Manage input pixel flow |
| kernel_mem | Store kernel coefficients |
| sliding_window | Produce valid N×N windows |
| processing_element | Multiply one pixel and one kernel coefficient |
| MAC_array | Produce one partial sum every cycle |
| accumulator | Generate final convolution result |
| relu | Clamp negative values to zero (optional) |
| output_formatter | Produce final output value |
| output_ctrl | Manage output storage |
| output_mem | Store output pixels |
 
No module shall assume responsibilities assigned to another module.
 
---
 
<a id="part-3-s7"></a>
# 8. Datapath Philosophy
 
The accelerator follows a streaming architecture.
 
Pixels move continuously through the datapath.
 
Entire images are never buffered.
 
Only the minimum amount of information required to generate the next sliding window is stored.
 
This minimizes:
 
- BRAM usage
- Latency
- Idle cycles
while maximizing data reuse.
 
---
 
<a id="part-3-s8"></a>
# 9. Parameterization Strategy
 
The architecture distinguishes between compile-time parameters and runtime configuration.
 
## Compile-Time Parameters
 
Compile-time parameters modify hardware structure.
 
Examples:
 
- Kernel dimension (N)
Changing these parameters requires RTL resynthesis.
 
---
 
## Runtime Configuration
 
Runtime configuration changes accelerator behavior without changing hardware.
 
Examples:
 
- Image width
- Image height
- Kernel coefficients
- ReLU enable
- Output formatter configuration
These values are written into `cfg.sv` before processing begins.
 
---
 
<a id="part-3-s9"></a>
# 10. Data Lifetime
 
Each piece of data exists only where it is needed.
 
| Data | Owner Module |
|------|--------------|
| Input Pixels | `input_if.sv` |
| Sliding Window | `sliding_window.sv` |
| Kernel Coefficients | `kernel_mem.sv` |
| Partial Products | `MAC_array.sv` |
| Partial Sum | `accumulator.sv` |
| Final Pixel | `output_formatter.sv` |
| Output Feature Map | `output_mem.sv` |
 
No unnecessary copies of data shall be created.
 
---
 
<a id="part-3-s10"></a>
# 11. Design Principles
 
The architecture follows the following principles throughout development.
 
1. One module, one responsibility.
2. Streaming over batch processing.
3. Parameterize hardware structure.
4. Configure execution at runtime.
5. Minimize BRAM utilization.
6. Minimize DSP utilization while maintaining acceptable throughput.
7. Keep module interfaces simple and well-defined.
8. Prevent architectural coupling between independent modules.
These principles shall guide all future RTL modifications.
 
---
 
<a id="part-4"></a>
# Part 4 / 18
# Global Accelerator Operation
 
## 1. Introduction
 
This chapter defines the complete execution sequence of the accelerator.
 
Unlike the previous chapter, which introduced the hardware modules, this chapter describes **how those modules cooperate** to process one image.
 
The execution flow presented here shall be considered the official reference for implementing `global_ctrl.sv` and for coordinating every RTL module.
 
---
 
<a id="part-4-s1"></a>
# 2. Accelerator Life Cycle
 
One accelerator execution consists of four phases.
 
```text
IDLE
   │
   ▼
CONFIGURATION
   │
   ▼
PROCESSING
   │
   ▼
COMPLETION
   │
   ▼
IDLE
```
 
The accelerator always returns to the **IDLE** state after finishing one image.
 
---
 
<a id="part-4-s2"></a>
# 3. Phase 1 — Configuration
 
Before asserting the `START` signal, software (or the testbench) configures the accelerator.
 
Typical configuration sequence:
 
1. Write `IMG_WIDTH`
2. Write `IMG_HEIGHT`
3. Write ReLU configuration
4. Write Output Formatter configuration
5. Load all kernel coefficients
6. Assert `START`
During this phase:
 
- No image processing occurs.
- No module other than `cfg.sv` and `kernel_mem.sv` is active.
---
 
<a id="part-4-s3"></a>
# 4. Phase 2 — Processing
 
After `START` is asserted, the Global Controller begins normal accelerator operation.
 
The processing sequence is:
 
```text
Receive Pixels
        │
        ▼
Generate Sliding Windows
        │
        ▼
Multiply Pixels × Kernel
        │
        ▼
Accumulate Products
        │
        ▼
Apply ReLU (Optional)
        │
        ▼
Format Output
        │
        ▼
Store Output Pixel
```
 
This sequence repeats until the complete output feature map has been generated.
 
---
 
<a id="part-4-s4"></a>
# 5. Phase 3 — Completion
 
When the final output pixel has been generated:
 
- Output Controller finishes writing the output.
- Output Controller asserts `DONE`.
- Global Controller returns to the IDLE state.
The accelerator is then ready to receive a new `START` command.
 
---
 
<a id="part-4-s5"></a>
# 6. Global FSM
 
The Global Controller shall implement the following finite state machine.
 
```text
           +-------+
           | IDLE  |
           +-------+
               |
           START=1
               |
               ▼
       +---------------+
       | PROCESSING    |
       +---------------+
               |
          done = 1
               |
               ▼
          +---------+
          |  DONE   |
          +---------+
               |
               ▼
           +-------+
           | IDLE  |
           +-------+
```
 
Only three states are required.
 
---
 
<a id="part-4-s6"></a>
# 7. State Descriptions
 
## IDLE
 
### Purpose
 
Wait for a new accelerator execution request.
 
### Entry Conditions
 
- Reset
- Previous execution finished
### Active Modules
 
- cfg.sv
- kernel_mem.sv
All datapath modules remain idle.
 
### Exit Condition
 
```text
START == 1
```
 
---
 
## PROCESSING
 
### Purpose
 
Execute convolution over the complete image.
 
### Active Modules
 
- input_if
- input_ctrl
- sliding_window
- MAC_array
- accumulator
- relu
- output_formatter
- output_ctrl
- output_mem
### Exit Condition
 
```text
DONE == 1
```
 
generated by the Output Controller.
 
---
 
## DONE
 
### Purpose
 
Finalize execution and safely return to the IDLE state.
 
This state exists primarily to simplify control logic and provide a clean termination point.
 
No datapath computation occurs in this state.
 
---
 
<a id="part-4-s7"></a>
# 8. Module Activation Timeline
 
The following table indicates when each module becomes active.
 
| Module | IDLE | PROCESSING | DONE |
|---------|------|------------|------|
| cfg | ✓ | Read Only | Read Only |
| global_ctrl | ✓ | ✓ | ✓ |
| input_if | | ✓ | |
| input_ctrl | | ✓ | |
| kernel_mem | ✓ | Read Only | ✓ |
| sliding_window | | ✓ | |
| MAC_array | | ✓ | |
| accumulator | | ✓ | |
| relu | | ✓ | |
| output_formatter | | ✓ | |
| output_ctrl | | ✓ | |
| output_mem | | ✓ | |
 
---
 
<a id="part-4-s8"></a>
# 9. Startup Latency
 
The accelerator cannot produce an output immediately after `START`.
 
The first valid convolution window requires:
 
- buffering the required image rows
- constructing the first N×N window
Therefore:
 
```text
START
 
↓
 
Receive Pixels
 
↓
 
Generate First Valid Window
 
↓
 
First MAC Operation
 
↓
 
First Output Pixel
```
 
The startup latency depends on:
 
- image width
- kernel size
and is therefore **not constant**.
 
---
 
<a id="part-4-s9"></a>
# 10. Steady-State Operation
 
Once the first valid window has been generated, the accelerator enters steady-state operation.
 
For every valid sliding window:
 
```text
Window
 
↓
 
MAC
 
↓
 
Accumulator
 
↓
 
ReLU
 
↓
 
Formatter
 
↓
 
Output
```
 
The datapath remains continuously active until the final output pixel is produced.
 
---
 
<a id="part-4-s10"></a>
# 11. Accelerator Restart
 
After reaching the DONE state:
 
- Internal status flags are cleared.
- The Global Controller returns to IDLE.
- Configuration registers remain unchanged.
- Kernel Memory remains unchanged.
A second execution may begin immediately by asserting `START` again.
 
The kernel only needs to be reloaded if different coefficients are desired.
 
---
 
<a id="part-4-s11"></a>
# 12. Responsibilities of the Global Controller
 
The Global Controller is responsible for:
 
- Monitoring the `START` signal.
- Starting accelerator execution.
- Enabling processing.
- Monitoring completion.
- Returning the accelerator to IDLE.
The Global Controller shall **not**:
 
- Read image pixels.
- Generate sliding windows.
- Perform arithmetic.
- Access output memory directly.
- Modify kernel coefficients.
Its responsibility is **coordination**, not computation.
 
---
 
<a id="part-4-s12"></a>
# 13. Design Notes
 
To keep the architecture modular:
 
- Every datapath module performs only its local task.
- The Global Controller never manipulates pixel data.
- Every module communicates using clearly defined control and data signals.
- Future architectural extensions should preserve this separation between control path and datapath.
---
 
<a id="part-5"></a>
# Part 5 / 18
# Module Specification — cfg.sv
 
## 1. Module Overview
 
### Purpose
 
The Configuration Register File (`cfg.sv`) stores all runtime-programmable parameters required by the accelerator.
 
These parameters are written before accelerator execution begins and remain constant during processing.
 
The Configuration Register File is the only RTL module responsible for storing user configuration.
 
---
 
## 2. Position in the Architecture
 
```text
             Software / Testbench
                     │
                     ▼
               +------------+
               |  cfg.sv    |
               +------------+
                     │
      ----------------------------------------
      │         │          │          │
      ▼         ▼          ▼          ▼
global_ctrl kernel_mem output_fmt input_ctrl
```
 
The Configuration Register File belongs to the **Configuration Path**.
 
It is **not** part of the datapath.
 
---
 
## 3. Responsibilities
 
The module shall:
 
- Store runtime configuration.
- Provide stable configuration values to other RTL modules.
- Hold configuration constant throughout one execution.
- Reset all configuration registers to predefined values.
---
 
## 4. Non-Responsibilities
 
The module shall **NOT**:
 
- Perform image processing.
- Generate addresses.
- Store image pixels.
- Store output pixels.
- Control accelerator execution.
- Generate windows.
- Perform arithmetic.
---
 
<a id="part-5-s1"></a>
# 5. Configuration Registers
 
The accelerator currently defines the following runtime registers.
 
| Register | Width | Reset | Description |
|----------|------:|------:|-------------|
| img_width | 16 | 32 | Input image width |
| img_height | 16 | 32 | Input image height |
| relu_en | 1 | 0 | Enable ReLU block |
| shift_amt | 5 | 0 | Right shift amount |
| round_en | 1 | 0 | Enable rounding |
 
---
 
## Register Descriptions
 
### img_width
 
Specifies the number of pixels in each image row.
 
Requirements:
 
- Must be written before START.
- Shall remain unchanged while processing.
Minimum supported value:
 
```text
32
```
 
---
 
### img_height
 
Specifies the number of image rows.
 
Requirements:
 
- Must be written before START.
- Shall remain unchanged while processing.
Minimum supported value:
 
```text
32
```
 
---
 
### relu_en
 
Controls the ReLU block.
 
```text
0 → ReLU Disabled
 
1 → ReLU Enabled
```
 
When disabled,
 
```text
Output = Accumulator Result
```
 
When enabled,
 
```text
Output = max(0, Accumulator Result)
```
 
---
 
### shift_amt
 
Controls output scaling.
 
The Output Formatter performs
 
```text
Output = Input >>> shift_amt
```
 
before saturation.
 
The value is interpreted as
 
```text
Division by 2^shift_amt
```
 
Examples
 
| shift_amt | Division |
|-----------|----------|
| 0 | ×1 |
| 1 | ÷2 |
| 2 | ÷4 |
| 3 | ÷8 |
| 4 | ÷16 |
 
---
 
### round_en
 
Controls optional rounding.
 
```text
0 → Truncation
 
1 → Round-to-nearest
```
 
This register is only used when
 
```text
shift_amt > 0
```
 
---
 
<a id="part-5-s2"></a>
# 6. Future Expansion
 
The following registers are intentionally reserved for future versions.
 
| Register | Purpose |
|----------|----------|
| reserved_0 | Future use |
| reserved_1 | Future use |
| reserved_2 | Future use |
 
These registers shall not affect accelerator behavior.
 
---
 
<a id="part-5-s3"></a>
# 7. Module Interface
 
## Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
 
The write interface will be defined by the system integration layer.
 
For the first project version, the Testbench directly assigns register values.
 
Future versions may replace this with:
 
- AXI-Lite
- APB
- Avalon
- Wishbone
- Memory-mapped CPU interface
without modifying downstream RTL modules.
 
---
 
## Outputs
 
| Signal | Width | Destination |
|---------|------:|-------------|
| img_width | 16 | input_ctrl |
| img_height | 16 | input_ctrl |
| relu_en | 1 | relu |
| shift_amt | 5 | output_formatter |
| round_en | 1 | output_formatter |
 
---
 
<a id="part-5-s4"></a>
# 8. Reset Behavior
 
On reset,
 
```text
img_width  = 32
img_height = 32
 
relu_en    = 0
 
shift_amt  = 0
 
round_en   = 0
```
 
These values represent a valid default accelerator configuration.
 
---
 
<a id="part-5-s5"></a>
# 9. Timing
 
Configuration registers are sampled before START.
 
During accelerator execution:
 
```text
Configuration Registers
 
↓
 
Remain Constant
 
↓
 
Read by Other Modules
```
 
No configuration update is permitted while the accelerator is processing.
 
---
 
<a id="part-5-s6"></a>
# 10. Interaction with Global Controller
 
### IDLE
 
Configuration registers may be modified.
 
---
 
### PROCESSING
 
Configuration registers become read-only.
 
Their values must remain constant.
 
---
 
### DONE
 
Configuration registers may be modified again for the next execution.
 
---
 
<a id="part-5-s7"></a>
# 11. Design Rules
 
The following rules shall always be respected.
 
### Rule 1
 
No RTL module shall modify configuration registers.
 
Only software or the Testbench may write them.
 
---
 
### Rule 2
 
Every RTL module shall treat configuration outputs as read-only.
 
---
 
### Rule 3
 
Configuration registers shall never contain temporary processing data.
 
---
 
### Rule 4
 
Configuration registers shall not implement accelerator control logic.
 
---
 
<a id="part-5-s8"></a>
# 12. Verification Checklist
 
The following behaviors shall be verified.
 
□ Reset values are correct.
 
□ Registers retain written values.
 
□ ReLU enable propagates correctly.
 
□ Shift amount reaches Output Formatter.
 
□ Rounding enable reaches Output Formatter.
 
□ Image dimensions propagate correctly.
 
□ Configuration remains constant during processing.
 
□ Reset restores default values.
 
---
 
<a id="part-5-s9"></a>
# 13. RTL Notes
 
Recommended implementation style:
 
- Synchronous register bank.
- One always_ff block.
- Non-blocking assignments.
- No combinational logic except direct output assignments.
The module should remain simple and purely sequential.
 
---
 
<a id="part-6"></a>
# Part 6 / 18
# Top-Level Module Specification — dut_top.sv
 
## 1. Module Overview
 
### Purpose
 
The Top-Level module integrates all RTL modules of the accelerator.
 
It is the only module visible to the external world.
 
The Top-Level shall:
 
- Instantiate every RTL module.
- Connect all datapath signals.
- Connect all control signals.
- Connect configuration signals.
- Expose the accelerator interface.
The Top-Level shall contain **no processing logic**.
 
It is purely an integration module.
 
---
 
<a id="part-6-s1"></a>
# 2. Top-Level Architecture
 
```
                    +----------------------+
                    |      dut_top         |
                    |                      |
                    |   Configuration      |
                    |   Control Path       |
                    |   Data Path          |
                    |                      |
                    +----------------------+
```
 
---
 
<a id="part-6-s2"></a>
# 3. Internal Module Hierarchy
 
```
dut_top
│
├── cfg
├── global_ctrl
├── input_if
├── input_ctrl
├── kernel_mem
├── sliding_window
├── MAC_array
│   └── processing_element[N]
├── accumulator
├── relu
├── output_formatter
├── output_ctrl
└── output_mem
```
 
Only `processing_element.sv` is instantiated multiple times.
 
All other modules shall have exactly one instance.
 
---
 
<a id="part-6-s3"></a>
# 4. External Interface
 
## Clock & Reset
 
| Signal | Direction | Width | Description |
|----------|-----------|------:|-------------|
| clk | Input | 1 | System clock |
| rst_n | Input | 1 | Active-low synchronous reset |
 
---
 
## Control Interface
 
| Signal | Direction | Width | Description |
|----------|-----------|------:|-------------|
| start | Input | 1 | Starts one accelerator execution |
| done | Output | 1 | Asserted after finishing one output feature map |
| busy | Output | 1 | Accelerator currently processing |
 
---
 
## Configuration Interface
 
The first project version does **not** implement a processor bus.
 
Configuration values are provided directly by the Testbench.
 
| Signal | Direction | Width |
|----------|-----------|------:|
| cfg_img_width | Input | 16 |
| cfg_img_height | Input | 16 |
| cfg_relu_en | Input | 1 |
| cfg_shift_amt | Input | 5 |
| cfg_round_en | Input | 1 |
 
These signals are internally connected to `cfg.sv`.
 
Future versions may replace them with:
 
- AXI-Lite
- APB
- Wishbone
- Avalon
without changing the accelerator datapath.
 
---
 
## Kernel Loading Interface
 
Kernel coefficients are loaded before processing begins.
 
| Signal | Direction | Width | Description |
|----------|-----------|------:|-------------|
| kernel_we | Input | 1 | Write Enable |
| kernel_addr | Input | ceil(log₂(N²)) | Kernel coefficient address |
| kernel_data | Input | 8 | Signed kernel coefficient |
 
---
 
## Input Image Interface
 
Pixels are streamed into the accelerator.
 
| Signal | Direction | Width | Description |
|----------|-----------|------:|-------------|
| pixel_in | Input | 8 | Unsigned grayscale pixel |
| pixel_valid | Input | 1 | Input pixel is valid |
 
Future versions may replace this interface with:
 
- DMA
- DDR Controller
- Camera Interface
without modifying the datapath.
 
---
 
## Output Interface
 
| Signal | Direction | Width | Description |
|----------|-----------|------:|-------------|
| pixel_out | Output | 16 | Final output pixel |
| pixel_out_valid | Output | 1 | Output pixel valid |
 
---
 
<a id="part-6-s4"></a>
# 5. Internal Connectivity
 
The following table summarizes the major module connections.
 
| Source | Destination | Data |
|----------|-------------|------|
| cfg | global_ctrl | Configuration |
| cfg | output_formatter | Shift / Rounding |
| cfg | relu | Enable |
| input_if | input_ctrl | Input Pixels |
| input_ctrl | sliding_window | Pixel Stream |
| sliding_window | MAC_array | N×N Window |
| kernel_mem | MAC_array | Kernel Coefficients |
| MAC_array | accumulator | Partial Sum |
| accumulator | relu | Convolution Result |
| relu | output_formatter | Activated Result |
| output_formatter | output_ctrl | Output Pixel |
| output_ctrl | output_mem | Output Feature Map |
 
---
 
<a id="part-6-s5"></a>
# 6. Top-Level Responsibilities
 
The Top-Level shall:
 
- Instantiate all modules.
- Connect all modules.
- Forward external inputs.
- Forward external outputs.
---
 
<a id="part-6-s6"></a>
# 7. Non-Responsibilities
 
The Top-Level shall NOT:
 
- Perform multiplication.
- Perform accumulation.
- Generate windows.
- Store kernel coefficients.
- Store pixels.
- Implement an FSM.
- Implement combinational datapath logic.
If a behavioral statement longer than a simple signal assignment appears inside `dut_top.sv`, it should be questioned during code review.
 
---
 
<a id="part-6-s7"></a>
# 8. Design Rules
 
## Rule 1
 
Every datapath connection shall be point-to-point.
 
No module shall read another module's internal signals.
 
---
 
## Rule 2
 
No module shall instantiate another module except:
 
```
MAC_array
    └── processing_element
```
 
---
 
## Rule 3
 
All communication shall occur through explicit ports.
 
Hidden dependencies are prohibited.
 
---
 
## Rule 4
 
Every signal crossing module boundaries shall have exactly one driver.
 
---
 
<a id="part-6-s8"></a>
# 9. Verification Checklist
 
The following shall be verified during integration.
 
□ All modules are instantiated.
 
□ Every configuration signal reaches its destination.
 
□ Input stream reaches Sliding Window.
 
□ Kernel reaches MAC Array.
 
□ Convolution result reaches ReLU.
 
□ Formatter reaches Output Controller.
 
□ Output Controller reaches Output Memory.
 
□ START propagates correctly.
 
□ DONE propagates correctly.
 
□ BUSY behaves correctly.
 
---
 
<a id="part-6-s9"></a>
# 10. RTL Notes
 
`dut_top.sv` should be the simplest RTL file in the project.
 
A reader should understand the complete architecture simply by opening this file.
 
Its primary purpose is readability and integration.
 
---
 
<a id="part-7"></a>
# Part 7 / 18
# Module Specification — global_ctrl.sv
 
## 1. Module Overview
 
### Purpose
 
The Global Controller is the central control unit of the accelerator.
 
It coordinates the complete execution flow by monitoring the accelerator status and enabling the appropriate processing stages.
 
Unlike datapath modules, the Global Controller never manipulates image data. Its responsibility is limited to **control and synchronization**.
 
---
 
<a id="part-7-s1"></a>
# 2. Position in the Architecture
 
```
                    START
                      │
                      ▼
              +----------------+
              | global_ctrl.sv |
              +----------------+
                │     │      │
                │     │      │
                ▼     ▼      ▼
         input_ctrl  ... output_ctrl
```
 
The Global Controller belongs to the **Control Path**.
 
---
 
<a id="part-7-s2"></a>
# 3. Responsibilities
 
The Global Controller shall:
 
- Wait for a START command.
- Start accelerator execution.
- Keep the accelerator in the processing state.
- Monitor processing completion.
- Return the accelerator to the IDLE state.
- Generate the global BUSY signal.
- Generate enable signals for downstream modules.
---
 
<a id="part-7-s3"></a>
# 4. Non-Responsibilities
 
The Global Controller shall NOT:
 
- Receive image pixels.
- Generate memory addresses.
- Read kernel coefficients.
- Generate sliding windows.
- Perform arithmetic.
- Store input or output data.
- Apply ReLU.
- Perform output formatting.
---
 
<a id="part-7-s4"></a>
# 5. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
| start | 1 | Starts accelerator execution |
| output_done | 1 | Asserted by output_ctrl after generating the last output pixel |
 
---
 
<a id="part-7-s5"></a>
# 6. Outputs
 
| Signal | Width | Destination | Description |
|---------|------:|-------------|-------------|
| busy | 1 | Top-Level | Accelerator busy flag |
| done | 1 | Top-Level | Execution completed |
| processing_en | 1 | Datapath | Enables processing |
 
> **Design Decision**
>
> Instead of generating many enable signals (`input_en`, `mac_en`, `acc_en`, ...), the first implementation exports a single `processing_en`.
>
> Every processing module may use this signal together with its own local valid signals.
>
> This greatly simplifies the control path.
 
---
 
<a id="part-7-s6"></a>
# 7. FSM
 
The Global Controller implements three states.
 
```
                +---------+
                |  IDLE   |
                +---------+
                     |
               start = 1
                     |
                     ▼
              +--------------+
              | PROCESSING   |
              +--------------+
                     |
          output_done = 1
                     |
                     ▼
                +---------+
                |  DONE   |
                +---------+
                     |
                     ▼
                +---------+
                |  IDLE   |
                +---------+
```
 
---
 
<a id="part-7-s7"></a>
# 8. State Description
 
## IDLE
 
### Purpose
 
Wait for a START command.
 
### Outputs
 
```
busy = 0
 
done = 0
 
processing_en = 0
```
 
### Transition
 
```
START = 1
 
↓
 
PROCESSING
```
 
---
 
## PROCESSING
 
### Purpose
 
Accelerator is actively computing.
 
### Outputs
 
```
busy = 1
 
done = 0
 
processing_en = 1
```
 
### Transition
 
```
output_done = 1
 
↓
 
DONE
```
 
---
 
## DONE
 
### Purpose
 
Generate a completion pulse.
 
### Outputs
 
```
busy = 0
 
done = 1
 
processing_en = 0
```
 
The DONE state lasts exactly **one clock cycle**.
 
Afterward:
 
```
↓
 
IDLE
```
 
---
 
<a id="part-7-s8"></a>
# 9. Timing Diagram
 
```
clk
 
┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐
┘ └─┘ └─┘ └─┘ └─┘ └─
 
start
____████_________________
 
busy
______████████████________
 
done
___________________█______
 
```
 
---
 
<a id="part-7-s9"></a>
# 10. State Transition Table
 
| Current State | Condition | Next State |
|---------------|-----------|------------|
| IDLE | start = 0 | IDLE |
| IDLE | start = 1 | PROCESSING |
| PROCESSING | output_done = 0 | PROCESSING |
| PROCESSING | output_done = 1 | DONE |
| DONE | Always | IDLE |
 
---
 
<a id="part-7-s10"></a>
# 11. Reset Behavior
 
After reset:
 
```
State = IDLE
 
busy = 0
 
done = 0
 
processing_en = 0
```
 
No processing shall begin automatically after reset.
 
---
 
<a id="part-7-s11"></a>
# 12. Interaction with Other Modules
 
| Module | Interaction |
|----------|------------|
| cfg | Reads configuration indirectly (through system integration) |
| input_ctrl | Enabled by `processing_en` |
| sliding_window | Enabled by `processing_en` |
| MAC_array | Enabled by `processing_en` |
| accumulator | Enabled by `processing_en` |
| relu | Enabled by `processing_en` |
| output_formatter | Enabled by `processing_en` |
| output_ctrl | Generates `output_done` |
 
---
 
<a id="part-7-s12"></a>
# 13. Corner Cases
 
## START asserted while BUSY
 
Behavior:
 
Ignore.
 
The accelerator shall finish the current execution before accepting another START command.
 
---
 
## START held high for multiple cycles
 
Behavior:
 
Only the first rising edge shall initiate execution.
 
Subsequent high cycles shall have no effect.
 
---
 
## Reset during PROCESSING
 
Behavior:
 
Immediately terminate execution.
 
Return to IDLE.
 
Discard any partially processed image.
 
---
 
<a id="part-7-s13"></a>
# 14. Verification Checklist
 
□ Reset enters IDLE.
 
□ START transitions to PROCESSING.
 
□ BUSY asserted only during PROCESSING.
 
□ DONE asserted for exactly one clock cycle.
 
□ DONE returns to IDLE.
 
□ START ignored while BUSY.
 
□ Reset interrupts PROCESSING correctly.
 
□ FSM never enters an illegal state.
 
---
 
<a id="part-7-s14"></a>
# 15. RTL Implementation Notes
 
Recommended implementation:
 
- Enumerated FSM using `typedef enum logic`.
- One `always_ff` block for state register.
- One `always_comb` block for next-state logic.
- One `always_comb` block for output logic (Moore FSM).
Example:
 
```systemverilog
typedef enum logic [1:0] {
    IDLE,
    PROCESSING,
    DONE
} state_t;
```
 
This structure improves readability, synthesis quality, and verification.
 
---
 
<a id="part-7-s15"></a>
# 16. Future Extensions
 
The current FSM is intentionally minimal.
 
Future versions may extend it with additional states such as:
 
- LOAD_KERNEL
- WAIT_FOR_INPUT
- FLUSH_PIPELINE
- ERROR
These states are not required for Version 1.0 of the accelerator.
 
---
 
<a id="part-8"></a>
# Part 8 / 18
# Module Specification — input_if.sv
 
## 1. Module Overview
 
### Purpose
 
The Input Interface (`input_if.sv`) is responsible for interfacing the accelerator with the external image source.
 
It receives incoming pixels from the external world and presents them to the accelerator using the internal streaming protocol.
 
The Input Interface isolates the accelerator from the communication protocol used by the image source.
 
Consequently, replacing the image source shall only require modifications to `input_if.sv`, while the remaining accelerator remains unchanged.
 
---
 
<a id="part-8-s1"></a>
# 2. Position in the Architecture
 
```
            External Image Source
                     │
                     ▼
              +---------------+
              |   input_if    |
              +---------------+
                     │
      pixel + valid  │
                     ▼
              +---------------+
              | input_ctrl    |
              +---------------+
```
 
The Input Interface is the boundary between the external environment and the accelerator.
 
---
 
<a id="part-8-s2"></a>
# 3. Responsibilities
 
The Input Interface shall:
 
- Receive external image pixels.
- Verify that incoming pixels are valid.
- Forward pixels to the Input Controller.
- Convert the external protocol into the accelerator's internal protocol.
---
 
<a id="part-8-s3"></a>
# 4. Non-Responsibilities
 
The Input Interface shall NOT:
 
- Count image rows.
- Count image columns.
- Store pixels.
- Generate addresses.
- Generate sliding windows.
- Perform convolution.
- Control accelerator execution.
---
 
<a id="part-8-s4"></a>
# 5. Internal Streaming Protocol
 
All datapath modules shall communicate using the following protocol.
 
| Signal | Description |
|----------|-------------|
| data | Contains one data item |
| valid | Indicates that `data` is valid during the current clock cycle |
 
There is no READY signal.
 
If `valid == 0`, the receiver ignores `data`.
 
---
 
<a id="part-8-s5"></a>
# 6. Inputs
 
## Clock & Reset
 
| Signal | Width | Description |
|----------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
 
---
 
## External Interface
 
| Signal | Width | Description |
|----------|------:|-------------|
| pixel_in | 8 | Incoming grayscale pixel |
| pixel_valid | 1 | Incoming pixel is valid |
 
---
 
## Control
 
| Signal | Width | Description |
|----------|------:|-------------|
| processing_en | 1 | Accelerator currently processing |
 
---
 
<a id="part-8-s6"></a>
# 7. Outputs
 
| Signal | Width | Destination |
|----------|------:|-------------|
| pixel_out | 8 | input_ctrl |
| pixel_out_valid | 1 | input_ctrl |
 
---
 
<a id="part-8-s7"></a>
# 8. Functional Description
 
When
 
```
processing_en == 1
```
 
and
 
```
pixel_valid == 1
```
 
the module forwards the incoming pixel.
 
```
pixel_out       = pixel_in
 
pixel_out_valid = 1
```
 
Otherwise,
 
```
pixel_out_valid = 0
```
 
No additional processing is performed.
 
---
 
<a id="part-8-s8"></a>
# 9. Timing
 
```
External Source
 
pixel_valid
 
↓
 
input_if
 
↓
 
pixel_out_valid
 
↓
 
input_ctrl
```
 
The module introduces **zero additional latency**.
 
It behaves as a simple streaming interface.
 
---
 
<a id="part-8-s9"></a>
# 10. Reset Behavior
 
During reset:
 
```
pixel_out_valid = 0
```
 
The pixel output is don't-care while valid is low.
 
---
 
<a id="part-8-s10"></a>
# 11. Design Rules
 
## Rule 1
 
The Input Interface shall never buffer pixels.
 
---
 
## Rule 2
 
The Input Interface shall never modify pixel values.
 
Incoming pixels shall be forwarded unchanged.
 
---
 
## Rule 3
 
The Input Interface shall remain protocol-independent.
 
Future interfaces (DMA, Camera, DDR, AXI Stream, etc.) shall only require modifications to this module.
 
---
 
<a id="part-8-s11"></a>
# 12. Future Extensions
 
The following features may be added in future versions.
 
- AXI-Stream slave interface
- Camera receiver
- DDR controller
- DMA engine
- FIFO buffering
- Clock-domain crossing
These features are intentionally excluded from Version 1.0.
 
---
 
<a id="part-8-s12"></a>
# 13. Verification Checklist
 
□ Valid pixel forwarded correctly.
 
□ Invalid pixel not forwarded.
 
□ Pixel value unchanged.
 
□ Reset clears output valid.
 
□ No output while processing is disabled.
 
□ Continuous streaming supported.
 
---
 
<a id="part-8-s13"></a>
# 14. RTL Implementation Notes
 
Recommended implementation:
 
- One `always_ff` block (if registering outputs), or
- Continuous assignments (if purely combinational).
The implementation shall remain lightweight.
 
The module should not exceed a few lines of RTL.
 
---
 
<a id="part-8-s14"></a>
# 15. Design Philosophy
 
The Input Interface exists to decouple the accelerator from external communication protocols.
 
This allows the internal datapath to remain stable even if the external image source changes in future revisions.
 
.---
 
<a id="part-9"></a>
# Part 9 / 18
# Module Specification — input_ctrl.sv
 
## 1. Module Overview
 
### Purpose
 
The Input Controller (`input_ctrl.sv`) controls the flow of incoming image pixels into the accelerator datapath.
 
It tracks the current pixel location within the image and forwards valid pixels to the Sliding Window module.
 
Unlike the Input Interface, which only converts communication protocols, the Input Controller understands the image structure.
 
It is therefore responsible for maintaining the current row and column indices.
 
---
 
<a id="part-9-s1"></a>
# 2. Position in the Architecture
 
```
                 pixel + valid
                      │
                      ▼
               +---------------+
               |   input_if    |
               +---------------+
                      │
                      ▼
               +---------------+
               |  input_ctrl   |
               +---------------+
                      │
          pixel + valid + position
                      │
                      ▼
               +------------------+
               | sliding_window   |
               +------------------+
```
 
---
 
<a id="part-9-s2"></a>
# 3. Responsibilities
 
The Input Controller shall:
 
- Accept pixels from `input_if`.
- Track the current image position.
- Count image rows.
- Count image columns.
- Forward pixels to the Sliding Window subsystem.
- Detect the last pixel of the image.
---
 
<a id="part-9-s3"></a>
# 4. Non-Responsibilities
 
The Input Controller shall NOT:
 
- Store image rows.
- Generate sliding windows.
- Store the complete image.
- Perform convolution.
- Apply ReLU.
- Format output pixels.
- Control accelerator execution.
---
 
<a id="part-9-s4"></a>
# 5. Inputs
 
## Clock & Reset
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
 
---
 
## Configuration
 
| Signal | Width | Description |
|---------|------:|-------------|
| img_width | 16 | Image width |
| img_height | 16 | Image height |
 
---
 
## Control
 
| Signal | Width | Description |
|---------|------:|-------------|
| processing_en | 1 | Accelerator currently processing |
 
---
 
## Pixel Stream
 
| Signal | Width | Description |
|---------|------:|-------------|
| pixel_in | 8 | Input pixel |
| pixel_valid | 1 | Input pixel valid |
 
---
 
<a id="part-9-s5"></a>
# 6. Outputs
 
| Signal | Width | Destination | Description |
|---------|------:|-------------|-------------|
| pixel_out | 8 | sliding_window | Forwarded pixel |
| pixel_out_valid | 1 | sliding_window | Pixel valid |
| row_idx | 16 | sliding_window | Current image row |
| col_idx | 16 | sliding_window | Current image column |
| image_done | 1 | global_ctrl (future use) | Last input pixel received |
 
---
 
<a id="part-9-s6"></a>
# 7. Internal Registers
 
| Register | Width | Description |
|----------|------:|-------------|
| row_cnt | 16 | Current row |
| col_cnt | 16 | Current column |
 
---
 
<a id="part-9-s7"></a>
# 8. Functional Description
 
Whenever
 
```
processing_en == 1
```
 
and
 
```
pixel_valid == 1
```
 
the Input Controller shall:
 
1. Forward the incoming pixel.
2. Assert `pixel_out_valid`.
3. Update the row/column counters.
---
 
## Column Counter
 
The column counter increments after every valid pixel.
 
```
col_cnt++
 
```
 
When
 
```
col_cnt == img_width - 1
```
 
the controller shall
 
```
col_cnt = 0
row_cnt++
```
 
---
 
## Row Counter
 
The row counter increments after every completed row.
 
When
 
```
row_cnt == img_height - 1
```
 
and
 
```
col_cnt == img_width - 1
```
 
the final pixel of the image has been received.
 
The controller shall assert
 
```
image_done = 1
```
 
for one clock cycle.
 
---
 
<a id="part-9-s8"></a>
# 9. Timing
 
```
Incoming Pixel
 
↓
 
Forward Pixel
 
↓
 
Update Counters
```
 
The forwarded pixel and its corresponding `(row_idx, col_idx)` shall refer to the same image location.
 
---
 
<a id="part-9-s9"></a>
# 10. Reset Behavior
 
After reset:
 
```
row_cnt = 0
 
col_cnt = 0
 
pixel_out_valid = 0
 
image_done = 0
```
 
---
 
<a id="part-9-s10"></a>
# 11. Interaction with Other Modules
 
## Receives From
 
- input_if
- cfg
- global_ctrl
---
 
## Sends To
 
- sliding_window
- global_ctrl (optional status)
---
 
<a id="part-9-s11"></a>
# 12. Design Rules
 
## Rule 1
 
The Input Controller shall never buffer image rows.
 
---
 
## Rule 2
 
The Input Controller shall never modify pixel values.
 
---
 
## Rule 3
 
Image dimensions shall always be obtained from `cfg.sv`.
 
No dimensions shall be hardcoded.
 
---
 
## Rule 4
 
Counters shall advance **only** when a valid pixel is accepted.
 
Invalid cycles must not affect image position.
 
---
 
<a id="part-9-s12"></a>
# 13. Corner Cases
 
## Image Width = 32
 
Counters shall wrap correctly.
 
---
 
## Image Height = 32
 
The last pixel shall be detected correctly.
 
---
 
## Invalid Input Cycle
 
If
 
```
pixel_valid == 0
```
 
then
 
- counters remain unchanged.
- no output pixel is generated.
---
 
## Reset During Reception
 
Current image reception is aborted.
 
Counters return to zero.
 
The next valid image begins from `(0,0)`.
 
---
 
<a id="part-9-s13"></a>
# 14. Verification Checklist
 
□ Pixel forwarded correctly.
 
□ Row counter increments correctly.
 
□ Column counter increments correctly.
 
□ Column wraps correctly.
 
□ Row wraps correctly.
 
□ Last pixel detected.
 
□ Invalid cycles ignored.
 
□ Reset clears counters.
 
□ Image dimensions respected.
 
---
 
<a id="part-9-s14"></a>
# 15. RTL Implementation Notes
 
Recommended implementation:
 
- One sequential process for counters.
- Continuous assignment or simple combinational logic for forwarded signals.
- Counters shall only increment on valid pixels.
This module should remain lightweight and deterministic.
 
---
 
<a id="part-9-s15"></a>
# 16. Future Extensions
 
Future versions may add:
 
- Multi-channel support.
- ROI (Region of Interest) processing.
- Programmable scan order.
- Image cropping.
- Frame synchronization signals.
These features are intentionally excluded from Version 1.0.
 
---
 
<a id="part-10"></a>
# Part 10 / 18
# Module Specification — kernel_mem.sv
 
## 1. Module Overview
 
### Purpose
 
The Kernel Memory (`kernel_mem.sv`) stores the programmable convolution kernel coefficients.
 
The kernel is loaded before accelerator execution begins and remains constant throughout the complete convolution operation.
 
The Kernel Memory is read-only during processing.
 
---
 
<a id="part-10-s1"></a>
# 2. Position in the Architecture
 
```
             Software / Testbench
                     │
                     ▼
              +---------------+
              |  kernel_mem   |
              +---------------+
                     │
        N coefficients / cycle
                     │
                     ▼
              +---------------+
              |   MAC_array   |
              +---------------+
```
 
The Kernel Memory belongs to the **Configuration Path**.
 
---
 
<a id="part-10-s2"></a>
# 3. Responsibilities
 
The Kernel Memory shall:
 
- Store all kernel coefficients.
- Allow software/Testbench to program coefficients.
- Provide coefficients to the MAC Array.
- Hold coefficients constant during processing.
---
 
<a id="part-10-s3"></a>
# 4. Non-Responsibilities
 
The Kernel Memory shall NOT:
 
- Modify kernel coefficients.
- Perform multiplication.
- Generate addresses.
- Perform convolution.
- Apply activation functions.
- Format outputs.
- Control accelerator execution.
---
 
<a id="part-10-s4"></a>
# 5. Kernel Organization
 
The kernel is stored as a one-dimensional memory.
 
Example for N = 5
 
```
Address
 
0
1
2
3
4
5
...
24
```
 
The logical mapping is
 
```
Address = row × N + column
```
 
Example
 
```
5×5 Kernel
 
K00 K01 K02 K03 K04
K10 K11 K12 K13 K14
K20 K21 K22 K23 K24
K30 K31 K32 K33 K34
K40 K41 K42 K43 K44
```
 
becomes
 
```
0  → K00
1  → K01
2  → K02
...
24 → K44
```
 
---
 
<a id="part-10-s5"></a>
# 6. Parameters
 
| Parameter | Description |
|------------|-------------|
| N | Kernel dimension |
 
The memory depth is
 
```
N × N
```
 
---
 
<a id="part-10-s6"></a>
# 7. Inputs
 
## Clock & Reset
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
 
---
 
## Programming Interface
 
| Signal | Width | Description |
|---------|------:|-------------|
| kernel_we | 1 | Write enable |
| kernel_addr | ceil(log₂(N²)) | Write address |
| kernel_data | 8 | Signed coefficient |
 
---
 
## Read Interface
 
| Signal | Width | Description |
|---------|------:|-------------|
| processing_en | 1 | Accelerator processing |
 
---
 
<a id="part-10-s7"></a>
# 8. Outputs
 
| Signal | Width | Destination |
|---------|------:|-------------|
| kernel_coeff[N][N] | 8 each | MAC Array |
 
---
 
<a id="part-10-s8"></a>
# 9. Internal Memory
 
Recommended RTL implementation
 
```systemverilog
logic signed [7:0] mem [0:N*N-1];
```
 
---
 
<a id="part-10-s9"></a>
# 10. Functional Description
 
## Programming Phase
 
When
 
```
kernel_we == 1
```
 
the memory performs
 
```
mem[kernel_addr] <= kernel_data;
```
 
Programming is only allowed while the accelerator is idle.
 
---
 
## Processing Phase
 
During processing,
 
the Kernel Memory continuously provides all coefficients to the MAC Array.
 
The coefficients remain unchanged until a new kernel is programmed.
 
---
 
<a id="part-10-s10"></a>
# 11. Read Strategy
 
Since the kernel is relatively small,
 
the accelerator reads **all N² coefficients simultaneously**.
 
Conceptually,
 
```
Kernel Memory
 
↓
 
K00
 
K01
 
...
 
KNN
 
↓
 
MAC Array
```
 
This avoids repeated memory accesses and maximizes throughput.
 
---
 
<a id="part-10-s11"></a>
# 12. Reset Behavior
 
After reset,
 
kernel contents are undefined.
 
Software or the Testbench shall always program the kernel before asserting START.
 
The accelerator shall never assume a default kernel.
 
---
 
<a id="part-10-s12"></a>
# 13. Interaction with Other Modules
 
Receives from
 
- Testbench
- Software
Provides data to
 
- MAC_array
No other module shall access Kernel Memory directly.
 
---
 
<a id="part-10-s13"></a>
# 14. Design Rules
 
## Rule 1
 
Kernel coefficients shall never change during processing.
 
---
 
## Rule 2
 
Only software/Testbench may program the kernel.
 
---
 
## Rule 3
 
Kernel Memory shall never perform arithmetic.
 
---
 
## Rule 4
 
Kernel coefficients shall be stored as signed 8-bit integers.
 
---
 
<a id="part-10-s14"></a>
# 15. Corner Cases
 
## Programming while PROCESSING
 
Not supported.
 
Behavior is undefined.
 
Software shall not perform writes during processing.
 
---
 
## Invalid Address
 
Software shall only access valid addresses.
 
For
 
```
N = 5
```
 
valid addresses are
 
```
0 ... 24
```
 
---
 
<a id="part-10-s15"></a>
# 16. Verification Checklist
 
□ All coefficients programmed correctly.
 
□ Signed values stored correctly.
 
□ First coefficient read correctly.
 
□ Last coefficient read correctly.
 
□ Negative coefficients handled correctly.
 
□ Kernel remains constant during processing.
 
□ Reset behavior verified.
 
---
 
<a id="part-10-s16"></a>
# 17. RTL Notes
 
Recommended implementation:
 
- Register array.
- One sequential write process.
- Continuous read outputs.
Since the kernel is very small,
 
the synthesizer will likely implement it using distributed RAM or registers instead of BRAM.
 
This is acceptable and may even improve the Figure of Merit by avoiding unnecessary BRAM utilization.
 
---
 
<a id="part-10-s17"></a>
# 18. Design Rationale
 
The kernel contains only
 
```
N²
```
 
values.
 
For the competition target
 
```
N = 5
```
 
only
 
```
25 bytes
```
 
must be stored.
 
Using BRAM for such a small storage would waste FPGA resources.
 
Keeping the kernel in registers or distributed RAM improves resource efficiency while allowing all coefficients to be available to the MAC Array every clock cycle.
 
---
 
<a id="part-11"></a>
# Part 11 / 18
# Module Specification — sliding_window.sv
 
## 1. Module Overview
 
### Purpose
 
The Sliding Window module generates one valid **N × N** convolution window from the incoming pixel stream.
 
It combines two logical blocks:
 
- Line Buffers
- Window Generator
into a single RTL module.
 
Its primary objective is to maximize data reuse while minimizing external memory bandwidth.
 
---
 
<a id="part-11-s1"></a>
# 2. Position in the Architecture
 
```
                  pixel + valid
                       │
                       ▼
               +----------------+
               |   input_ctrl   |
               +----------------+
                       │
                       ▼
               +----------------+
               | sliding_window |
               +----------------+
                       │
              N×N Window + valid
                       │
                       ▼
                 +------------+
                 | MAC_array  |
                 +------------+
```
 
The Sliding Window module is the first computational stage of the datapath.
 
---
 
<a id="part-11-s2"></a>
# 3. Responsibilities
 
The Sliding Window module shall:
 
- Receive the input pixel stream.
- Store the previous **N−1** image rows.
- Shift pixels horizontally.
- Construct one valid **N × N** window.
- Assert `window_valid` only when a complete window is available.
---
 
<a id="part-11-s3"></a>
# 4. Non-Responsibilities
 
The Sliding Window module shall **NOT**:
 
- Count image dimensions.
- Perform multiplication.
- Perform accumulation.
- Store the complete image.
- Apply activation functions.
- Format output data.
- Control accelerator execution.
---
 
<a id="part-11-s4"></a>
# 5. Design Philosophy
 
Instead of reading the same pixels from memory multiple times, previously received pixels are reused.
 
This dramatically reduces external memory bandwidth.
 
Example for **N = 3**:
 
```
Image
 
A B C D E
F G H I J
K L M N O
```
 
To compute the first window:
 
```
A B C
F G H
K L M
```
 
the accelerator reads nine pixels.
 
To compute the next window:
 
```
B C D
G H I
L M N
```
 
only **three new pixels** are required.
 
The remaining six pixels are reused from the Sliding Window.
 
---
 
<a id="part-11-s5"></a>
# 6. Internal Architecture
 
The module consists of two logical stages.
 
```
Incoming Pixels
       │
       ▼
+------------------+
|   Line Buffers   |
+------------------+
       │
       ▼
+------------------+
| Window Generator |
+------------------+
       │
       ▼
N×N Window
```
 
---
 
<a id="part-11-s6"></a>
# 7. Line Buffers
 
The Line Buffers store the previous **N−1** rows.
 
Required storage:
 
```
(N − 1) × Image Width
```
 
Example
 
For
 
```
N = 5
 
Image Width = 32
```
 
storage becomes
 
```
4 × 32 = 128 pixels
```
 
---
 
<a id="part-11-s7"></a>
# 8. Window Generator
 
The Window Generator maintains an **N × N** sliding register matrix.
 
Every new input pixel causes:
 
1. Horizontal shift of the window.
2. Insertion of the newest pixel.
3. Update of all rows.
Conceptually,
 
```
Before
 
A B C
D E F
G H I
 
↓
 
New Pixel = J
 
↓
 
After
 
B C J
E F J
H I J
```
 
(The exact RTL implementation updates each row using the corresponding line buffer output.)
 
---
 
<a id="part-11-s8"></a>
# 9. Inputs
 
## Clock & Reset
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
 
---
 
## Pixel Stream
 
| Signal | Width | Description |
|---------|------:|-------------|
| pixel_in | 8 | Input pixel |
| pixel_valid | 1 | Pixel valid |
 
---
 
## Image Control
 
| Signal | Width | Description |
|---------|------:|-------------|
| end_of_row | 1 | Asserted on the last pixel of each row |
| end_of_frame | 1 | Asserted on the last pixel of the image |
 
---
 
<a id="part-11-s9"></a>
# 10. Outputs
 
| Signal | Width | Destination |
|---------|------:|-------------|
| window[N*N] | 8 each | MAC_array |
| window_valid | 1 | MAC_array |
 
> **Implementation Note**
>
> The window shall be exported as a **flat array**:
>
> ```systemverilog
> logic [7:0] window [0:N*N-1];
> ```
>
> This matches the flattened kernel interface and simplifies PE indexing.
 
---
 
<a id="part-11-s10"></a>
# 11. Internal Storage
 
Recommended implementation
 
```
Line Buffers
 
logic [7:0] line_buffer [0:N-2][0:IMG_WIDTH-1]
```
 
Window registers
 
```
logic [7:0] window_reg [0:N*N-1]
```
 
The exact RTL organization may differ provided the external behavior remains unchanged.
 
---
 
<a id="part-11-s11"></a>
# 12. Startup Behavior
 
Immediately after START,
 
a valid convolution window does **not** exist.
 
The module must first receive sufficient pixels to fill:
 
- all line buffers
- the complete window registers
Only then shall
 
```
window_valid = 1
```
 
be asserted.
 
---
 
<a id="part-11-s12"></a>
# 13. Steady-State Operation
 
After startup,
 
every accepted input pixel advances the window by one column.
 
The module shall produce:
 
```
One Input Pixel
 
↓
 
One Updated Window
```
 
once the pipeline has been filled.
 
---
 
<a id="part-11-s13"></a>
# 14. Reset Behavior
 
After reset:
 
- All line buffers are cleared.
- Window registers are cleared.
- `window_valid = 0`.
The next image begins from an empty state.
 
---
 
<a id="part-11-s14"></a>
# 15. Interaction with Other Modules
 
Receives from:
 
- input_ctrl
Provides data to:
 
- MAC_array
No other module shall directly access the internal line buffers.
 
---
 
<a id="part-11-s15"></a>
# 16. Design Rules
 
## Rule 1
 
Only the previous **N−1** rows may be stored.
 
The complete image shall never be buffered.
 
---
 
## Rule 2
 
Pixels shall never be fetched twice from the external source.
 
---
 
## Rule 3
 
The window shall advance by exactly one column for each accepted input pixel.
 
---
 
## Rule 4
 
`window_valid` shall only be asserted when every element of the window contains valid image data.
 
---
 
<a id="part-11-s16"></a>
# 17. Corner Cases
 
### Startup
 
`window_valid` shall remain low until the first complete window is assembled.
 
---
 
### End of Row
 
The module shall correctly handle the transition between image rows without corrupting the stored line-buffer contents.
 
---
 
### End of Frame
 
After the last pixel has been processed, no additional windows shall be generated.
 
---
 
### Reset During Processing
 
Reset immediately clears all internal storage and invalidates the current window.
 
---
 
<a id="part-11-s17"></a>
# 18. Verification Checklist
 
□ Line buffers store previous rows correctly.
 
□ Window shifts correctly.
 
□ First valid window generated at the correct time.
 
□ Every output window contains the correct pixels.
 
□ `window_valid` asserted only for complete windows.
 
□ Horizontal sliding verified.
 
□ Row transitions verified.
 
□ Reset clears all storage.
 
---
 
<a id="part-11-s18"></a>
# 19. RTL Implementation Notes
 
Recommended implementation:
 
- Line buffers implemented using BRAM or inferred RAM when appropriate.
- Window registers implemented using flip-flops.
- Sequential logic for storage updates.
- Simple combinational assignments for window outputs.
The design should sustain one window update per clock after pipeline fill.
 
---
 
<a id="part-11-s19"></a>
# 20. Design Rationale
 
Without line buffers, generating every new window would require repeatedly fetching overlapping pixels from external memory.
 
By retaining only the previous **N−1** rows and maintaining a sliding window register matrix, each input pixel is fetched exactly once.
 
This architecture:
 
- Minimizes external memory bandwidth.
- Reduces idle cycles in the MAC Array.
- Achieves continuous streaming after startup.
- Improves the overall Figure of Merit by reducing memory traffic without buffering the entire image.
---
 
<a id="part-12"></a>
# Part 12 / 18
# Module Specification — processing_element.sv
 
## 1. Module Overview
 
### Purpose
 
The Processing Element (PE) performs one signed multiplication between:
 
- one image pixel
- one kernel coefficient
It is the smallest computational unit of the accelerator.
 
The MAC Array is built by instantiating multiple identical Processing Elements.
 
---
 
<a id="part-12-s1"></a>
# 2. Position in the Architecture
 
```
             Window Pixel
                  │
                  ▼
           +--------------+
           | Processing   |
           |   Element    |
           +--------------+
                  ▲
                  │
          Kernel Coefficient
```
 
---
 
<a id="part-12-s2"></a>
# 3. Responsibilities
 
The Processing Element shall:
 
- Receive one pixel.
- Receive one kernel coefficient.
- Multiply the two values.
- Produce one signed product.
---
 
<a id="part-12-s3"></a>
# 4. Non-Responsibilities
 
The Processing Element shall NOT:
 
- Perform accumulation.
- Store image pixels.
- Store kernel coefficients.
- Generate windows.
- Apply activation.
- Perform output formatting.
- Control accelerator execution.
---
 
<a id="part-12-s4"></a>
# 5. Mathematical Operation
 
Each PE computes
 
```
product = pixel × coefficient
```
 
where
 
```
pixel
 
↓
 
Unsigned 8-bit
```
 
and
 
```
coefficient
 
↓
 
Signed 8-bit
```
 
---
 
<a id="part-12-s5"></a>
# 6. Input Data Types
 
## Pixel
 
| Property | Value |
|----------|-------|
| Width | 8 bits |
| Type | Unsigned |
 
Range
 
```
0
 
↓
 
255
```
 
---
 
## Kernel Coefficient
 
| Property | Value |
|----------|-------|
| Width | 8 bits |
| Type | Signed |
 
Range
 
```
-128
 
↓
 
127
```
 
---
 
<a id="part-12-s6"></a>
# 7. Output Data Type
 
The multiplication result shall be
 
| Property | Value |
|----------|-------|
| Width | 16 bits |
| Type | Signed |
 
Maximum possible values
 
```
255 × 127 = 32385
 
255 × (-128) = -32640
```
 
Both values fit within a signed 16-bit representation.
 
---
 
<a id="part-12-s7"></a>
# 8. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| pixel | 8 | Unsigned image pixel |
| coeff | 8 | Signed kernel coefficient |
| valid_in | 1 | Input data valid |
 
---
 
<a id="part-12-s8"></a>
# 9. Outputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| product | 16 | Signed multiplication result |
| valid_out | 1 | Product valid |
 
---
 
<a id="part-12-s9"></a>
# 10. Functional Description
 
When
 
```
valid_in = 1
```
 
the PE computes
 
```
product = pixel × coeff
```
 
and asserts
 
```
valid_out = 1
```
 
Otherwise
 
```
valid_out = 0
```
 
The value of `product` is ignored when `valid_out` is low.
 
---
 
<a id="part-12-s10"></a>
# 11. Signed Arithmetic
 
Since the pixel is unsigned and the coefficient is signed, the RTL shall explicitly perform mixed-sign multiplication.
 
Recommended implementation:
 
```systemverilog
logic [7:0]         pixel;
logic signed [7:0]  coeff;
 
logic signed [15:0] product;
 
assign product = $signed({1'b0, pixel}) * coeff;
```
 
This guarantees correct synthesis and avoids accidental unsigned multiplication.
 
---
 
<a id="part-12-s11"></a>
# 12. DSP Inference
 
The PE shall be written in a style that allows the synthesis tool to infer a dedicated DSP block.
 
No vendor-specific primitives shall be instantiated.
 
This keeps the design portable across FPGA families.
 
---
 
<a id="part-12-s12"></a>
# 13. Pipeline Considerations
 
Version 1.0 implements a combinational multiplier.
 
Therefore,
 
```
Input
 
↓
 
Multiply
 
↓
 
Output
```
 
occurs within the same clock cycle from a functional perspective.
 
If timing becomes critical at higher clock frequencies, an optional pipeline register may be inserted in a future revision.
 
---
 
<a id="part-12-s13"></a>
# 14. Reset Behavior
 
The Processing Element contains no internal state.
 
Therefore, reset does not affect the multiplication logic directly.
 
Only `valid_out` shall be considered invalid whenever `valid_in` is low.
 
---
 
<a id="part-12-s14"></a>
# 15. Interaction with Other Modules
 
Receives data from:
 
- sliding_window
- kernel_mem
Provides data to:
 
- MAC_array
The PE shall never communicate directly with any other module.
 
---
 
<a id="part-12-s15"></a>
# 16. Design Rules
 
## Rule 1
 
Exactly one multiplication shall be performed.
 
---
 
## Rule 2
 
No accumulation shall occur inside the PE.
 
---
 
## Rule 3
 
No storage elements shall be added unless explicitly pipelining the multiplier.
 
---
 
## Rule 4
 
The multiplier implementation shall remain generic and synthesizable.
 
---
 
<a id="part-12-s16"></a>
# 17. Corner Cases
 
### Pixel = 0
 
```
Output = 0
```
 
---
 
### Coefficient = 0
 
```
Output = 0
```
 
---
 
### Negative Coefficient
 
The output shall be negative.
 
---
 
### Maximum Positive Product
 
```
255 × 127 = 32385
```
 
---
 
### Maximum Negative Product
 
```
255 × (-128) = -32640
```
 
---
 
<a id="part-12-s17"></a>
# 18. Verification Checklist
 
□ Positive × Positive.
 
□ Positive × Negative.
 
□ Zero × Positive.
 
□ Zero × Negative.
 
□ Maximum positive product.
 
□ Maximum negative product.
 
□ Random multiplication tests.
 
□ Correct valid propagation.
 
---
 
<a id="part-12-s18"></a>
# 19. RTL Implementation Notes
 
Recommended coding style:
 
- Pure combinational logic.
- Continuous assignment for multiplication.
- Explicit signed casting.
- No clocked logic.
- No vendor-specific primitives.
The RTL should remain extremely small and readable.
 
---
 
<a id="part-12-s19"></a>
# 20. Design Rationale
 
The Processing Element intentionally performs only one operation: multiplication.
 
Separating multiplication from accumulation provides several advantages:
 
- Simple, reusable RTL.
- Easy unit-level verification.
- Scalable MAC Array construction.
- Clear separation of responsibilities.
- Flexible future architectural exploration (e.g., pipelining or resource sharing).
By instantiating one PE per kernel coefficient, the accelerator exploits the FPGA's DSP resources to maximize throughput while maintaining a modular architecture.
 
---
 
<a id="part-13"></a>
# Part 13 / 18
# Module Specification — MAC_array.sv
 
## 1. Module Overview
 
### Purpose
 
The MAC Array performs the first reduction stage of the convolution operation.
 
It receives:
 
- one complete N×N window
- one complete N×N kernel
and computes **N row partial sums**.
 
The MAC Array does **not** compute the final convolution result.
 
---
 
<a id="part-13-s1"></a>
# 2. Position in the Architecture
 
```
             Sliding Window
                    │
                    ▼
          N×N Window Pixels
                    │
                    ▼
             +---------------+
             |   MAC_array   |
             +---------------+
                    ▲
                    │
             Kernel Memory
```
 
The MAC Array is the first arithmetic stage of the datapath.
 
---
 
<a id="part-13-s2"></a>
# 3. Internal Architecture
 
For an N×N kernel:
 
```
             Window Pixels
                    │
                    ▼
 
        +-----------------------+
        | N² Processing Elements|
        +-----------------------+
                    │
          N² Products (16 bits)
                    │
                    ▼
      +----------------------------+
      | N Parallel Row Adders      |
      +----------------------------+
                    │
            N Partial Sums
                    │
                    ▼
              accumulator.sv
```
 
---
 
<a id="part-13-s3"></a>
# 4. Responsibilities
 
The MAC Array shall:
 
- Receive one convolution window.
- Receive one kernel.
- Instantiate N² Processing Elements.
- Compute one multiplication per Processing Element.
- Compute N row partial sums.
- Forward the partial sums to the Accumulator.
---
 
<a id="part-13-s4"></a>
# 5. Non-Responsibilities
 
The MAC Array shall NOT:
 
- Produce the final convolution result.
- Apply ReLU.
- Format outputs.
- Store image data.
- Store kernel coefficients.
- Generate sliding windows.
- Control accelerator execution.
---
 
<a id="part-13-s5"></a>
# 6. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| window[N²] | 8 each | Window pixels |
| kernel_coeffs[N²] | 8 each | Signed kernel coefficients |
| window_valid | 1 | Window valid |
 
---
 
<a id="part-13-s6"></a>
# 7. Outputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| partial_sum[N] | Signed | One partial sum per kernel row |
| partial_valid | 1 | Partial sums valid |
 
---
 
<a id="part-13-s7"></a>
# 8. Processing Element Organization
 
Example for **N = 5**
 
```
PE00 PE01 PE02 PE03 PE04
PE10 PE11 PE12 PE13 PE14
PE20 PE21 PE22 PE23 PE24
PE30 PE31 PE32 PE33 PE34
PE40 PE41 PE42 PE43 PE44
```
 
Each PE computes
 
```
pixel × coefficient
```
 
independently.
 
All Processing Elements operate simultaneously.
 
---
 
<a id="part-13-s8"></a>
# 9. Row Reduction
 
Instead of adding all N² products together,
 
each row is reduced independently.
 
Example
 
```
Row 0
 
P00 + P01 + P02 + P03 + P04
 
↓
 
RowSum0
```
 
Similarly,
 
```
RowSum1
 
RowSum2
 
RowSum3
 
RowSum4
```
 
These row sums are forwarded to the Accumulator.
 
---
 
<a id="part-13-s9"></a>
# 10. Partial Sum Width
 
Each product is
 
```
Signed 16 bits
```
 
A row contains
 
```
N
```
 
products.
 
Therefore,
 
the row adder output shall be wide enough to prevent overflow.
 
A recommended width is
 
```
16 + ceil(log₂(N))
```
 
Example
 
| N | Recommended Width |
|---|------------------:|
| 3 | 18 bits |
| 5 | 19 bits |
| 7 | 19 bits |
 
---
 
<a id="part-13-s10"></a>
# 11. Functional Description
 
Whenever
 
```
window_valid = 1
```
 
the MAC Array shall:
 
1. Feed each window pixel to its corresponding Processing Element.
2. Feed each kernel coefficient to its corresponding Processing Element.
3. Collect all products.
4. Reduce each row independently.
5. Assert `partial_valid`.
---
 
<a id="part-13-s11"></a>
# 12. Timing
 
```
Valid Window
 
↓
 
PE Multiplication
 
↓
 
Row Reduction
 
↓
 
Partial Sums
```
 
The MAC Array produces exactly one set of partial sums for every valid input window.
 
---
 
<a id="part-13-s12"></a>
# 13. Reset Behavior
 
The MAC Array contains no architectural state.
 
After reset,
 
```
partial_valid = 0
```
 
The arithmetic outputs are ignored until `partial_valid` becomes asserted.
 
---
 
<a id="part-13-s13"></a>
# 14. Interaction with Other Modules
 
Receives from
 
- sliding_window
- kernel_mem
Provides data to
 
- accumulator
No other module shall directly consume Processing Element outputs.
 
---
 
<a id="part-13-s14"></a>
# 15. Design Rules
 
## Rule 1
 
One Processing Element shall exist for every kernel coefficient.
 
---
 
## Rule 2
 
Every Processing Element operates in parallel.
 
---
 
## Rule 3
 
The MAC Array shall not compute the final convolution sum.
 
---
 
## Rule 4
 
Each row shall be reduced independently.
 
---
 
## Rule 5
 
All row adders shall operate in parallel.
 
---
 
<a id="part-13-s15"></a>
# 16. Corner Cases
 
### Zero Window
 
All partial sums shall be zero.
 
---
 
### Zero Kernel
 
All partial sums shall be zero.
 
---
 
### Negative Coefficients
 
Signed arithmetic shall be preserved throughout the reduction tree.
 
---
 
### Mixed Positive and Negative Products
 
Overflow shall not occur within the chosen partial-sum width.
 
---
 
<a id="part-13-s16"></a>
# 17. Verification Checklist
 
□ All Processing Elements instantiated.
 
□ Window pixels correctly mapped to PEs.
 
□ Kernel coefficients correctly mapped to PEs.
 
□ Row reductions verified.
 
□ Signed arithmetic verified.
 
□ Zero kernel verified.
 
□ Zero image verified.
 
□ Random convolution vectors verified.
 
□ Valid signal propagation verified.
 
---
 
<a id="part-13-s17"></a>
# 18. RTL Implementation Notes
 
Recommended implementation:
 
- Generate loop for Processing Elements.
- Generate loop for row adders.
- Balanced adder trees for each row.
Example:
 
```systemverilog
for (genvar r = 0; r < N; r++) begin
    ...
end
```
 
The reduction tree should be balanced to minimize the combinational delay.
 
---
 
<a id="part-13-s18"></a>
# 19. Design Rationale
 
The convolution operation consists of two distinct reduction stages:
 
1. Row-wise reduction
2. Global accumulation
Separating these stages provides several advantages:
 
- Shallower combinational logic.
- Improved maximum operating frequency.
- Clear module responsibilities.
- Simpler RTL.
- Easier verification.
This hierarchical reduction structure scales naturally as the kernel size increases.
 
---
 
<a id="part-13-s19"></a>
# 20. Resource Considerations
 
For an N×N kernel:
 
| Resource | Quantity |
|----------|---------:|
| Processing Elements | N² |
| DSP Blocks (expected) | N² |
| Row Adders | N |
| Final Accumulator | 1 |
 
This organization balances throughput and timing while remaining consistent with the architecture chosen during the design phase.
 
---
 
<a id="part-14"></a>
# Part 14 / 18
# Module Specification — accumulator.sv
 
## 1. Module Overview
 
### Purpose
 
The Accumulator receives the row partial sums generated by the MAC Array and computes the final convolution result.
 
It is the final arithmetic stage of the convolution engine.
 
Unlike the MAC Array, the Accumulator performs **only addition**.
 
---
 
<a id="part-14-s1"></a>
# 2. Position in the Architecture
 
```
                MAC_array
                    │
                    ▼
          N Row Partial Sums
                    │
                    ▼
            +---------------+
            | accumulator   |
            +---------------+
                    │
                    ▼
         Final Convolution Result
                    │
                    ▼
                 relu.sv
```
 
---
 
<a id="part-14-s2"></a>
# 3. Responsibilities
 
The Accumulator shall:
 
- Receive all row partial sums.
- Compute the final convolution sum.
- Preserve signed arithmetic.
- Forward the final result to the ReLU block.
---
 
<a id="part-14-s3"></a>
# 4. Non-Responsibilities
 
The Accumulator shall NOT:
 
- Perform multiplication.
- Read kernel coefficients.
- Store image pixels.
- Generate sliding windows.
- Apply ReLU.
- Perform output formatting.
- Control accelerator execution.
---
 
<a id="part-14-s4"></a>
# 5. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| partial_sum[N] | PARTIAL_W | Row partial sums |
| partial_valid | 1 | Partial sums valid |
 
---
 
<a id="part-14-s5"></a>
# 6. Outputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| conv_result | ACC_W | Final convolution result |
| conv_valid | 1 | Result valid |
 
---
 
<a id="part-14-s6"></a>
# 7. Datapath
 
For an **N×N** kernel,
 
```
RowSum0
 
RowSum1
 
...
 
RowSum(N−1)
```
 
are reduced into
 
```
Convolution Result
```
 
Example for **N = 5**
 
```
RowSum0
    │
RowSum1
    │
RowSum2
    │
RowSum3
    │
RowSum4
    │
    ▼
 Final Sum
```
 
---
 
<a id="part-14-s7"></a>
# 8. Arithmetic Operation
 
The accumulator computes
 
```
conv_result =
RowSum0 +
RowSum1 +
...
RowSum(N−1)
```
 
No multiplication is performed.
 
---
 
<a id="part-14-s8"></a>
# 9. Output Width
 
Each row sum has width
 
```
PARTIAL_W
```
 
The accumulator output shall be wide enough to prevent overflow.
 
Recommended width:
 
```
ACC_W = PARTIAL_W + ceil(log₂(N))
```
 
Example
 
| N | PARTIAL_W | ACC_W |
|---|----------:|------:|
| 3 | 18 | 20 |
| 5 | 19 | 22 |
| 7 | 19 | 22 |
 
The exact width shall be defined in the shared package.
 
---
 
<a id="part-14-s9"></a>
# 10. Functional Description
 
Whenever
 
```
partial_valid = 1
```
 
the accumulator shall:
 
1. Read all row partial sums.
2. Compute the final sum.
3. Assert
```
conv_valid = 1
```
 
Otherwise
 
```
conv_valid = 0
```
 
---
 
<a id="part-14-s10"></a>
# 11. Timing
 
```
Partial Sums
 
↓
 
Final Addition
 
↓
 
Convolution Result
```
 
Exactly one convolution result shall be generated for every valid input window.
 
---
 
<a id="part-14-s11"></a>
# 12. Reset Behavior
 
The accumulator contains no architectural state.
 
After reset,
 
```
conv_valid = 0
```
 
The value of `conv_result` is ignored while `conv_valid` is low.
 
---
 
<a id="part-14-s12"></a>
# 13. Interaction with Other Modules
 
Receives from:
 
- MAC_array
Provides data to:
 
- relu
No other module shall consume the row partial sums directly.
 
---
 
<a id="part-14-s13"></a>
# 14. Design Rules
 
## Rule 1
 
Only addition shall be performed.
 
---
 
## Rule 2
 
Signed arithmetic shall be preserved throughout the reduction.
 
---
 
## Rule 3
 
The accumulator shall not saturate, clip, truncate, or round.
 
Those operations belong exclusively to `output_formatter.sv`.
 
---
 
## Rule 4
 
One convolution result shall be generated for each valid window.
 
---
 
<a id="part-14-s14"></a>
# 15. Corner Cases
 
### All Partial Sums = 0
 
```
Output = 0
```
 
---
 
### Mixed Positive and Negative Values
 
The final result shall preserve signed arithmetic.
 
---
 
### Maximum Positive Sum
 
The selected accumulator width shall prevent overflow.
 
---
 
### Maximum Negative Sum
 
The selected accumulator width shall prevent overflow.
 
---
 
<a id="part-14-s15"></a>
# 16. Verification Checklist
 
□ Correct addition of all row sums.
 
□ Signed arithmetic verified.
 
□ Positive-only vectors.
 
□ Negative-only vectors.
 
□ Mixed-sign vectors.
 
□ Zero vector.
 
□ Random test vectors.
 
□ Correct propagation of `conv_valid`.
 
---
 
<a id="part-14-s16"></a>
# 17. RTL Implementation Notes
 
Recommended implementation:
 
- Pure combinational reduction.
- Balanced adder tree preferred over a linear chain.
- No registers unless pipelining is introduced in a future revision.
Example conceptual implementation:
 
```systemverilog
conv_result =
    partial_sum[0] +
    partial_sum[1] +
    ...
    partial_sum[N-1];
```
 
---
 
<a id="part-14-s17"></a>
# 18. Design Rationale
 
The accelerator divides the convolution computation into three stages:
 
1. Multiplication (`processing_element.sv`)
2. Row reduction (`MAC_array.sv`)
3. Final accumulation (`accumulator.sv`)
This hierarchy provides:
 
- Shorter critical paths.
- Better scalability with kernel size.
- Simpler RTL.
- Easier unit verification.
- Clear separation of responsibilities.
---
 
<a id="part-14-s18"></a>
# 19. Resource Considerations
 
The accumulator consumes:
 
- LUT-based adders.
- No DSP blocks.
- No BRAM.
Its hardware cost is small compared with the Processing Elements and has minimal impact on the Figure of Merit.
 
---
 
<a id="part-15"></a>
# Part 15 / 18
# Module Specification — relu.sv
 
## 1. Module Overview
 
### Purpose
 
The ReLU module implements the Rectified Linear Unit activation function.
 
It receives the signed convolution result from the Accumulator and optionally suppresses negative values.
 
The module is enabled or bypassed according to the runtime configuration stored in `cfg.sv`.
 
---
 
<a id="part-15-s1"></a>
# 2. Position in the Architecture
 
```
              accumulator
                    │
                    ▼
           Convolution Result
                    │
                    ▼
              +-----------+
              |  relu.sv  |
              +-----------+
                    │
                    ▼
          output_formatter.sv
```
 
The ReLU module belongs to the datapath but performs only post-processing.
 
---
 
<a id="part-15-s2"></a>
# 3. Responsibilities
 
The ReLU module shall:
 
- Receive the convolution result.
- Check the sign of the result.
- Replace negative values with zero when enabled.
- Forward positive values unchanged.
- Support runtime enable/disable.
---
 
<a id="part-15-s3"></a>
# 4. Non-Responsibilities
 
The ReLU module shall NOT:
 
- Perform convolution.
- Perform multiplication.
- Perform accumulation.
- Perform scaling.
- Perform rounding.
- Perform saturation.
- Perform clipping.
- Store any data.
---
 
<a id="part-15-s4"></a>
# 5. Mathematical Operation
 
When ReLU is enabled:
 
```
          { input,    input ≥ 0
output =
          { 0,        input < 0
```
 
When ReLU is disabled:
 
```
output = input
```
 
---
 
<a id="part-15-s5"></a>
# 6. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| conv_result | ACC_W | Signed convolution result |
| conv_valid | 1 | Input valid |
| relu_en | 1 | Runtime enable |
 
---
 
<a id="part-15-s6"></a>
# 7. Outputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| relu_result | ACC_W | Output after activation |
| relu_valid | 1 | Output valid |
 
---
 
<a id="part-15-s7"></a>
# 8. Functional Description
 
Whenever
 
```
conv_valid = 1
```
 
the module behaves as follows.
 
### Case 1 — ReLU Disabled
 
```
relu_result = conv_result
```
 
No modification is performed.
 
---
 
### Case 2 — ReLU Enabled
 
If
 
```
conv_result < 0
```
 
then
 
```
relu_result = 0
```
 
Otherwise
 
```
relu_result = conv_result
```
 
---
 
<a id="part-15-s8"></a>
# 9. Timing
 
```
Accumulator
 
↓
 
ReLU
 
↓
 
Output Formatter
```
 
Exactly one output shall be generated for every valid input.
 
---
 
<a id="part-15-s9"></a>
# 10. Reset Behavior
 
The ReLU module contains no internal state.
 
After reset,
 
```
relu_valid = 0
```
 
The value of `relu_result` is ignored whenever `relu_valid` is low.
 
---
 
<a id="part-15-s10"></a>
# 11. Interaction with Other Modules
 
Receives data from:
 
- accumulator
- cfg
Provides data to:
 
- output_formatter
---
 
<a id="part-15-s11"></a>
# 12. Design Rules
 
## Rule 1
 
Only negative values may be modified.
 
---
 
## Rule 2
 
Positive values shall pass through unchanged.
 
---
 
## Rule 3
 
Zero shall remain zero.
 
---
 
## Rule 4
 
When disabled,
 
the module shall behave as a direct wire.
 
---
 
<a id="part-15-s12"></a>
# 13. Corner Cases
 
### Input = 0
 
```
Output = 0
```
 
---
 
### Input > 0
 
```
Output = Input
```
 
---
 
### Input < 0
 
```
Output = 0
```
 
---
 
### ReLU Disabled
 
```
Output = Input
```
 
for all values.
 
---
 
<a id="part-15-s13"></a>
# 14. Verification Checklist
 
□ Positive input passes unchanged.
 
□ Negative input becomes zero.
 
□ Zero remains zero.
 
□ ReLU disabled bypasses input correctly.
 
□ Valid signal propagates correctly.
 
□ Random signed vectors verified.
 
---
 
<a id="part-15-s14"></a>
# 15. RTL Implementation Notes
 
Recommended implementation:
 
```systemverilog
if (!relu_en)
    relu_result = conv_result;
else if (conv_result < 0)
    relu_result = '0;
else
    relu_result = conv_result;
```
 
The implementation is purely combinational.
 
No registers are required.
 
---
 
<a id="part-15-s15"></a>
# 16. Design Rationale
 
Although ReLU could be merged into the Output Formatter, it is intentionally implemented as a separate RTL module for the following reasons:
 
- Demonstrates the optional competition feature explicitly.
- Improves modularity.
- Simplifies unit-level verification.
- Allows future replacement with other activation functions (e.g., Leaky ReLU, ReLU6, PReLU) without modifying the Output Formatter.
This separation aligns with the accelerator's design philosophy of assigning a single primary responsibility to each module.
 
---
 
<a id="part-15-s16"></a>
# 17. Resource Considerations
 
The ReLU module consists primarily of:
 
- One signed comparison.
- One multiplexer.
Expected FPGA resource usage:
 
- DSPs: **0**
- BRAMs: **0**
- LUTs: Very low
- FFs: **0** (combinational implementation)
Its contribution to the overall Figure of Merit is therefore negligible.
 
---
 
<a id="part-16"></a>
# Part 16 / 18
# Module Specification — output_formatter.sv
 
## 1. Module Overview
 
### Purpose
 
The Output Formatter converts the raw convolution result into the final output pixel format required by the accelerator.
 
It is responsible for all numerical post-processing after convolution.
 
Unlike previous modules, it performs **no convolution arithmetic**.
 
---
 
<a id="part-16-s1"></a>
# 2. Position in the Architecture
 
```
            accumulator
                  │
                  ▼
              relu.sv
                  │
                  ▼
         +-------------------+
         | output_formatter  |
         +-------------------+
                  │
                  ▼
            output_ctrl.sv
```
 
---
 
<a id="part-16-s2"></a>
# 3. Responsibilities
 
The Output Formatter shall:
 
- Scale the convolution result.
- Optionally round the scaled value.
- Saturate values outside the representable range.
- Produce the final output precision.
- Forward the formatted output pixel.
---
 
<a id="part-16-s3"></a>
# 4. Non-Responsibilities
 
The Output Formatter shall NOT:
 
- Perform multiplication.
- Perform accumulation.
- Perform ReLU.
- Store output pixels.
- Generate memory addresses.
- Control accelerator execution.
---
 
<a id="part-16-s4"></a>
# 5. Processing Pipeline
 
Every valid sample shall pass through the following stages.
 
```
Input
 
↓
 
Arithmetic Right Shift
 
↓
 
Optional Rounding
 
↓
 
Saturation
 
↓
 
16-bit Output
```
 
---
 
<a id="part-16-s5"></a>
# 6. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| relu_result | ACC_W | Signed convolution result |
| relu_valid | 1 | Input valid |
| shamt | 5 | Runtime scaling factor |
| round_en | 1 | Enable rounding |
 
---
 
<a id="part-16-s6"></a>
# 7. Outputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| pixel_out | 16 | Final formatted output |
| pixel_valid | 1 | Output valid |
 
---
 
<a id="part-16-s7"></a>
# 8. Stage 1 — Scaling
 
Scaling is implemented using an arithmetic right shift.
 
```
scaled = relu_result >>> shamt;
```
 
Arithmetic shifting preserves the sign bit.
 
The shift amount is supplied by `cfg.sv`.
 
---
 
<a id="part-16-s8"></a>
# 9. Stage 2 — Optional Rounding
 
When
 
```
round_en = 0
```
 
```
rounded = scaled;
```
 
When
 
```
round_en = 1
```
 
the formatter rounds the scaled value to the nearest representable integer before saturation.
 
One recommended implementation is
 
```
rounded = scaled + (1 << (shamt - 1))
```
 
before the arithmetic shift.
 
> **Note:** The exact RTL implementation may differ, provided the numerical behavior matches the chosen rounding policy.
 
---
 
<a id="part-16-s9"></a>
# 10. Stage 3 — Saturation
 
The project specifies a **16-bit signed output**.
 
Therefore,
 
```
Maximum = +32767
 
Minimum = -32768
```
 
If
 
```
rounded > 32767
```
 
```
pixel_out = 32767
```
 
If
 
```
rounded < -32768
```
 
```
pixel_out = -32768
```
 
Otherwise
 
```
pixel_out = rounded
```
 
---
 
<a id="part-16-s10"></a>
# 11. Functional Description
 
Whenever
 
```
relu_valid = 1
```
 
the formatter shall:
 
1. Apply arithmetic scaling.
2. Apply optional rounding.
3. Saturate if necessary.
4. Assert
```
pixel_valid = 1
```
 
Otherwise
 
```
pixel_valid = 0
```
 
---
 
<a id="part-16-s11"></a>
# 12. Timing
 
```
ReLU Result
 
↓
 
Scaling
 
↓
 
Rounding
 
↓
 
Saturation
 
↓
 
Output Pixel
```
 
Exactly one formatted output shall be produced for every valid convolution result.
 
---
 
<a id="part-16-s12"></a>
# 13. Reset Behavior
 
The Output Formatter contains no architectural state.
 
After reset,
 
```
pixel_valid = 0
```
 
The output value is ignored while `pixel_valid` is low.
 
---
 
<a id="part-16-s13"></a>
# 14. Interaction with Other Modules
 
Receives data from:
 
- relu
- cfg
Provides data to:
 
- output_ctrl
---
 
<a id="part-16-s14"></a>
# 15. Design Rules
 
## Rule 1
 
Scaling shall always occur before saturation.
 
---
 
## Rule 2
 
Rounding is optional and controlled by `round_en`.
 
---
 
## Rule 3
 
The formatter shall never modify the sign incorrectly.
 
---
 
## Rule 4
 
The output shall always be a signed 16-bit value.
 
---
 
<a id="part-16-s15"></a>
# 16. Corner Cases
 
### No Scaling
 
```
shamt = 0
```
 
The input passes unchanged to the rounding stage.
 
---
 
### Maximum Positive Overflow
 
Output shall saturate to
 
```
32767
```
 
---
 
### Maximum Negative Overflow
 
Output shall saturate to
 
```
-32768
```
 
---
 
### Rounding Disabled
 
Scaling is performed without rounding.
 
---
 
### Rounding Enabled
 
The scaled value is rounded according to the selected rounding policy.
 
---
 
<a id="part-16-s16"></a>
# 17. Verification Checklist
 
□ No scaling.
 
□ Various shift amounts.
 
□ Positive overflow.
 
□ Negative overflow.
 
□ Rounding disabled.
 
□ Rounding enabled.
 
□ Positive values.
 
□ Negative values.
 
□ Zero value.
 
□ Random signed vectors.
 
---
 
<a id="part-16-s17"></a>
# 18. RTL Implementation Notes
 
Recommended implementation:
 
- Pure combinational logic.
- Arithmetic shift operator (`>>>`).
- Signed comparisons for saturation.
- Runtime-configurable shift amount.
No registers are required.
 
---
 
<a id="part-16-s18"></a>
# 19. Design Rationale
 
The Output Formatter isolates all numerical formatting from the convolution datapath.
 
This separation provides several advantages:
 
- Simpler arithmetic modules.
- Easier experimentation with different scaling factors.
- Runtime-adjustable output precision.
- Independent verification of formatting behavior.
It also aligns directly with the competition requirements regarding overflow handling, truncation, saturation, and rounding.
 
---
 
<a id="part-16-s19"></a>
# 20. Resource Considerations
 
Expected FPGA resource usage:
 
- DSPs: **0**
- BRAMs: **0**
- LUTs: Low
- FFs: **0** (combinational implementation)
The module has minimal impact on the overall Figure of Merit while providing essential numerical processing.
 
---
 
<a id="part-17"></a>
# Part 17 / 18
# Module Specification — output_ctrl.sv
 
## 1. Module Overview
 
### Purpose
 
The Output Controller manages the transmission of the output feature-map produced by the accelerator.
 
It receives formatted output pixels from `output_formatter.sv`, keeps track of the output image position, and forwards the pixels to the external world.
 
It also detects when the entire output feature-map has been transmitted and notifies the Global Controller.
 
---
 
<a id="part-17-s1"></a>
# 2. Position in the Architecture
 
```
             output_formatter
                    │
                    ▼
      pixel + valid + pixel_last
                    │
                    ▼
             +---------------+
             |  output_ctrl  |
             +---------------+
                    │
                    ▼
           External Output Interface
```
 
---
 
<a id="part-17-s2"></a>
# 3. Responsibilities
 
The Output Controller shall:
 
- Receive formatted output pixels.
- Stream output pixels externally.
- Count output rows.
- Count output columns.
- Detect completion of the output feature-map.
- Notify the Global Controller that processing has completed.
---
 
<a id="part-17-s3"></a>
# 4. Non-Responsibilities
 
The Output Controller shall NOT:
 
- Perform convolution.
- Perform arithmetic.
- Store the complete output feature-map.
- Apply ReLU.
- Apply scaling or saturation.
- Control other datapath modules.
---
 
<a id="part-17-s4"></a>
# 5. Inputs
 
## Clock & Reset
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
 
---
 
## Configuration
 
| Signal | Width | Description |
|---------|------:|-------------|
| out_width | 16 | Output feature-map width |
| out_height | 16 | Output feature-map height |
 
---
 
## Datapath
 
| Signal | Width | Description |
|---------|------:|-------------|
| pixel_in | 16 | Formatted output pixel |
| pixel_valid | 1 | Pixel valid |
| pixel_last | 1 | Last output pixel indicator |
 
---
 
<a id="part-17-s5"></a>
# 6. Outputs
 
| Signal | Width | Destination |
|---------|------:|-------------|
| pixel_out | 16 | External interface |
| pixel_out_valid | 1 | External interface |
| done | 1 | global_ctrl |
 
---
 
<a id="part-17-s6"></a>
# 7. Internal Registers
 
| Register | Width | Description |
|----------|------:|-------------|
| row_cnt | 16 | Current output row |
| col_cnt | 16 | Current output column |
 
---
 
<a id="part-17-s7"></a>
# 8. Functional Description
 
Whenever
 
```
pixel_valid = 1
```
 
the controller shall:
 
- Forward the output pixel.
- Assert `pixel_out_valid`.
- Update the row and column counters.
---
 
## Column Counter
 
After every valid output pixel,
 
```
col_cnt++
```
 
When
 
```
col_cnt == out_width - 1
```
 
the controller performs
 
```
col_cnt = 0
row_cnt++
```
 
---
 
## Row Counter
 
When
 
```
row_cnt == out_height - 1
```
 
and
 
```
col_cnt == out_width - 1
```
 
the controller has transmitted the final output pixel.
 
---
 
<a id="part-17-s8"></a>
# 9. Completion Detection
 
The accelerator also receives
 
```
pixel_last
```
 
from `output_formatter.sv`.
 
When
 
```
pixel_last = 1
```
 
the controller shall:
 
```
done = 1
```
 
for one clock cycle.
 
Afterward,
 
the controller returns to the idle state.
 
---
 
<a id="part-17-s9"></a>
# 10. Timing
 
```
Formatted Pixel
 
↓
 
Forward Pixel
 
↓
 
Update Counters
 
↓
 
Detect Completion
```
 
One valid output pixel is produced for every valid formatter output.
 
---
 
<a id="part-17-s10"></a>
# 11. Reset Behavior
 
After reset
 
```
row_cnt = 0
 
col_cnt = 0
 
pixel_out_valid = 0
 
done = 0
```
 
---
 
<a id="part-17-s11"></a>
# 12. Interaction with Other Modules
 
Receives data from:
 
- output_formatter
- cfg
Provides data to:
 
- External interface
- global_ctrl
---
 
<a id="part-17-s12"></a>
# 13. Design Rules
 
## Rule 1
 
Output pixels shall never be modified.
 
---
 
## Rule 2
 
The controller shall only transmit pixels when `pixel_valid` is asserted.
 
---
 
## Rule 3
 
Counters shall only advance on valid output pixels.
 
---
 
## Rule 4
 
The controller shall assert `done` exactly once for each processed image.
 
---
 
<a id="part-17-s13"></a>
# 14. Corner Cases
 
### Invalid Cycle
 
When
 
```
pixel_valid = 0
```
 
the controller shall:
 
- Hold counters.
- Produce no output.
---
 
### Reset During Transmission
 
Transmission is aborted.
 
Counters return to zero.
 
The next image begins from the first pixel.
 
---
 
### Last Output Pixel
 
The controller shall assert
 
```
done = 1
```
 
for exactly one clock cycle.
 
---
 
<a id="part-17-s14"></a>
# 15. Verification Checklist
 
□ Pixels forwarded correctly.
 
□ Row counter verified.
 
□ Column counter verified.
 
□ Invalid cycles ignored.
 
□ Last pixel detected.
 
□ Done pulse verified.
 
□ Reset behavior verified.
 
---
 
<a id="part-17-s15"></a>
# 16. RTL Implementation Notes
 
Recommended implementation:
 
- One sequential process for counters.
- Continuous assignments for forwarded data.
- Single-cycle `done` pulse generation.
The implementation should remain lightweight.
 
---
 
<a id="part-17-s16"></a>
# 17. Design Rationale
 
The Output Controller separates output stream management from numerical processing.
 
This allows:
 
- Output protocol changes without modifying arithmetic modules.
- Independent verification of output sequencing.
- Cleaner top-level architecture.
---
 
<a id="part-17-s17"></a>
# 18. Resource Considerations
 
Expected FPGA resource usage:
 
- LUTs: Very low.
- FFs: Row/column counters.
- DSPs: 0.
- BRAMs: 0.
The module contributes negligibly to the overall Figure of Merit.
 
---
 
<a id="part-18"></a>
# Part 18 / 18
# Module Specification — global_ctrl.sv
 
## 1. Module Overview
 
### Purpose
 
The Global Controller manages the overall execution of the accelerator.
 
It is responsible for coordinating the beginning and end of processing but does not participate in datapath computations.
 
---
 
<a id="part-18-s1"></a>
# 2. Position in the Architecture
 
```
                 START
                   │
                   ▼
            +---------------+
            | global_ctrl   |
            +---------------+
             │           │
             │           │
             ▼           ▼
      processing_en    done
             ▲
             │
        output_ctrl
```
 
---
 
<a id="part-18-s2"></a>
# 3. Responsibilities
 
The Global Controller shall:
 
- Wait for a START command.
- Enable accelerator processing.
- Monitor completion.
- Return the accelerator to the idle state.
---
 
<a id="part-18-s3"></a>
# 4. Non-Responsibilities
 
The Global Controller shall NOT:
 
- Count pixels.
- Generate memory addresses.
- Store data.
- Perform arithmetic.
- Generate convolution windows.
- Apply activation functions.
- Format outputs.
---
 
<a id="part-18-s4"></a>
# 5. Inputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| clk | 1 | System clock |
| rst_n | 1 | Active-low reset |
| start | 1 | Start processing |
| done | 1 | Output processing completed |
 
---
 
<a id="part-18-s5"></a>
# 6. Outputs
 
| Signal | Width | Description |
|---------|------:|-------------|
| processing_en | 1 | Enables all datapath modules |
| busy | 1 | Accelerator busy |
| idle | 1 | Accelerator idle |
 
---
 
<a id="part-18-s6"></a>
# 7. FSM States
 
```
IDLE
 
↓
 
LOAD_CFG
 
↓
 
PROCESSING
 
↓
 
COMPLETE
 
↓
 
IDLE
```
 
---
 
<a id="part-18-s7"></a>
# 8. State Descriptions
 
## IDLE
 
- Wait for START.
- processing_en = 0
---
 
## LOAD_CFG
 
One clock cycle.
 
Configuration registers are assumed to already contain valid values.
 
This state exists only to cleanly separate configuration from execution.
 
---
 
## PROCESSING
 
processing_en = 1
 
All datapath modules operate continuously.
 
Remain in this state until
 
```
done == 1
```
 
---
 
## COMPLETE
 
Generate
 
```
busy = 0
 
idle = 1
```
 
Return to IDLE.
 
---
 
<a id="part-18-s8"></a>
# 9. Reset Behavior
 
After reset
 
```
State = IDLE
 
processing_en = 0
 
busy = 0
 
idle = 1
```
 
---
 
<a id="part-18-s9"></a>
# 10. Verification Checklist
 
□ Correct reset.
 
□ Start detection.
 
□ Correct state transitions.
 
□ Busy asserted during processing.
 
□ Processing enabled correctly.
 
□ Done detection.
 
□ Return to IDLE.
 
---
 
<a id="part-18-s10"></a>
# 11. RTL Notes
 
Recommended implementation:
 
- Enumerated FSM.
- One sequential process.
- One combinational next-state process.
The FSM should remain very small.
 
---
 
<a id="part-18-s11"></a>
# 12. Design Philosophy
 
The Global Controller coordinates execution.
 
Each datapath module manages its own internal behavior.
 
This minimizes coupling and greatly simplifies verification.
 
---
 
<a id="part-18-s12"></a>
# Module Specification — dut_top.sv
 
## 1. Purpose
 
The top-level module instantiates and connects every accelerator block.
 
It contains no computational logic.
 
---
 
<a id="part-18-s13"></a>
# 2. Instantiated Modules
 
```
cfg
 
global_ctrl
 
input_if
 
input_ctrl
 
kernel_mem
 
sliding_window
 
processing_element
    (generated inside MAC_array)
 
MAC_array
 
accumulator
 
relu
 
output_formatter
 
output_ctrl
```
 
---
 
<a id="part-18-s14"></a>
# 3. Interconnection
 
```
                    cfg
                     │
                     ▼
 
External Input
 
↓
 
input_if
 
↓
 
input_ctrl
 
↓
 
sliding_window
 
↓
 
MAC_array
 
↓
 
accumulator
 
↓
 
relu
 
↓
 
output_formatter
 
↓
 
output_ctrl
 
↓
 
External Output
 
 
             ▲
 
      global_ctrl
```
 
---
 
<a id="part-18-s15"></a>
# 4. Top-Level Responsibilities
 
The top module shall:
 
- Instantiate all modules.
- Connect all signals.
- Propagate clock and reset.
- Route configuration signals.
- Route datapath signals.
---
 
<a id="part-18-s16"></a>
# 5. Non-Responsibilities
 
The top module shall NOT:
 
- Perform arithmetic.
- Implement FSM logic.
- Store image data.
- Modify datapath values.
---
 
<a id="part-18-s17"></a>
# 6. Coding Guidelines
 
The top module should contain only:
 
- Parameters.
- Internal signal declarations.
- Module instantiations.
- Signal connections.
No behavioral logic should be added except simple wiring.
 
---
 
<a id="part-18-s18"></a>
# 7. Verification Checklist
 
□ All modules instantiated.
 
□ Clock connected.
 
□ Reset connected.
 
□ Configuration connected.
 
□ Datapath connected.
 
□ Control path connected.
 
□ No floating signals.
 
□ No multiple drivers.
 
---
 
<a id="part-18-s19"></a>
# 8. Final Frozen RTL Files
 
The complete RTL architecture consists of:
 
```
dut_top.sv
 
cfg.sv
 
global_ctrl.sv
 
input_if.sv
 
input_ctrl.sv
 
kernel_mem.sv
 
sliding_window.sv
 
processing_element.sv
 
MAC_array.sv
 
accumulator.sv
 
relu.sv
 
output_formatter.sv
 
output_ctrl.sv
```
 
Additionally, the project contains one shared package:
 
```
accelerator_pkg.sv
```
 
This package contains:
 
- Common typedefs.
- Width calculations.
- Shared parameters.
- Utility functions.
It is **not** considered a DUT module.
 
---
 
<a id="part-18-s20"></a>
# 9. Final Architecture Summary
 
The accelerator processes one image as follows:
 
```
Configuration Registers
          │
          ▼
Global Controller
          │
          ▼
Input Interface
          │
          ▼
Input Controller
          │
          ▼
Sliding Window
          │
          ▼
MAC Array
          │
          ▼
Accumulator
          │
          ▼
ReLU (Optional)
          │
          ▼
Output Formatter
          │
          ▼
Output Controller
          │
          ▼
Output Feature Map
```
 
---
 
<a id="end-of-spec"></a>
# End of Detailed Specification
 
Architecture Status: **Frozen**
 
The project is now ready for:
 
1. RTL implementation.
2. Verification Plan development.
3. SystemVerilog coding.
4. Python golden model development.
5. Module-level verification.
6. Top-level integration.
7. FPGA synthesis and implementation.
---