# RV64-AI-MCU RTL Handoff Repository

## System Overview

The **RV64-AI-MCU** repository contains a cleaned, structured, flat Verilog RTL codebase for a 64-bit RISC-V Microcontroller Unit (MCU) System-on-Chip (SoC). The architecture integrates a high-performance 64-bit RISC-V core with dedicated hardware accelerators for AI/Tensor computations, Digital Signal Processing (DSP) execution pipelines, hardware security extensions, and a comprehensive peripheral suite.

This repository is optimized for front-end synthesis handoff to **Synopsys Design Compiler** (`dc_shell`). All hardware description files have been validated for clean syntax, modular hierarchy, and simulation capability.

---

## Architecture & System Features

The system architecture is categorized into four primary design domains:

### 1. CPU Core & System Control Subsystem (`*_cm.v`)
* **64-bit RISC-V Core (`core_cm.v`)**: Parameterized execution engine featuring configurable register file depths, Branch Target Buffer (BTB), Return Address Stack (RAS), and performance monitoring counters.
* **Control & Execution (`ctrl_cm.v`)**: Central system controller handling pipeline coordination, decode logic, and interrupt trap vector routing.
* **Memory Subsystem (`mem_cm.v`)**: Integrated memory controller managing instruction/data bus transactions and multi-bank SRAM interfaces.
* **System Crossbar Interconnect (`xbar_cm.v`)**: High-bandwidth bus matrix facilitating concurrent master/slave routing across memory and peripherals.

### 2. Digital Signal Processing (DSP) Subsystem (`*_d.v`)
* **DSP Processing Unit (`dsp_d.v`, `dspc_d.v`)**: Dedicated hardware acceleration for fixed-point math operations, filtering algorithms, and matrix operations.
* **Multiply-Accumulate Engine (`mac_d.v`)**: Single-cycle and multi-cycle hardware MAC blocks tailored for signal processing workloads.
* **SIMD Engine (`simd_d.v`)**: Single Instruction Multiple Data execution pipeline for vector processing.

### 3. AI & Tensor Acceleration Subsystem (`*_a.v`)
* **Tensor Processing Unit (`tpu_a.v`)**: Systolic array matrix math engine for neural network inference acceleration.
* **Tensor Stream Accelerator (`tsa_a.v`)**: High-throughput streaming module for continuous weight and activation data delivery.
* **Tensor DMA (`tdma_a.v`)**: Autonomous Direct Memory Access engine dedicated to high-bandwidth tensor transfer operations without CPU intervention.
* **Custom AI Extensions (`xt_a.v`)**: Custom ISA extension interfaces for domain-specific AI instruction execution.

### 4. Peripherals & Security Subsystem (`*_ps.v`)
* **SoC Top Wrapper (`soc_top_ps.v`)**: `rv64_ai_soc_top` top-level integration wrapper exposing external interface pins and bus topologies.
* **Security & Crypto (`sec_ps.v`, `crypto_ps.v`, `pmp_ps.v`)**: Hardware Root-of-Trust, cryptographic coprocessor (AES/SHA support), and Physical Memory Protection (PMP) units.
* **Interrupt & Debug Management (`plic_ps.v`, `dbg_ps.v`, `trace_ps.v`, `jtag_ps.v`, `brk_ps.v`)**: RISC-V compliant Platform-Level Interrupt Controller (PLIC), JTAG debug interface, hardware execution tracing, and breakpoint controllers.
* **Peripheral Suite**: Multi-channel UART (`uart_ps.v`, `uart2_ps.v`), SPI/QSPI (`spi_ps.v`, `spi2_ps.v`, `qspi_ps.v`), I2C (`i2c_ps.v`, `i2c2_ps.v`), CAN bus (`can_ps.v`), USB 2.0 (`usb_ps.v`), GPIO (`gpio_ps.v`), PWM (`pwm_ps.v`), ADC interface (`adc_ps.v`), and system clock/reset management (`clk_ps.v`).

---

## Directory Organization

