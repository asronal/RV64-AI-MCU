# DC synthesis script for RV64-AI-MCU
# Usage: dc_shell -f scripts/dc.tcl

set app_var [info exists env(DC_SHELL_MODE)]
set DESIGN_NAME "rv64_ai_soc_top"
set RTL_DIR     "../inputs"
set SDC_FILE    "../sdc/rv64_ai_soc_top.sdc"
set WORK_DIR    "./work"
set LOG_DIR     "./logs"

file mkdir $WORK_DIR
file mkdir $LOG_DIR

set search_path [concat $search_path $RTL_DIR]
set target_library     ""
set link_library       "*"

set RTL_FILES [list \
  ../inputs/adc_ps.v \
  ../inputs/brk_ps.v \
  ../inputs/can_ps.v \
  ../inputs/clk_ps.v \
  ../inputs/core_cm.v \
  ../inputs/crypto_ps.v \
  ../inputs/ctrl_cm.v \
  ../inputs/dbg_ps.v \
  ../inputs/dma_ps.v \
  ../inputs/dsp_d.v \
  ../inputs/dspc_d.v \
  ../inputs/dspkg_d.v \
  ../inputs/gpio_ps.v \
  ../inputs/i2c_ps.v \
  ../inputs/i2c2_ps.v \
  ../inputs/jtag_ps.v \
  ../inputs/mac_d.v \
  ../inputs/mem_cm.v \
  ../inputs/perf_ps.v \
  ../inputs/pkg_cm.v \
  ../inputs/plic_ps.v \
  ../inputs/pmp_ps.v \
  ../inputs/pwm_ps.v \
  ../inputs/qspi_ps.v \
  ../inputs/sec_ps.v \
  ../inputs/simd_d.v \
  ../inputs/soc_ps.v \
  ../inputs/spi_ps.v \
  ../inputs/spi2_ps.v \
  ../inputs/tdma_a.v \
  ../inputs/tpu_a.v \
  ../inputs/tpupkg_a.v \
  ../inputs/trace_ps.v \
  ../inputs/tsa_a.v \
  ../inputs/uart_ps.v \
  ../inputs/uart2_ps.v \
  ../inputs/usb_ps.v \
  ../inputs/xbar_cm.v \
  ../inputs/xt_a.v \
]

analyze -format verilog -library work -autoread $RTL_FILES
elaborate $DESIGN_NAME
link

if { [file exists $SDC_FILE] } {
  source $SDC_FILE
} else {
  puts "Warning: SDC file not found: $SDC_FILE"
}

compile_ultra -gate_clock

write -format ddc -hierarchy -output "$WORK_DIR/${DESIGN_NAME}.ddc"
write -format verilog -hierarchy -output "$WORK_DIR/${DESIGN_NAME}.v"
report_area > "$LOG_DIR/${DESIGN_NAME}_area.rpt"
report_timing > "$LOG_DIR/${DESIGN_NAME}_timing.rpt"
report_power > "$LOG_DIR/${DESIGN_NAME}_power.rpt"
report_qor > "$LOG_DIR/${DESIGN_NAME}_qor.rpt"

puts "DC synthesis completed for $DESIGN_NAME"
