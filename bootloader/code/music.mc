void psg_write(byte b);

//extern byte[] music_data;

byte* music_pointer;
bool music_on;

void debug_print(byte* string);
void debug_print_byte(byte b);
void debug_new_line();

void music_on_irq()
{
	byte cmd;
	if (music_on) {
		cmd = music_read_byte();
		if (cmd==0xff) {
			music_start();
		} else {
			if (cmd!=0) {
				repeat(cmd) {
					psg_write(music_read_byte());
				}
			}
		}
	}
}

void music_start()
{
//	music_pointer = music_data;
//	music_on = true;
}

void music_stop()
{
//	music_on = false;
}

byte music_read_byte()
{
	byte b;
	b = *music_pointer;
	music_pointer = music_pointer+1;
	return b;
}
