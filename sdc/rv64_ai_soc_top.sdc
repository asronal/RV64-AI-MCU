# RV64 AI SoC top-level timing constraints
# Primary clock
create_clock -name clk -period 10.000 [get_ports clk]

# No I/O delay assumptions in this generic flow
set_input_delay -clock clk -max 0 [get_ports -regexp "^(axil_.*|gpio_io.*)$"]
set_output_delay -clock clk -max 0 [get_ports -regexp "^(axil_.*|gpio_io.*)$"]

# Reset is asynchronous and not timing-constrained as a clock path
set_false_path -from [get_ports rst_n]
set_false_path -to [get_ports rst_n]

# Allow some clock uncertainty for this generic setup
set_clock_uncertainty 0.050 [get_clocks clk]
