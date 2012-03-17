COMP = ../compiler/compiler
LINK = ../compiler/linker
CONV = ../compiler/conv_bin

#PATH_EMU=/home/ben/prog/JSMS
PATH_EMU=/home/backup/workspace/JSMS
EMU=java -cp $(PATH_EMU)/bin/ org.jsms.awt.SwingJsms

boot.o: boot.asm
	z80asm -o $@ $^

boot.mem: boot.o
	srec_cat boot.o -binary -line_length 59 -o boot.mem -vmem 8

vram.mem: vram.bin
	srec_cat vram.bin -binary -offset 0x8000 -line_length 59 -o vram.mem -vmem 8

all.mem: vram.mem boot.mem
	cat boot.mem vram.mem > all.mem

boot.sms: boot.o
	srec_cat boot.o -binary -fill 0 0 0x8000 -o boot.sms -binary

run: boot.sms
	$(EMU) boot.sms

clean:
	rm *.mco


OBJECTS := main.mco console.mco sd.mco fat.mco sort.mco debug.mco music.mco
OBJECTS := $(OBJECTS) int32.mco video.mco spi.mco
OBJECTS := $(OBJECTS) palette.mco #font.mco arrow.mco sega.mco tune.mco

boot.asm: startup.asm end.asm $(OBJECTS)
	$(LINK) $(OBJECTS) > $@

sega.mco: sega.bin
	$(CONV) -l sega_logo sega.bin > $@

tune.mco: tune.bin
	$(CONV) -l music_data tune.bin > $@

%.mco: %.mc
	$(COMP) $^ > $@

%.mco: %.asm
	echo "%code" > $@
	cat $< >> $@
	echo "%end" >> $@

