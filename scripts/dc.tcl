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

set RTL_FILES [concat \
  [lsort [glob -nocomplain -directory $RTL_DIR "rv64_ai_*.v"]] \
  [list \
    [file join $RTL_DIR "pkg_cm.v"] \
    [file join $RTL_DIR "mem_bank.v"] \
    [file join $RTL_DIR "mem_cm.v"] \
  ] \
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
