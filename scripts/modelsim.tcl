# ModelSim Script to Compile and Simulate Testbench


transcript off

# Set the working library
vlib work
vmap work work

# Compile Design Files
vlog -sv ../../rtl/vortex.v
vlog -sv ../../rtl/testbench.sv

# Load the Simulation
vsim -voptargs="+acc" Testbench
# Dump eVCD
vcd dumpports -file dump.evcd Testbench/vortex/*

# Run Simulation
run 10000000


quit 