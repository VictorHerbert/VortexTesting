all: fault_simulation

stimuli: dump.evcd
compilation: build/zoix/zoix.sim
simulation: build/zoix/sim.zdb

build/simulation/dump.evcd: rtl/vortex.v rtl/testbench.sv scripts/modelsim.tcl
	@cd build/simulation && \
	vsim -c -do ../../scripts/modelsim.tcl

build/zoix/zoix.sim: rtl/vortex.v
	@cd build/zoix && \
	zoix ../../rtl/vortex.v ../../rtl/strobe.sv +top+Vortex+strobe +sv

build/zoix/sim.zdb: build/zoix/zoix.sim build/simulation/dump.evcd
	@cd build/zoix && \
	./zoix.sim +vcd+file+../simulation/dump.evcd +vcd+dut+Vortex+Testbench.vortex

fault_simulation: build/zoix/sim.zdb scripts/fsim_evcd.fmsh scripts/faults.sff
	@cd build/zoix && \
	fmsh -load ../../scripts/fsim_evcd.fmsh

clean:
	@rm -rf build
	@mkdir -p build/simulation
	@mkdir -p build/zoix
	@mkdir -p build/logs