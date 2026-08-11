# Set search path 
set script_dir [file dirname [info script]]
set syn_root [file normalize [file join $script_dir ..]]
set inputs_dir [file normalize [file join $syn_root inputs]]
set search_path $inputs_dir

set link_library {saed32hvt_ss0p75v125c.db saed32rvt_ss0p75v125c.db saed32sramlp_ss0p75v125c_i0p75v.db}      
set target_library { saed32hvt_ss0p75v125c.db saed32rvt_ss0p75v125c.db saed32sramlp_ss0p75v125c_i0p75v.db}

# determine the script directory and input file directory
# set script_dir [file dirname [info script]]
# set syn_root [file normalize [file join $script_dir ..]]
# set inputs_dir [file normalize [file join $syn_root inputs]]

# read verilog (RTL) 
set rtl_files [list \
    [file join $inputs_dir dspkg_d.v] \
    [file join $inputs_dir pkg_cm.v] \
    [file join $inputs_dir rv64_ai_adc_usb_can.v] \
    [file join $inputs_dir rv64_ai_axi4lite_crossbar.v] \
    [file join $inputs_dir rv64_ai_breakpoint_unit.v] \
    [file join $inputs_dir rv64_ai_can_fd.v] \
    [file join $inputs_dir rv64_ai_clock_sleep_wakeup.v] \
    [file join $inputs_dir rv64_ai_control_unit.v] \
    [file join $inputs_dir rv64_ai_core.v] \
    [file join $inputs_dir rv64_ai_crypto_engine.v] \
    [file join $inputs_dir rv64_ai_debug_module.v] \
    [file join $inputs_dir rv64_ai_dma_sg.v] \
    [file join $inputs_dir rv64_ai_dsp_coprocessor.v] \
    [file join $inputs_dir rv64_ai_dsp_top.v] \
    [file join $inputs_dir rv64_ai_gpio.v] \
    [file join $inputs_dir rv64_ai_i2c.v] \
    [file join $inputs_dir rv64_ai_i2c2.v] \
    [file join $inputs_dir rv64_ai_jtag_debug.v] \
    [file join $inputs_dir rv64_ai_mac_engine.v] \
    [file join $inputs_dir rv64_ai_mem_bank.v] \
    [file join $inputs_dir rv64_ai_memory_subsystem.v] \
    [file join $inputs_dir rv64_ai_perf_counters.v] \
    [file join $inputs_dir rv64_ai_plic_clint_debug.v] \
    [file join $inputs_dir rv64_ai_pmp.v] \
    [file join $inputs_dir rv64_ai_pwm_timer_wdt_rtc.v] \
    [file join $inputs_dir rv64_ai_qspi_psram_dma.v] \
    [file join $inputs_dir rv64_ai_security_block.v] \
    [file join $inputs_dir rv64_ai_simd_engine.v] \
    [file join $inputs_dir rv64_ai_soc_top.v] \
    [file join $inputs_dir rv64_ai_spi.v] \
    [file join $inputs_dir rv64_ai_spi2.v] \
    [file join $inputs_dir rv64_ai_tpu_dma.v] \
    [file join $inputs_dir rv64_ai_tpu_systolic_array.v] \
    [file join $inputs_dir rv64_ai_tpu_top.v] \
    [file join $inputs_dir rv64_ai_trace_buffer.v] \
    [file join $inputs_dir rv64_ai_uart.v] \
    [file join $inputs_dir rv64_ai_uart2.v] \
    [file join $inputs_dir rv64_ai_usb_fs.v] \
    [file join $inputs_dir rv64_ai_xtensor_extension.v] \
    [file join $inputs_dir tpupkg_a.v]]

analyze -library work -format verilog -define SYNTHESIS -top rv64_ai_soc_top -autoread $rtl_files

# Elaborate the design 
elaborate rv64_ai_soc_top -library work

# Read the timing constraints (.sdc)
source [file join $inputs_dir rv64_ai_soc_top.sdc]

# Make sure the output directory exists
set output_dir [file join $syn_root outputs]
file mkdir $output_dir

# Synthesize the design using the supported compile command
compile

# Dump verilog
write_file -format verilog -hierarchy -output [file join $output_dir gprs_top.v]

