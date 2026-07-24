# RV64-AI-MCU SoC synthesis constraints
# Synopsys Design Compiler / IC Compiler II friendly

##################################################################
# General timing
##################################################################
create_clock -name clk -period 10.0 -waveform {0 5} [get_ports clk]

set all_nonclk_inputs [remove_from_collection [all_inputs] [get_ports clk]]
set all_nonclk_inputs [remove_from_collection $all_nonclk_inputs [get_ports rst_n]]
set_input_delay 0.5 -clock clk $all_nonclk_inputs

set_output_delay 0.5 -clock clk [all_outputs]

# Treat reset as asynchronous and exclude it from clocked-path timing.
set_false_path -from [get_ports rst_n] -to [all_registers]

##################################################################
# Drive and load
##################################################################
set_driving_cell -lib_cell BUFFD1 $all_nonclk_inputs
set_load 0.05 [all_outputs]

##################################################################
# Compile strategy
##################################################################
set_max_transition 0.5 [current_design]
set_max_fanout 32 [current_design]
set_max_capacitance 0.2 [current_design]

##################################################################
# Do not optimize away outputs
##################################################################
set_dont_touch [get_ports clk]
