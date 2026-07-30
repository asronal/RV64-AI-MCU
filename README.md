# RV64-AI-MCU RTL Handoff Repository

## Project Overview

This repository contains a flat RTL implementation of a RV64-style System-on-Chip (SoC) designed for digital design exploration, functional simulation, and ASIC front-end synthesis handoff. The project is centered around the top-level module `rv64_ai_soc_top`, which integrates a processor-oriented core/memory subsystem, DSP and AI-oriented accelerators, a wide set of peripherals, and a lightweight AXI-Lite-like control interface.

The design is structured to be easy to navigate, easy to simulate, and suitable for synthesis flows that use Synopsys Design Compiler. The codebase has been organized into clearly separated domains so that each subsystem can be understood and reused independently.

---

## What This Repository Contains

The repository brings together several important pieces of a modern SoC design flow:

- RTL source files for the full SoC and its subsystems
- A consolidated testbench for top-level verification
- Timing constraints for synthesis
- Synthesis and reporting scripts
- Report and waveform outputs generated during design evaluation

This makes the repository useful both as a design reference and as a handoff package for later synthesis and implementation stages.

---

## Architecture Summary

The SoC is divided into several functional groups:

### 1. Core and Memory Subsystem
These modules handle the core execution path, memory access, and interconnect behavior. Representative files include:

- `core_cm.v`
- `ctrl_cm.v`
- `mem_cm.v`
- `xbar_cm.v`
- `pkg_cm.v`

### 2. DSP Subsystem
This group includes arithmetic and DSP-focused hardware blocks for signal-processing style workloads:

- `dsp_d.v`
- `dspc_d.v`
- `mac_d.v`
- `simd_d.v`
- `dspkg_d.v`

### 3. AI and TPU-Related Accelerators
The AI side of the design includes tensor-oriented processing and data movement blocks:

- `tpu_a.v`
- `tsa_a.v`
- `tdma_a.v`
- `xt_a.v`
- `tpupkg_a.v`

### 4. Peripherals and Security Blocks
The peripheral and security domain adds the interface and system-control features needed for a complete SoC:

- `gpio_ps.v`
- `uart_ps.v`
- `spi_ps.v`
- `i2c_ps.v`
- `qspi_ps.v`
- `pwm_ps.v`
- `adc_ps.v`
- `plic_ps.v`
- `sec_ps.v`
- `crypto_ps.v`
- `dbg_ps.v`
- `trace_ps.v`
- `perf_ps.v`
- `brk_ps.v`

The top-level integration point is `rtl/soc_top_ps.v`.

---

## Technical Details

This section summarizes the main hardware components present in the SoC, including memory types, processor and accelerator units, and system-level peripherals.

### Memory Architecture

- `rtl/mem_cm.v` and `rtl/mem_bank.v` implement the main memory subsystem.
- The design includes explicit bank instances for:
  - Boot ROM
  - Internal SRAM
  - Tensor SRAM
  - One-time programmable (OTP) memory
  - Instruction cache (I-cache)
  - Data cache (D-cache)
- Memory banks are initialized through the top-level reset/init path and are accessed by the core through the `mem_cm` subsystem.

### Core and Execution Units

- `rtl/core_cm.v` contains the RV64-style core execution pipeline and register file.
- The core is responsible for instruction fetch, decode, execution, and data memory access.
- It exposes instruction and data memory interfaces to the memory subsystem and performance counter outputs for monitoring.

### DSP Subsystem

- DSP-related modules are grouped under `rtl/` with file suffixes such as `_d.v`.
- Key DSP blocks include:
  - `dsp_d.v`
  - `dspc_d.v`
  - `mac_d.v`
  - `simd_d.v`
  - `dspkg_d.v`
- These units provide arithmetic and signal-processing capabilities that complement the core for high-throughput compute.

### TPU and AI Accelerators

- AI/TPU accelerators are implemented in the `*_a.v` files.
- Important AI-related blocks include:
  - `tpu_a.v`
  - `tsa_a.v`
  - `tdma_a.v`
  - `xt_a.v`
  - `tpupkg_a.v`
- These modules support tensor processing, matrix operations, and accelerator-oriented data movement inside the SoC.

### Peripheral and System Units

- The SoC includes an extensive set of peripheral controllers and system services:
  - GPIO, UART, SPI, I2C, QSPI, PWM, ADC
  - PLIC interrupt controller, security engine, crypto engine
  - Debug unit, trace buffer, performance counters, breakpoint logic
- These units are accessible through a lightweight AXI-Lite-like register interface managed by the top-level wrapper.

### Top-Level Integration

