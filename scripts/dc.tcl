# DC synthesis script for RV64-AI-MCU
# Usage: dc_shell -f scripts/dc.tcl

set SCRIPT_DIR [file dirname [info script]]
set REPO_ROOT  [file normalize [file join $SCRIPT_DIR ..]]
set DESIGN_NAME "rv64_ai_soc_top"
set RTL_DIR     [file join $REPO_ROOT "rtl"]
set SDC_FILE    [file join $REPO_ROOT "sdc" "rv64_ai_soc_top.sdc"]
set WORK_DIR    [file join $REPO_ROOT "work"]
set LOG_DIR     [file join $REPO_ROOT "logs"]

file mkdir $WORK_DIR
file mkdir $LOG_DIR

set search_path [concat $search_path $RTL_DIR]
set target_library ""
set link_library "*"

set RTL_FILES [list \
  [file join $RTL_DIR "adc_ps.v"] \
  [file join $RTL_DIR "brk_ps.v"] \
  [file join $RTL_DIR "can_ps.v"] \
  [file join $RTL_DIR "clk_ps.v"] \
  [file join $RTL_DIR "core_cm.v"] \
  [file join $RTL_DIR "crypto_ps.v"] \
  [file join $RTL_DIR "ctrl_cm.v"] \
  [file join $RTL_DIR "dbg_ps.v"] \
  [file join $RTL_DIR "dma_ps.v"] \
  [file join $RTL_DIR "dsp_d.v"] \
  [file join $RTL_DIR "dspc_d.v"] \
  [file join $RTL_DIR "dspkg_d.v"] \
  [file join $RTL_DIR "gpio_ps.v"] \
  [file join $RTL_DIR "i2c_ps.v"] \
  [file join $RTL_DIR "i2c2_ps.v"] \
  [file join $RTL_DIR "jtag_ps.v"] \
  [file join $RTL_DIR "mac_d.v"] \
  [file join $RTL_DIR "mem_bank.v"] \
  [file join $RTL_DIR "mem_cm.v"] \
  [file join $RTL_DIR "perf_ps.v"] \
  [file join $RTL_DIR "pkg_cm.v"] \
  [file join $RTL_DIR "plic_ps.v"] \
  [file join $RTL_DIR "pmp_ps.v"] \
  [file join $RTL_DIR "pwm_ps.v"] \
  [file join $RTL_DIR "qspi_ps.v"] \
  [file join $RTL_DIR "sec_ps.v"] \
  [file join $RTL_DIR "simd_d.v"] \
  [file join $RTL_DIR "soc_top_ps.v"] \
  [file join $RTL_DIR "spi_ps.v"] \
  [file join $RTL_DIR "spi2_ps.v"] \
  [file join $RTL_DIR "tdma_a.v"] \
  [file join $RTL_DIR "tpu_a.v"] \
  [file join $RTL_DIR "tpupkg_a.v"] \
  [file join $RTL_DIR "trace_ps.v"] \
  [file join $RTL_DIR "tsa_a.v"] \
  [file join $RTL_DIR "uart_ps.v"] \
  [file join $RTL_DIR "uart2_ps.v"] \
  [file join $RTL_DIR "usb_ps.v"] \
  [file join $RTL_DIR "xbar_cm.v"] \
  [file join $RTL_DIR "xt_a.v"] \
]

foreach rtl_file $RTL_FILES {
  if { ![file exists $rtl_file] } {
    error "Missing RTL source: $rtl_file"
  }
}

analyze -format verilog -library work -autoread $RTL_FILES
elaborate $DESIGN_NAME
link

if { [file exists $SDC_FILE] } {
  source $SDC_FILE
} else {
  puts "Warning: SDC file not found: $SDC_FILE"
}

compile_ultra -gate_clock

write -format ddc -hierarchy -output [file join $WORK_DIR "${DESIGN_NAME}.ddc"]
write -format verilog -hierarchy -output [file join $WORK_DIR "${DESIGN_NAME}.v"]
report_area > [file join $LOG_DIR "${DESIGN_NAME}_area.rpt"]
report_timing > [file join $LOG_DIR "${DESIGN_NAME}_timing.rpt"]
report_power > [file join $LOG_DIR "${DESIGN_NAME}_power.rpt"]
report_qor > [file join $LOG_DIR "${DESIGN_NAME}_qor.rpt"]

puts "DC synthesis completed for $DESIGN_NAME"
