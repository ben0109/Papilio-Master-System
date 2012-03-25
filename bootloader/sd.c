#include <sms.h>
#include "sd.h"
#include "console.h"
#include "debug.h"

//#define DEBUG_SD

void spi_out_c0(BYTE value)
{
	#asm
	ld	hl, 2
	add	hl, sp
	ld	a, (hl)
	out ($c0),a
	#endasm
}

void spi_out_c1(BYTE value)
{
	#asm
	ld	hl, 2
	add	hl, sp
	ld	a, (hl)
	out ($c1),a
	#endasm
}

UBYTE spi_in_00()
{
	#asm
	in	a,($00)
	ld	l,a
	ld	h,0
	#endasm
}

UBYTE spi_in_01()
{
	#asm
	in	a,($01)
	ld	l,a
	ld	h,0
	#endasm
}

void spi_set_speed(BYTE delay)
{
	spi_out_c0(delay&0x7f);
}

void spi_assert_cs()
{
	spi_out_c0(spi_in_00()&0x7f);
}

void spi_deassert_cs()
{
	spi_out_c0(spi_in_00()|0x80);
}

UBYTE spi_send_byte(BYTE data)
{
	spi_out_c1(data);
	while ((spi_in_00()&0x80)==0) {}
	return spi_in_01();
}

void spi_delay()
{
	spi_send_byte(0xff);
}

UBYTE spi_receive_byte()
{
	return spi_send_byte(0xff);
}



UBYTE sd_wait_r1()
{
	BYTE r,timeout;
	for (timeout=0x20; timeout>0; --timeout) {
		r = spi_receive_byte();
		if ((r&0x80)==0) {
			break;
		}
	}
	return r;
}

UBYTE sd_cmd0()
{
	BYTE r;

	spi_send_byte(0x40);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x95);

	r = sd_wait_r1();

#ifdef DEBUG_SD
	console_puts("cmd0:");
	console_print_byte(r);
	console_puts("\n");
#endif
	return r;
}

UBYTE sd_cmd8()
{
	BYTE r;

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

#ifdef DEBUG_SD
	console_puts("cmd8:");
	console_print_byte(r);
	console_puts("\n");
#endif
	return r;
}

UBYTE sd_acmd41()
{
	BYTE r;

	spi_send_byte(0x77); // CMD55
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();

	spi_send_byte(0x69); // CMD41
	spi_send_byte(0x40);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();

#ifdef DEBUG_SD
	console_puts("cmd41:");
	console_print_byte(r);
	console_puts("\n");
#endif
	return r;
}

UBYTE sd_cmd58()
{
	BYTE r;

	spi_send_byte(0x7a);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();
	spi_delay(); // if &0xc0==0xc0 => SDHC
	spi_delay();
	spi_delay();
	spi_delay();

#ifdef DEBUG_SD
	console_puts("cmd58:");
	console_print_byte(r);
	console_puts("\n");
#endif
	return r;
}


int sd_init()
{
	UBYTE timeout;

	spi_set_speed(0x7f); // min speed

	// wait a bit
	spi_assert_cs();
	for(timeout=0x10; timeout>0; --timeout) {
		spi_send_byte(0xff);
	}
	spi_deassert_cs();
	spi_send_byte(0xff);
	spi_send_byte(0xff);
	spi_assert_cs();

	// go into idle state
	timeout = 0xff;
	while (sd_cmd0() != 0x01) {
		if (timeout==0) {
			spi_deassert_cs();
			return FALSE;
		}
		timeout = timeout-1;
	}

	if (sd_cmd8() != 0x01) {
		spi_deassert_cs();
		return FALSE;
	}

	// initialize card
	timeout = 0xff;
	while ((sd_acmd41()&1)!=0) {
		if (timeout==0) {
			spi_deassert_cs();
			return FALSE;
		}
		timeout = timeout-1;
	}

	// read OCR
	if (sd_cmd58()!=0) {
		spi_deassert_cs();
		return FALSE;
	}

	spi_deassert_cs();
	spi_set_speed(0x01); // max speed
	return TRUE;
}

int sd_load_sector(UBYTE* target, DWORD sector)
{
	DWORD address;
	BYTE r;
	BYTE timeout;
	int i;

	address = sector<<9;

#ifdef DEBUG_SD
	console_puts("loading address ");
	console_print_dword(address);
	console_puts("\n");
#endif

	// read block
	spi_assert_cs();
	spi_send_byte(0x51);		// CMD17
	spi_send_byte((address>>24)&0xff);
	spi_send_byte((address>>16)&0xff);
	spi_send_byte((address>>8)&0xff);
	spi_send_byte(address&0xff);
	spi_send_byte(0xff);

	r = sd_wait_r1();
#ifdef DEBUG_SD
	console_puts("cmd17:");
	console_print_byte(r);
	console_puts("\n");
#endif
	if ((r&0x80)!=0) {
		spi_deassert_cs();
		return FALSE;
	}

	// wait for 0xfe (start of block)
	timeout = 0xff;
	while (spi_receive_byte()!=0xfe) {
		if (timeout==0) {
			spi_deassert_cs();
			return FALSE;
		}
		timeout = timeout-1;
	}

	// read block
	for (i=0; i<0x200; i++) {
		*target = spi_receive_byte();
/*#ifdef DEBUG
		debug_print_byte(*target);
		if ((i&0x1f)==0x1f)
			debug_puts("\n");
#endif*/
		target++;
	}

	// skip crc
	spi_delay();
	spi_delay();

	// shutdown
	spi_delay();
	spi_deassert_cs();
	return TRUE;
}