- `rtl/soc_top_ps.v` stitches together all of the above subsystems into a single chip-level design.
- It routes the AXI-Lite-like control bus, distributes reset/init signals, and instantiates the core, memory subsystem, DSP/TPU accelerators, and peripheral blocks.
- The top-level module is the main entry point for simulation and synthesis of the complete SoC.

---

## Detailed Technical Specification

This design targets a fully synthesizable RV64-AI-MCU SoC with advanced compute, memory, and security features.

### Processor Core and ISA

- RV64IMC ISA support with a 5-stage pipeline: IF, ID, EX, MEM, WB.
- Forwarding, hazard detection, pipeline stalls, flushing, and load-use hazard handling.
- 2-bit dynamic branch prediction and Branch Target Buffer (BTB).
- Optional Return Address Stack and Machine Mode support.
- 32 × 64-bit general-purpose registers and performance counters.
- Modular control unit architecture in the core path.

### Memory Subsystem

- 64 KB Boot ROM.
- 512 KB internal SRAM.
- 256 KB dedicated Tensor SRAM.
- 4 KB OTP memory.
- 32 KB Instruction Cache.
- 32 KB Data Cache.
- 16 MB external QSPI Flash with Execute-In-Place (XIP) support.
- 8 MB Octal SPI PSRAM (expandable to 16 MB).
- AXI4-Lite crossbar interconnect connecting CPU, memories, DMA, peripherals, DSP, TPU, and security modules.

### DSP Subsystem

- Dedicated DSP coprocessor connected through the AXI4-Lite interconnect.
- 128-bit SIMD engine and 128-bit accumulator MAC engine.
- INT8, INT16, INT32, and INT64 arithmetic support.
- 4× INT8 MAC per cycle, 2× INT16 MAC per cycle, 1× INT32 MAC per cycle, 1× INT64 MAC per cycle.
- Vector operations including add, subtract, multiply, MAC, dot product, min/max, clipping, rounding, averaging, saturating arithmetic, shifts, pack/unpack, shuffle, permute, compare, and vector reduction.
- Dedicated hardware accelerators for FFT/IFFT, FIR/IIR filters, 1D/2D convolution, depthwise convolution, pointwise convolution, grouped/dilated convolution, cross correlation, auto correlation, normalized correlation, matrix operations, and more.
- Matrix support up to 32×32, with local memories where appropriate.

### TPU and AI Accelerator Subsystem

- Dedicated INT8 TPU optimized for TinyML and TensorFlow Lite Micro.
- 16×16 systolic array with 256 INT8 MAC units.
- INT16 and INT32 accumulation results.
- 256 KB Tensor SRAM and dedicated Tensor DMA.
- Double buffering and a high-bandwidth tensor memory controller.
- Hardware acceleration for GEMM, matrix multiplication, Conv2D, depthwise/pointwise convolution, pooling, activation functions, normalization, quantization, dequantization, tensor copy/fill/reshape/concatenate.
- Custom XTENSOR instruction extension for TPU command issuing while maintaining RV64IMC ISA compatibility.

### Peripheral and System Subsystem

- GPIO, 2× UART, 2× SPI, 2× I²C, PWM, timers, watchdog, RTC.
- 12-bit ADC, USB Full-Speed, CAN FD.
- Platform-Level Interrupt Controller (PLIC), CLINT timer, QSPI Flash controller, Octal SPI PSRAM controller.
- 8-channel scatter-gather DMA controller.

### IoT Security and System Control

- Secure Boot, AES-128, AES-256, SHA-256, SHA-512, CRC32.
- True Random Number Generator (TRNG), Physical Memory Protection (PMP), secure firmware update.
- Anti-rollback protection, secure JTAG lock, OTP key storage, device unique ID.
- Clock gating, sleep modes, deep sleep, peripheral clock gating, wake-up controller.
- RISC-V Debug Module, JTAG, hardware breakpoints, watchpoints, trace buffer, performance counters.

### Integration Notes

- The full subsystem is designed to integrate cleanly with the AXI4-Lite interconnect.
- The RTL is intended to be modular, synthesizable, and suitable for Synopsys Design Compiler.
- This repo focuses on a complete chip-level integration with a top-level wrapper, verification bench, and synthesis/constraint support.

---

## Repository Structure

The repository is organized into a small set of directories that separate documentation, RTL sources, verification, and synthesis outputs.

