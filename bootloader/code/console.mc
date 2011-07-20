void vdp_set_address(word address);
void vdp_write(byte b);
void video_clear_screen();
void video_load_tiles_1bpp(byte* data,byte ntiles);

extern byte[] palette_data;
extern byte[] font_data;

void console_print_byte(byte b);
byte console_style = 0;
word console_pos = 0;

void console_init()
{
	byte* ptr;

	vdp_set_address(0x8004);	// mode 4
	vdp_set_address(0x8100);	// display off
	vdp_set_address(0x820e);	// table address at $3700
	vdp_set_address(0x8560);	// sprite table at $3000
	vdp_set_address(0x8700);	// overscan color 0
	vdp_set_address(0x8800);	// scroll x = 0
	vdp_set_address(0x8900);	// scroll y = 0

	vdp_set_address(0xc000);
	ptr = palette_data;
	repeat (32) {
		vdp_write(*ptr);
		ptr = ptr+1;
	}

	vdp_set_address(0x0000);
	video_load_tiles_1bpp(font_data, 96);

	console_move_to(0,0);
}

void console_move_to(byte x,byte y)
{
	console_pos = 0x3800;
	repeat (y) {
		console_pos = console_pos + 0x40;
	}
	console_pos = console_pos + x + x;
	vdp_set_address(console_pos);
}

void console_set_style(byte style)
{
	console_style = style&8;
}

void console_new_line()
{
	console_pos = console_pos & 0xffc0;
	console_pos = console_pos + 0x40;
	vdp_set_address(console_pos);
}

void console_reset_position()
{
	vdp_set_address(console_pos);
}

void console_print_char(byte c)
{
	console_reset_position();
	vdp_write(c-0x20);
	vdp_write(console_style);
	console_pos = console_pos+2;
}

void console_print_chars(byte n,byte *str)
{
	byte c;
	console_reset_position();
	repeat (n) {
		c = *str;
		vdp_write(c-0x20);
		vdp_write(console_style);
		console_pos = console_pos+2;
		str = str+1;
	}
}

void console_print(byte* str)
{
	byte c;
	console_reset_position();
	while (true) {
		c = *str;
		if (c==0) {
			break;
		}
		vdp_write(c-0x20);
		vdp_write(console_style);
		console_pos = console_pos+2;
		str = str+1;
	}
}

void console_print_int32(byte* i)
{
	console_print_byte(i[3]);
	console_print_byte(i[2]);
	console_print_byte(i[1]);
	console_print_byte(i[0]);
}
