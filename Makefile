all: fault_simulation

synthesis: src/generated_vortex.v
stimuli: /build/simulation/dump.evcd
compilation: build/zoix/zoix.sim
simulation: build/zoix/sim.zdb

USE_GENERATED ?= 0
PLATFORM_MEMORY_DATA_WIDTH ?= 32
PLATFORM_MEMORY_ADDR_WIDTH ?= 16

ifeq ($(USE_GENERATED),1)
    VORTEX_SRC = rtl/generated_vortex.v
else
    VORTEX_SRC = rtl/vortex.v
endif

RTL_SRCS = \
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
	-DPLATFORM_MEMORY_DATA_WIDTH=$(PLATFORM_MEMORY_DATA_WIDTH) \
	-DPLATFORM_MEMORY_ADDR_WIDTH=$(PLATFORM_MEMORY_ADDR_WIDTH)


rtl/generated_vortex.v:
	vortex/hw/scripts/sv2v.sh -tVortex \
		-DFPU_FPNEW \
		$(RTL_SRCS) \
		-o../src/generated_vortex.v

build/zoix/zoix.sim: $(VORTEX_SRC)
	@cd build/zoix && \
	zoix ../../$(VORTEX_SRC) ../../rtl/strobe.sv +top+Vortex+strobe +sv

build/simulation/dump.evcd: $(VORTEX_SRC) rtl/testbench.sv scripts/modelsim.tcl
	@cd build/simulation && \
	vsim -c -do ../../scripts/modelsim.tcl

build/zoix/sim.zdb: build/zoix/zoix.sim /build/simulation/dump.evcd
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