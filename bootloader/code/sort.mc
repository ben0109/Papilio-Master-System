void debug_print_char(byte char);
void debug_print_chars(byte n, byte* chars);
void debug_print(byte* string);
void debug_print_byte(byte b);
void debug_print_word(byte b);
void debug_print_address(byte* b);
void debug_new_line();

extern byte[] directory_buffer;

void sort_directory(byte* directory)
{
	bool loop;
	byte* a;
	byte* b;
	do {
		a = directory;
		b = a+0x10;
		loop = false;
		while ((*b)!=0) {
			if (sort_compare_entries(a,b)) {
				sort_swap_entries(a,b);
				loop = true;
			}
			a = b;
			b = a+0x10;			
		}
	} while (loop);
}

bool sort_compare_entries(byte* a, byte* b)
{
	repeat (12) {
		if ((*b)!=(*a)) {
			return (*b)<(*a);
		}
		a = a+1;
		b = b+1;
	}
	return false;
}

void sort_swap_entries(byte* a, byte* b)
{
	byte tmp;
	repeat (16) {
		tmp = *a;
		*a = *b;
		*b = tmp;
		a = a+1;
		b = b+1;
	}
}