```text
riscv/
├── LICENSE
├── README.md
├── docs/                          # Additional documentation and notes
├── outputs/                       # Generated output artifacts
│   ├── riscv_sim.vcd              # Simulation waveform output
│   └── synopsys_outputs/          # Additional Synopsys-related outputs
├── reports/                       # Synthesis and analysis summaries
│   ├── area.txt
│   ├── des.txt
│   ├── power.txt
│   ├── qor.txt
│   └── timing.txt
├── rtl/                           # Main RTL source tree
│   ├── adc_ps.v
│   ├── brk_ps.v
│   ├── can_ps.v
│   ├── clk_ps.v
│   ├── core_cm.v
│   ├── crypto_ps.v
│   ├── ctrl_cm.v
│   ├── dbg_ps.v
│   ├── dma_ps.v
│   ├── dsp_d.v
│   ├── dspc_d.v
│   ├── dspkg_d.v
│   ├── gpio_ps.v
│   ├── i2c_ps.v
│   ├── i2c2_ps.v
│   ├── jtag_ps.v
│   ├── mac_d.v
│   ├── mem_bank.v
│   ├── mem_cm.v
│   ├── perf_ps.v
│   ├── pkg_cm.v
│   ├── plic_ps.v
│   ├── pmp_ps.v
│   ├── pwm_ps.v
│   ├── qspi_ps.v
│   ├── sec_ps.v
│   ├── simd_d.v
│   ├── soc_top_ps.v
│   ├── spi_ps.v
│   ├── spi2_ps.v
│   ├── tdma_a.v
│   ├── tpu_a.v
│   ├── tpupkg_a.v
│   ├── trace_ps.v
│   ├── tsa_a.v
│   ├── uart_ps.v
│   ├── uart2_ps.v
│   ├── usb_ps.v
│   ├── xbar_cm.v
│   └── xt_a.v
├── scripts/                       # Synthesis automation scripts
│   └── dc.tcl
├── sdc/                           # Timing constraints for synthesis
│   └── rv64_ai_soc_top.sdc
└── tb/                            # Verification testbench
    └── tb.v
```

### What each part is for

- `README.md` provides the project overview, setup notes, and contributor information.
- `rtl/` contains the Verilog RTL source files. These are grouped by role:
  - `*_cm.v` files are core and memory related.
  - `*_d.v` files cover DSP functionality.
  - `*_a.v` files represent AI and tensor-oriented accelerator blocks.
  - `*_ps.v` files cover peripherals, security logic, and the SoC wrapper.
- `tb/` contains the primary testbench used to exercise the top-level SoC.
- `scripts/` stores synthesis automation commands.
- `sdc/` holds timing constraints for synthesis and timing analysis.
- `reports/` stores generated summaries such as area, power, QoR, and timing data.
- `outputs/` contains waveform and other generated output artifacts.

---

## Simulation and Verification

The project includes a consolidated verification flow centered on the testbench in `tb/tb.v`.

### Current Verification Flow

The simulation flow can be run with:

```sh
iverilog -g2001 -o sim_soc.out rtl/*.v tb/tb.v
vvp sim_soc.out
```

### Current Status

At the time of this update, the simulation flow is still failing during elaboration due to issues in `rtl/mem_cm.v` related to memory-bank output port handling. This is a useful next debugging target and should be resolved before the project can be considered fully verified in this environment.

---

## Synthesis and Handoff Flow

The repository is also prepared for a Synopsys Design Compiler handoff flow.

### Key Files

- Synthesis script: `scripts/dc.tcl`
- Constraint file: `sdc/rv64_ai_soc_top.sdc`
- Reports: `reports/area.txt`, `reports/des.txt`, `reports/power.txt`, `reports/qor.txt`, `reports/timing.txt`
- Waveform output: `outputs/riscv_sim.vcd`

### Report Snapshot

The available reports show that the design was evaluated with a 10 ns target clock and that the latest QoR summary reported timing closure for the design under the provided setup.

---

## Getting Started

To begin working with the project:

1. Open the RTL sources in `rtl/`.
2. Use `tb/tb.v` as the main simulation entry point.
3. For synthesis, run the flow from a workstation with Synopsys Design Compiler:

```sh
cd /path/to/riscv
dc_shell -f scripts/dc.tcl
```

> The synthesis script may need environment or path adjustments depending on your local setup.

---

## Team and Contributors

This project was developed as a team effort. The section below is ready to be filled with your teammates and their GitHub profiles so that the project history, ownership, and collaboration are easy to track.


- [Asron](https://github.com/asronal)
- [Dharani N](https://github.com/natarajandharani13-afk)
- [Abhishiek D](https://github.com/AbhishiekDevanand)
- [Ganghesh K B](https://github.com/gangheshkb-netizen)

---

## License

This repository contains RTL source code intended for simulation, design exploration, and synthesis-focused handoff. Please refer to the repository license for distribution and reuse terms.
