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

compilation_procedural: rtl/vortex.v
	@cd build/zoix && \
	zoix ../../rtl/generated_vortex.v ../../rtl/strobe.sv +top+Vortex+strobe +sv

build/zoix/sim.zdb: build/zoix/zoix.sim build/simulation/dump.evcd
	@cd build/zoix && \
	./zoix.sim +vcd+file+../simulation/dump.evcd +vcd+dut+Vortex+Testbench.vortex

fault_simulation: build/zoix/sim.zdb scripts/fsim_evcd.fmsh scripts/faults.sff
	@cd build/zoix && \
	fmsh -load ../../scripts/fsim_evcd.fmsh

src/generated_vortex.v:
	vortex/hw/scripts/sv2v.sh -tVortex \
		-DFPU_FPNEW \
		-I/vortex/hw/rtl/cache \
		-I/vortex/hw/rtl/core \
		-I/vortex/hw/rtl/fpu \
		-I/vortex/hw/rtl/interfaces \
		-I/vortex/hw/rtl/libs \
		-I/vortex/hw/rtl/mem \
		-I/vortex/hw/rtl \
		-I/vortex/third_party/cvfpu/src \
		-I/vortex/third_party/cvfpu/src/common_cells/include \
		-I/vortex/third_party/cvfpu/src/common_cells/src \
		-I/vortex/third_party/cvfpu/src/fpu_div_sqrt_mvp/hdl \
		-DPLATFORM_MEMORY_DATA_WIDTH=32	\
		-DPLATFORM_MEMORY_ADDR_WIDTH=16	\
		-o../src/generated_vortex.v

clean:
	@rm -rf build
	@mkdir -p build/simulation
	@mkdir -p build/zoix
	@mkdir -p build/logs