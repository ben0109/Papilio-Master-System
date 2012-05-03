MEM_PATH:=~/prog/vhdl/master_system/bootloader
ISE_PATH:=/home/ben/prog/Xilinx/13.1/ISE_DS/ISE
DATA2MEM:=$(ISE_PATH)/bin/lin/data2mem

load: sms_vga_final.bit
	sudo papilio-prog -v -f $<

TARGETS := sms_vga sms_tv

%_final.bit: %.bit sms_bd.bmm $(MEM_PATH)/all.mem
	$(DATA2MEM) -bm sms_bd.bmm -bd $(MEM_PATH)/all.mem -bt $*.bit -o b $*_final.bit

# remove Make's built-in rules
.SUFFIXES:

.PHONY: load clean

DUT      := xc6slx9tqg144-3
HDL_PATH := src
SRCS     := $(wildcard $(HDL_PATH)/*.$(VHDL_EXT))

# Tools can run in different contextual/verbosity modes:
# standalone (empty string) or "-intstyle ise|xflow|silent"
MODE  := 

#-----------------------------------------
# cleaning targets
#-----------------------------------------

clean:
	rm -I $(TARGETS:%=%.ngc) $(TARGETS:%=%.ngd) $(TARGETS:%=%._map.ncd) $(TARGETS:%=%.pcf) $(TARGETS:%=%.ncd) $(TARGETS:%=%.bit) $(TARGETS:%=%.twr)


# synthesis: generate netlist
%.ngc: %.xst %.prj $(SRCS)
	xst $(MODE) -ifn $*.xst
	@if test ! -f $*.ngc; then exit 2; fi

# ngdbuild: convert netlist to Xilinx format
%.ngd: %.ngc src/%.ucf
	ngdbuild $(MODE) -p $(DUT) -uc src/$*.ucf -bm sms.bmm $*.ngc $*.ngd

# map: place/route design
%_map.ncd %.pcf: %.ngd
	map $(MODE) -w $*.ngd -p $(DUT) -o $*_map.ncd $*.pcf

# par: route design
%.ncd: %_map.ncd %.pcf
	par $(MODE) -w $*_map.ncd $*.ncd $*.pcf

# bitgen: generate bitstream
%.bit: %.ncd
	bitgen $(MODE) -w $*.ncd

# trce: timing analysis
%.twr: %.ncd %.pcf
	trce $(MODE) $*.ncd $*.pcf -xml $*.twx -o $*.twr $(TIM_OPT)

