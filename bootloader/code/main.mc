void start_rom();
void wait_vbl();
byte key_wait();
byte key_read();

void vdp_set_address(word address);
void vdp_write(byte b);
void video_clear_screen();
void video_load_tiles_1bpp(byte* data,byte ntiles);
void video_copy(byte* data, word size);

void console_init();
void console_move_to(byte x,byte y);
void console_set_style(byte style);
void console_print_char(byte char);
void console_print_chars(byte n, byte* chars);
void console_print(byte* string);
void console_print_byte(byte b);
void console_print_word(byte b);
void console_print_address(byte* b);
void console_new_line();

void debug_print_char(byte char);
void debug_print_chars(byte n, byte* chars);
void debug_print(byte* string);
void debug_print_byte(byte b);
void debug_print_word(byte b);
void debug_print_address(byte* b);
void debug_new_line();

void int32_add_int32(byte* a, byte* b);
void int32_debug(byte* a);

bool sd_init();
bool sd_load_sector(byte* target, byte* sector);

bool fat_init();
bool fat_open_root_directory();
bool fat_open_directory(byte* f);

void music_on_irq();
void music_start();
void music_stop();

byte spi_write0(byte value);
void spi_write1(byte value);
byte spi_read0();
byte spi_read1();


void sort_directory(byte* buffer);

extern byte[] sega_logo;
extern byte[] arrow_data;
extern byte[] directory_buffer;

void irq_handler()
{
//	vdp_set_address(0xc000);
//	vdp_write(0x1);
//	music_on_irq();
}

void nmi_handler()
{
}

void main()
{
	byte key;
	console_init();

	// sega logo
	draw_sega_logo();
	
	vdp_set_address(0x3800);
	repeat(20) {
		repeat(0x20) {
			vdp_write(0);
			vdp_write(0);
		}
	}

//	music_start();
	music_stop();

	vdp_set_address(0x8140);
	console_move_to(0,0);
	console_print("SMS Bootloader v0.91");
	console_new_line();


	if (sd_init()) {
		console_print("sd card ok");
		console_new_line();
	} else {
		console_print("sd initialization error");
		return;
	}

	if (fat_init()) {
		console_print("fat init ok");
		console_new_line();
	} else {
		console_print("fat init error");
		return;
	}

	if (!fat_open_root_directory()) {
		console_print("error while reading root directory");
		return;
	}

	main_loop();
}

void draw_sega_logo()
{
	byte c = 0x80;
	console_move_to(22,0);
	repeat (10) {
		vdp_write(c);
		vdp_write(0);
		c = c+1;
	}
	console_move_to(22,1);
	repeat (10) {
		vdp_write(c);
		vdp_write(0);
		c = c+1;
	}
	console_move_to(22,2);
	repeat (10) {
		vdp_write(c);
		vdp_write(0);
		c = c+1;
	}
	console_move_to(22,3);
	repeat (10) {
		vdp_write(c);
		vdp_write(0);
		c = c+1;
	}
}

void main_loop()
{
	byte* scroll_position;
	byte* cursor_position;
	byte key;

	while (true) {
		sort_directory(directory_buffer);
		scroll_position = directory_buffer;
		cursor_position = directory_buffer;
		while (true) {
			print_dir(scroll_position,cursor_position);
			key = key_wait();
			if ((key&4)!=0) {
				if (cursor_position>directory_buffer) {
					cursor_position = cursor_position-0x10;
				}
				if (cursor_position<scroll_position) {
					scroll_position = cursor_position;
				}
			}
			if ((key&2)!=0) {
				if (cursor_position[0x10]!=0) {
					cursor_position = cursor_position+0x10;
				}
				if ((cursor_position-0x130)>scroll_position) {
					scroll_position = cursor_position-0x130;
				}
			}
			if ((key&0x10)!=0) {
				if ((cursor_position[0]&0x10)!=0) {
					if (!load_rom(&cursor_position[12])) {
						console_print("error while reading rom");
					}
					start_rom();
				} else {
					if (!fat_open_directory(&cursor_position[12])) {
						console_print("error while reading file");
						return;
					}
					break;
				}
			}
		}
	}
}

void print_dir(byte* buffer, byte* pointer)
{
	byte* entry;
	byte i;
	entry = buffer;
	i = 0;
	repeat(20) {
		console_move_to(6,4+i);
		if (entry==pointer) {
			console_print_char(0xc8);
			console_print_char(0xc9);
			console_print_char(0x20);
		} else {
			console_print("   ");
		}
		if ((*entry)!=0) {
			print_dir_entry(entry);
		} else {
			console_print("              ");
		}
		entry = entry+0x10;
		i = i+1;
	}
}

void print_dir_entry(byte* entry)
{
	bool dir;
	dir = ((*entry)&0x10)==0;
	if (!dir) {
		console_print(" ");
	} else {
		console_print("[");
	}
	entry = entry+1;
	repeat(8) {
		console_print_char(*entry);
		entry = entry+1;
	}
	console_print_char(0x2e);
	repeat(3) {
		console_print_char(*entry);
		entry = entry+1;
	}
	if (!dir) {
		console_print(" ");
	} else {
		console_print("]");
	}
}

bool load_rom(byte* file)
{
}

void int32_of_byte(byte* dst,byte src)
{
	dst[0] = src;
	dst[1] = 0;
	dst[2] = 0;
	dst[3] = 0;
}

void int32_of_int32(byte* dst,byte* src)
{
	dst[0] = src[0];
	dst[1] = src[1];
	dst[2] = src[2];
	dst[3] = src[3];
}

bool int32_is_equal(byte* a,byte* b)
{
	repeat (4) {
		if ((*a) != (*b)) {
			return false;
		}
		a = a+1;
		b = b+1;
	}
	return true;
}

void int32_print(byte* b)
{
	console_print_byte(b[3]);
	console_print_byte(b[2]);
	console_print_byte(b[1]);
	console_print_byte(b[0]);
}

void int32_debug(byte* b)
{
	debug_print_byte(b[3]);
	debug_print_byte(b[2]);
	debug_print_byte(b[1]);
	debug_print_byte(b[0]);
}
