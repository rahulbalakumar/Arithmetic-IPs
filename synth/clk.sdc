# Same tight target for every run, so every design is pushed equally hard.
# Nothing will meet 4 ns (250 MHz) on this device: read Fmax, not slack.
create_clock -name clk -period 4 [get_ports clk]
