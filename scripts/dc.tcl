# DC synthesis script for RV64-AI-MCU
# Usage: dc_shell -f scripts/dc.tcl

set app_var [info exists env(DC_SHELL_MODE)]
set DESIGN_NAME "rv64_ai_soc_top"
set RTL_DIR     "../rtl"
set SDC_FILE    "../sdc/rv64_ai_soc_top.sdc"
set WORK_DIR    "./work"
set LOG_DIR     "./logs"

file mkdir $WORK_DIR
file mkdir $LOG_DIR

set search_path [concat $search_path $RTL_DIR]
set target_library     ""
set link_library       "*"

analyze -format verilog [glob -directory $RTL_DIR *.v]

elaborate $DESIGN_NAME

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
