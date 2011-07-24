MEM_PATH:=~/prog/vhdl/master_system/bootloader/test_tv_output
ISE_PATH:=/home/ben/prog/Xilinx/13.1/ISE_DS/ISE
DATA2MEM:=$(ISE_PATH)/bin/lin/data2mem

load: final.bit
	sudo butterflyprog -v -f final.bit

final.bit: main.bit boot.bmm $(MEM_PATH)/boot.mem
	$(DATA2MEM) -bm boot.bmm -bd $(MEM_PATH)/boot.mem -bt main.bit -o b final.bit


