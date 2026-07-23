# RV64-AI-MCU SoC synthesis constraints template
# Synopsys Design Compiler / IC Compiler II friendly

##################################################################
# General timing
##################################################################
create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay  0.5 -clock clk [all_inputs]
set_output_delay 0.5 -clock clk [all_outputs]

##################################################################
# Drive and load
##################################################################
set_driving_cell -lib_cell BUFFD1 [all_inputs]
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
