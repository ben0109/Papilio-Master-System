void spi_set_speed(byte delay);
void spi_assert_cs();
void spi_deassert_cs();
void spi_delay();
byte spi_receive_byte();
void spi_send_byte(byte data);

void console_init();
void console_move_to(byte x,byte y);
void console_set_style(byte style);
void console_print_char(byte char);
void console_print_chars(byte n, byte* chars);
void console_print(byte* string);
void console_print_byte(byte b);
void console_new_line();

void debug_init();
void debug_move_to(byte x,byte y);
void debug_set_style(byte style);
void debug_print_char(byte char);
void debug_print_chars(byte n, byte* chars);
void debug_print(byte* string);
void debug_print_byte(byte b);
void debug_new_line();

void int32_add_int32(byte* a, byte* b);
void int32_print(byte* a);
void int32_debug(byte* a);

bool sd_init()
{
	byte timeout;

	spi_set_speed(0x40); // 378kHz

	// wait a bit
	spi_assert_cs();
	repeat(0xff) {
		spi_send_byte(0xff);
	}
	spi_deassert_cs();
	spi_send_byte(0xff);
	spi_send_byte(0xff);

	if (sd_cmd0() != 0x01) {	// GO_IDLE_STATE
		return false;
	}

	if (sd_cmd8() != 0x01) {
		return false;
	}

	timeout = 0xff;
	while (true) {
		if (timeout==0) {
			return false;
		}
		if ((sd_acmd41()&1)==0) {
			break;
		}
		timeout = timeout-1;
	}

	if (sd_cmd58()!=0) {
		return false;
	}
	if (sd_cmd16()!=0) {
		return false;
	}

	return true;
}

byte sd_wait_r1()
{
	byte r;
	repeat (8) {
		r = spi_receive_byte();
		if ((r&0x80)==0) {
			return r;
		}
	}
	return r;
}

byte sd_cmd0()
{
	byte r;
	spi_assert_cs();

	spi_send_byte(0x40);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x95);

	r = sd_wait_r1();

	spi_delay();
	spi_deassert_cs();
//	console_print("cmd0:");
//	console_print_byte(r);
//	console_new_line();
	return r;
}

byte sd_cmd8()
{
	byte r;
	spi_assert_cs();

	spi_send_byte(0x48);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x01);
	spi_send_byte(0xaa);
	spi_send_byte(0x87);

	r = sd_wait_r1();
	spi_delay();
	spi_delay();
	spi_delay();
	spi_delay();
	spi_delay();

	spi_delay();
	spi_deassert_cs();
//	console_print("cmd8:");
//	console_print_byte(r);
//	console_new_line();
	return r;
}

byte sd_acmd41()
{
	byte r;
	spi_assert_cs();

	spi_send_byte(0x77);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();

	spi_delay();
	spi_deassert_cs();
	spi_assert_cs();

	spi_send_byte(0x69);
	spi_send_byte(0x40);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();

	spi_delay();
	spi_deassert_cs();
//	console_print("cmd41:");
//	console_print_byte(r);
//	console_new_line();
	return r;
}

byte sd_cmd58()
{
	byte r;
	spi_assert_cs();

	spi_send_byte(0x7a);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();
	spi_delay();
	spi_delay();
	spi_delay();
	spi_delay();
	spi_delay();

	spi_delay();
	spi_deassert_cs();
//	console_print("cmd58:");
//	console_print_byte(r);
//	console_new_line();
	return r;
}

byte sd_cmd16()
{
	byte r;
	spi_assert_cs();

	spi_send_byte(0x50);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x02);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();

	spi_delay();
	spi_deassert_cs();
//	console_print("cmd16:");
//	console_print_byte(r);
//	console_new_line();
	return r;
}

byte sd_cmd17(byte* address)
{
	byte r;
	spi_assert_cs();

	spi_send_byte(0x51);
	spi_send_byte(address[3]);
	spi_send_byte(address[2]);
	spi_send_byte(address[1]);
	spi_send_byte(address[0]);
	spi_send_byte(0xff);

	r = sd_wait_r1();

	spi_delay();
	spi_deassert_cs();
//	console_print("cmd17:");
//	console_print_byte(r);
//	console_new_line();
	return r;
}

bool sd_load_sector(byte* target, byte* sector)
{
	byte[4] address;

	address[0] = 0;
	address[1] = sector[0];
	address[2] = sector[1];
	address[3] = sector[2];

	int32_add_int32(address,address);

//	console_print("loading address ");
//	int32_print(address);
//	console_new_line();

	if ((sd_cmd17(address)&0x80)!=0) {
		return false;
	}

	return sd_receive_block(target);
}

bool sd_receive_block(byte* target)
{
	byte r = 0;
	spi_assert_cs();
	while (true) {
		if (spi_receive_byte()==0xfe) {
			break;
		}
		r = r+1;
		if (r>=8) {
			return false;
		}
	}

	repeat (0x200) {
		*target = spi_receive_byte();
		target = target + 1;
	}

	// skip crc
	spi_delay();
	spi_delay();

	spi_delay();
	spi_deassert_cs();
	return true;
}