```
riscv/
├── rtl/                        Flat Verilog-2001 source files
│   ├── *_cm.v                  CPU core, memory controller, crossbar, and packages
│   ├── *_d.v                   DSP blocks, MAC pipelines, and SIMD units
│   ├── *_a.v                   AI acceleration engines, TPU core, and TDMA
│   └── *_ps.v                  Peripherals, PLIC, Security, and SoC top wrapper
├── tb/                         Regression and verification testbenches
│   ├── mc_tb.v                 Memory Controller testbench suite
│   ├── rv64_ai_core_params_tb.v Parameterized Core verification testbench
│   └── rv64_ai_soc_top_tb.v    Top-level SoC integration testbench
├── scripts/                    Synthesis automation scripts
│   └── dc.tcl                  Synopsys Design Compiler entry script
└── sdc/                        Timing and design constraints
    └── rv64_ai_soc_top.sdc     Top-level SDC template for synthesis
```

---

## Module Naming Taxonomy

To maintain modularity and structural clarity across the flat RTL tree, files follow a standardized, type-based suffix convention:

| Suffix | Domain Classification | Description & Examples |
| :--- | :--- | :--- |
| `*_cm.v` | Core & Memory | CPU core logic, control unit, interconnect crossbar, memory interfaces (`core_cm.v`, `xbar_cm.v`) |
| `*_d.v` | DSP Hardware | Multiply-accumulate units, SIMD engines, DSP controllers (`dsp_d.v`, `mac_d.v`, `simd_d.v`) |
| `*_a.v` | AI / TPU Accelerators | Tensor processing units, stream engines, TDMA controllers (`tpu_a.v`, `tsa_a.v`, `tdma_a.v`) |
| `*_ps.v` | Peripherals & Security | SoC top wrapper, security modules, bus peripherals (`soc_ps.v`, `plic_ps.v`, `crypto_ps.v`) |

---

## RTL Source Inventory (`rtl/`)

| File Name | Functional Description | Domain |
| :--- | :--- | :--- |
| `core_cm.v` | Parameterized 64-bit RISC-V CPU core implementation | Core & Memory |
| `ctrl_cm.v` | System control and execution pipeline manager | Core & Memory |
| `mem_cm.v` | High-performance memory controller interface | Core & Memory |
| `xbar_cm.v` | High-bandwidth crossbar bus matrix | Core & Memory |
| `pkg_cm.v` | Core configuration parameters and package definitions | Core & Memory |
| `dsp_d.v` | Digital Signal Processing (DSP) engine core | DSP |
| `dspc_d.v` | DSP execution pipeline controller | DSP |
| `mac_d.v` | Hardware Multiply-Accumulate (MAC) pipeline | DSP |
| `simd_d.v` | SIMD vector processing unit | DSP |
| `dspkg_d.v` | DSP parameter definitions | DSP |
| `tpu_a.v` | Tensor Processing Unit (TPU) matrix engine | AI Accelerator |
| `tsa_a.v` | Tensor Stream Accelerator data delivery unit | AI Accelerator |
| `tdma_a.v` | Tensor Direct Memory Access (TDMA) controller | AI Accelerator |
| `xt_a.v` | Custom ISA extension interface for AI operations | AI Accelerator |
| `tpupkg_a.v` | TPU subsystem package parameters | AI Accelerator |
| `soc_top_ps.v` | Top-level SoC peripheral wrapper (`rv64_ai_soc_top`) | Peripheral / SoC |
| `plic_ps.v` | Platform-Level Interrupt Controller (PLIC) | Security / System |
| `pmp_ps.v` | Physical Memory Protection (PMP) unit | Security / System |
| `sec_ps.v` | Hardware Root-of-Trust security controller | Security / System |
| `crypto_ps.v` | Hardware cryptographic accelerator (AES/SHA) | Security / System |
| `dma_ps.v` | General-purpose Direct Memory Access controller | System Peripheral |
| `clk_ps.v` | Clock distribution and reset management | System Peripheral |
| `uart_ps.v`, `uart2_ps.v` | Dual Universal Asynchronous Receiver-Transmitters | Communication |
| `spi_ps.v`, `spi2_ps.v` | Dual Serial Peripheral Interface (SPI) controllers | Communication |
| `qspi_ps.v` | Quad Serial Peripheral Interface (QSPI) flash controller | Communication |
| `i2c_ps.v`, `i2c2_ps.v` | Dual Inter-Integrated Circuit (I2C) controllers | Communication |
| `can_ps.v` | Controller Area Network (CAN) interface unit | Communication |
| `usb_ps.v` | USB 2.0 interface controller | Communication |
| `gpio_ps.v` | General-Purpose Input/Output controller | Peripheral |
| `pwm_ps.v` | Pulse-Width Modulation timer generator | Peripheral |
| `adc_ps.v` | Analog-to-Digital Converter interface block | Peripheral |
| `dbg_ps.v`, `jtag_ps.v` | Debug interface and JTAG TAP controller | Debug & Trace |
| `trace_ps.v` | Real-time hardware execution tracing module | Debug & Trace |
| `perf_ps.v` | Performance monitoring counters unit | Debug & Trace |
| `brk_ps.v` | Hardware breakpoint unit | Debug & Trace |

