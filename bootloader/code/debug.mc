void debug_print_char(byte c);
void debug_print_byte(byte c);

void debug_print_chars(byte n,byte *str)
{
	repeat (n) {
		debug_print_char(*str);
		str = str+1;
	}
}

void debug_print(byte* str)
{
	byte c;
	while (true) {
		c = *str;
		if (c==0) {
			break;
		}
		debug_print_char(c);
		str = str+1;
	}
}

void debug_print_int32(byte* i)
{
	debug_print_byte(i[3]);
	debug_print_byte(i[2]);
	debug_print_byte(i[1]);
	debug_print_byte(i[0]);
}

void debug_new_line()
{
	debug_print_char(0x0a);
}
