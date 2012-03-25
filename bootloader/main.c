#include <sms.h>
#include "console.h"
#include "sd.h"
#include "fat.h"

unsigned char pal[] = {
	0x30, 0x3f, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
	0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F,
	0x30, 0x03, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
	0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F };

void print_dir(file_descr_t *entries, file_descr_t *current);
void load_rom(file_descr_t *entry);
void wait_key();

void irq_handler()
{
	// nothing
}

void nmi_handler()
{
	// nothing
}

void main()
{
	file_descr_t *entries,*top_of_screen,*current;
	int i;
	char *ptr;

	vdp_set_address(0x8004) // mode 4, disable hbl irq
	vdp_set_address(0x8100); // screen on, enable vbl irq
	vdp_set_address(0x820e); // name table @ $3800
	vdp_set_address(0x85ff); // sprite table @ $3f00
	vdp_set_address(0x8700); // backdrop is color 0
	vdp_set_address(0x8800); // scrollx is 0
	vdp_set_address(0x8900); // scrolly is 0

	vdp_set_address(0xc000);
	ptr = pal;
	for (i=0; i<32; i++) {
		vdp_write(*ptr++);
	}

	// turn off sprites
	vdp_set_address(0x3f00);
	vdp_write(0xd0);

	console_init();
	console_clear();

	vdp_set_address(0x8140); // screen on, enable vbl irq

	console_gotoxy(0,0);
	console_puts("SMS bootloader v0.92\n");


	if (!sd_init()) {
		console_puts("could not initialize sd card\n");
		return;
#ifdef DEBUG
	} else {
		console_puts("sd card initialized\n");
#endif
	}

	if (!fat_init()) {
		console_puts("could not initialize fat system\n");
		return;
#ifdef DEBUG
	} else {
		console_puts("fat system initialized\n");
#endif
	}

	entries = fat_open_root_directory();
	if (entries==0) {
		console_puts("error while reading root directory");
		return;
	}

	top_of_screen = entries;
	current = entries;

	for (;;) {
		int key;
		print_dir(top_of_screen,current);
		key = wait_key();
		switch (key) {
		case JOY_UP:
			if (current!=entries) {
				current--;
				if (current<top_of_screen) {
					top_of_screen = current;
				}
			}
			break;
		case JOY_DOWN:
			if (current[1].type!=0) {
				current++;
				if ((current-top_of_screen)>19) {
					top_of_screen++;
				}
			}
			break;
		case JOY_FIREA:
		case JOY_FIREB:
			if ((current->type&0x10)==0) {
				entries = fat_open_directory(current->cluster);
				if (entries==0) {
					console_puts("error while reading directory");
					return;
				}
				top_of_screen = entries;
				current = entries;
			} else {
				load_rom(current);
				return;
			}
			break;
		}
	}
}

void load_rom(file_descr_t *entry)
{
	file_t file;
	int i;
	DWORD size;

	console_clear();
	console_puts("Opening rom ");
	for (i=0; i<8; i++) {
		console_putc(entry->name[i]);
	}
	console_putc('.');
	for (i=8; i<11; i++) {
		console_putc(entry->name[i]);
	}
	console_puts("\n");

	fat_open_file(&file, entry->cluster);
	size = 0;
	while (1) {
		UBYTE* data;
		if ((size&0x3fff)==0) {
			// switch page 1
			*((UBYTE*)0xfffe) = (size>>14)&0xff;
		}
		// write to page 1
		data = 0x4000+(size&0x3fff);
		data = fat_load_file_sector(&file,data);
		if (data==0) {
			console_puts("error while reading file\n");
		} else if (data==FAT_EOF) {
			console_gotoxy(0,2);
			console_puts("booting rom...\n");
			return;
		} else {
			// process data
			size += 0x200;
			console_gotoxy(0,1);
			console_print_dword(size);
			console_puts(" bytes loaded");
		}
	}
}

void print_dir_entry(file_descr_t *entry)
{
	int dir;
	int i;
	dir = (entry->type&0x10)==0;
	if (!dir) {
		console_putc(' ');
	} else {
		console_putc('[');
	}
	for (i=0; i<8; i++) {
		console_putc(entry->name[i]);
	}
	console_putc(0x2e);
	for (i=0; i<3; i++) {
		console_putc(entry->name[8+i]);
	}
	if (!dir) {
		console_putc(' ');
	} else {
		console_putc(']');
	}
}

void print_dir(file_descr_t *entries, file_descr_t *current)
{
	int i;
	for (i=0; i<20; i++) {
		console_gotoxy(6,4+i);
		if (&entries[i]==current) {
			console_puts("=> ");
		} else {
			console_puts("   ");
		}
		if (entries[i].type!=0) {
			print_dir_entry(&entries[i]);
		} else {
			console_puts("              ");
		}
	}
}

void wait_key()
{
	int j1,nj1;
	j1 = read_joypad1();
	while (1) {
		nj1 = read_joypad1();
		if (nj1&~j1) {
			return nj1&~j1;
		} else {
			j1 = nj1;
		}
	}
}