---

## Verification & Simulation Status

The RTL design tree has undergone functional verification using **Icarus Verilog (`iverilog`)**. All testbenches report zero failures under regression execution.

### Verification Summary

| Testbench | Scope / Coverage Target | Status |
| :--- | :--- | :--- |
| `tb/mc_tb.v` | Memory controller transaction, burst, and boundary checks | 3 Passed, 0 Failed |
| `tb/rv64_ai_soc_top_tb.v` | Top-level SoC integration, AXI-Lite read/write & GPIO interface | 9 Passed, 0 Failed |
| `tb/rv64_ai_core_params_tb.v` | Parameterized core reset vector and configuration checks | 1 Passed, 0 Failed |

### Running Simulations

To execute functional simulations using `iverilog` and `vvp`:

1. **Top-Level SoC Verification**:
   ```sh
   iverilog -g2001 -o sim_soc.out rtl/*.v tb/rv64_ai_soc_top_tb.v
   vvp sim_soc.out
   ```

2. **Memory Controller Verification**:
   ```sh
   iverilog -g2001 -o sim_mc.out rtl/*.v tb/mc_tb.v
   vvp sim_mc.out
   ```

3. **Parameterized Core Verification**:
   ```sh
   iverilog -g2001 -o sim_core.out rtl/*.v tb/rv64_ai_core_params_tb.v
   vvp sim_core.out
   ```

---

## Synopsys Design Compiler Handoff Flow

This workspace contains all necessary scripts and timing constraints required for ASIC front-end logic synthesis using **Synopsys Design Compiler** (`dc_shell`).

### Handoff Parameters

* **Top-Level Target Module**: `rv64_ai_soc_top`
* **Entry Script**: `scripts/dc.tcl`
* **Design Constraints**: `sdc/rv64_ai_soc_top.sdc`

### SDC Timing Constraints Overview

The top-level SDC file (`sdc/rv64_ai_soc_top.sdc`) specifies the target operating conditions:

```tcl
create_clock -name clk -period 10.0 [get_ports clk]   # Target Frequency: 100 MHz
set_input_delay  0.5 -clock clk [all_inputs]
set_output_delay 0.5 -clock clk [all_outputs]

set_driving_cell -lib_cell BUFFD1 [all_inputs]
set_load 0.05 [all_outputs]

set_max_transition 0.5 [current_design]
set_max_fanout 32 [current_design]
set_max_capacitance 0.2 [current_design]
```

### Executing Synthesis on Lab Workstation

Synthesis must be executed on a machine equipped with Synopsys Design Compiler (`dc_shell` environment).

Navigate to the repository root directory and invoke `dc_shell`:

```sh
cd /path/to/riscv
dc_shell -f scripts/dc.tcl
```

### Synthesis Outputs & Deliverables

Upon completion, `dc.tcl` automatically generates the following target artifacts:

```
riscv/
├── work/
│   ├── rv64_ai_soc_top.ddc     Synopsys unmapped/mapped database file
│   └── rv64_ai_soc_top.v       Synthesized gate-level netlist
└── logs/
    ├── rv64_ai_soc_top_area.rpt   Area utilization report
    ├── rv64_ai_soc_top_timing.rpt Timing slack and critical path report
    ├── rv64_ai_soc_top_power.rpt  Power consumption estimate
    └── rv64_ai_soc_top_qor.rpt    Quality of Results (QoR) summary
```

---

## License & Compliance

This repository contains front-end RTL source code intended for simulation, design exploration, and ASIC synthesis. Refer to local institution or project licensing guidelines for distribution and reuse policies.
