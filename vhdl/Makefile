MEM_PATH:=~/prog/vhdl/master_system/bootloader
ISE_PATH:=/home/ben/prog/Xilinx/13.1/ISE_DS/ISE
DATA2MEM:=$(ISE_PATH)/bin/lin/data2mem

load: sms_vga_final.bit
	sudo papilio-prog -v -f $<

%_final.bit: %.bit boot_bd.bmm $(MEM_PATH)/all.mem
	$(DATA2MEM) -bm boot_bd.bmm -bd $(MEM_PATH)/all.mem -bt $*.bit -o b $*_final.bit


#=================================================================
# 
# This Makefile builds FPGA projects, and was generated at
# 
#   https://www.boldport.com
# 
# on 2011-08-02 21:15:48 UTC (version 0.1.9.1 2011-07-14)
#
# 'make help' provides a list of possible targets; 'make license' 
# prints licensing information (please keep this header intact)
#
# For the project structure this Makefile follows, see
#
#   https://www.boldport.com/docs/fpgaproj 
#
#=================================================================

# remove Make's built-in rules
.SUFFIXES:

.PHONY: help license sim-hdl sim-view bbx syn imp bit timing power prog clean-all clean-sim clean-bbx clean-syn clean-imp zip upload

# environment parameters
DEL_CMD   = rm -rI 

# NOTE: due to the way make works, edits to the following flags will
# not cause an automatic rebuild of the target. If you edit these flags,
# don't forget to also delete the existing target or "touch" one of
# the dependencies.

# project parameters
DESIGN       := sms_vga
HDL_LANG     := VHDL
VLG_EXT      := v
VHDL_EXT     := vhd
DUT          := xc6slx9tqg144-3

TOP_PATH     := ~/prog/vhdl/master_system/vhdl
SIM_PATH     := $(TOP_PATH)/test
HDL_PATH     := $(TOP_PATH)/src
CON_PATH     := $(TOP_PATH)/src
BLD_PATH     := $(TOP_PATH)/build

# The TOP_FILE is either the top HDL file, or a project file (.prj);
TOP_FILE     := $(TOP_PATH)/main.prj

CON_FILE     := $(CON_PATH)/papilio_plus.ucf
TOP_MODULE   := main
SIM_HDL_TB   := $(SIM_PATH)/main_tb.vhd
SIM_HDL_TOP  := main_tb
XST_FILE     := $(DESIGN).xstbp
SYN_BASE      = -top $(TOP_MODULE) \
                -ifn $(TOP_FILE) \
                -ofn $(DESIGN) \
                -ofmt ngc \
                -p $(DUT)
#                -ifmt $(HDL_LANG) \

# build directory names
SIM          := simulation
SYN          := synthesis
IMP          := implement

# source files make will be sensitive to in $(HDL_PATH);
# if all files there are sources, change to *
HDL_SRCS   := $(wildcard $(HDL_PATH)/*.$(VHDL_EXT))

# blackbox targets (empty if none)
BBX_OBJS   := 

SIM_SRCS   := $(SIM_HDL_TB)
SIM_OBJS   := $(BLD_PATH)/$(SIM)/$(DESIGN)_hdl.sim
SYN_SRCS   := $(BBX_OBJS) $(HDL_SRCS)
SYN_OBJS   := $(BLD_PATH)/$(SYN)/$(DESIGN).ngc
FIT_OBJS   := $(BLD_PATH)/$(IMP)/$(DESIGN).ngd
MAP_OBJS   := $(BLD_PATH)/$(IMP)/$(DESIGN)_map.ncd
PAR_OBJS   := $(BLD_PATH)/$(IMP)/$(DESIGN).ncd
BIT_OBJS   := $(BLD_PATH)/$(IMP)/$(DESIGN).bit
TIM_OBJS   := $(BLD_PATH)/$(IMP)/$(DESIGN).twr
PWR_OBJS   := $(BLD_PATH)/$(IMP)/$(DESIGN).pwr
PROG_SRCS  := $(BLD_PATH)/$(IMP)/bp-impact.cmd

# Flow options
MAP_OPT := 
BIT_OPT := -w  
PAR_OPT := 
SYN_OPT := -opt_mode speed 
TIM_OPT := -e 10 
PWR_OPT := -l 10 

# Tools can run in different contextual/verbosity modes:
# standalone (empty string) or "-intstyle ise|xflow|silent"
MODE  := 

#-----------------------------------------
# build targets
#-----------------------------------------

# Target 'sim-hdl'  : perform behavioral simulation
sim-hdl: $(SIM_OBJS)

# Target 'sim-view' : launch GUI simulation viewer
sim-view: sim-hdl
	cd $(dir $(SIM_OBJS)) && ./$(notdir $(SIM_OBJS)) -gui &

# Target 'syn'      : synthesis netlist (xst .ngc)
syn: $(SYN_OBJS)

# Target 'imp'      : implementation (ngdbuild .ngd, map _map.ncd, par .ncd)
imp: $(FIT_OBJS) $(MAP_OBJS) $(PAR_OBJS)

# Target 'bit'      : bitstream (bitgen .bit)
bit: $(BIT_OBJS)

# Target 'timing'   : timing analysis (trce .twr)
timing: $(TWR_OBJS)

# Target 'power'    : power analysis (xpwr .pwr)
power: $(PWR_OBJS)

# Target 'prog'     : program the FPGA (iMPACT .cmd)
prog: $(BIT_OBJS) $(PROG_SRCS)
	@echo "-- Launcing iMPACT"
	impact -batch $(PROG_SRCS)

#-----------------------------------------
# cleaning targets
#-----------------------------------------

# Target 'clean-all': clean the entire build
clean-all:
	$(DEL_CMD) $(BLD_PATH)

# Target 'clean-sim': clean simulation build directory
clean-sim:
	$(DEL_CMD) $(BLD_PATH)/$(SIM)

# Target 'clean-syn': clean synthesis build dir, but not blackbox dir
clean-syn:
	cd $(BLD_PATH)/$(SYN) && $(DEL_CMD) $(shell ls $(BLD_PATH)/$(SYN)* | grep -v $(BBX))

# Target 'clean-imp': clean implementation build directory
clean-imp:
	$(DEL_CMD) $(BLD_PATH)/$(IMP)

#-----------------------------------------
# recipes
#-----------------------------------------

# synthesis: generate netlist
%.ngc: %.xst %.prj $(SYN_SRCS)
	xst $(MODE) -ifn $*.xst
	@if test ! -f $*.ngc; then exit 2; fi

# ngdbuild: convert netlist to Xilinx format
%.ngd: %.ngc src/%.ucf
	ngdbuild $(MODE) -p $(DUT) -uc src/sms_vga.ucf -bm boot.bmm $*.ngc $*.ngd

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

#xst -intstyle ise -ifn "/home/ben/prog/vhdl/master_system/vhdl/sms_vga.xst" -ofn "/home/ben/prog/vhdl/master_system/vhdl/sms_vga.syr"
#ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc src/papilio_plus.ucf -bm boot.bmm -p xc6slx9-tqg144-3 main.ngc main.ngd
#map -intstyle ise -p xc6slx9-tqg144-3 -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o main_map.ncd main.ngd main.pcf
#par -w -intstyle ise -ol high -mt off main_map.ncd main.ncd main.pcf
#trce -intstyle ise -v 3 -s 3 -n 3 -fastpaths -xml main.twx main.ncd -o main.twr main.pcf
#bitgen -intstyle ise -f main.ut main.ncd
