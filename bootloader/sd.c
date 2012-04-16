#include <sms.h>
#include "sd.h"
#include "console.h"
#include "debug.h"

//#define DEBUG_SD

void spi_set_speed(BYTE delay)
{
	#asm
	ld	hl, 2
	add	hl, sp
	ld	a, (hl)
	and a, $7f
	or a,$80
	out ($c0),a
	#endasm
}

void spi_assert_cs()
{
	#asm
	in a,($00)
	and a,$7f
	out ($c0),a
	#endasm
}

void spi_deassert_cs()
{
	#asm
	in a,($00)
	or a,$80
	out ($c0),a
	#endasm
}

void spi_wait()
{
	#asm
send_byte_loop:
	in a,($00)
	and a,$80
	jr z,send_byte_loop
	#endasm
}

void spi_send_byte(BYTE data)
{
	#asm
	ld	hl, 2
	add	hl, sp
	ld	a, (hl)
	out ($c1),a
	#endasm
	spi_wait();
}

void spi_delay()
{
	spi_send_byte(0xff);
}

UBYTE spi_receive_byte()
{
	spi_delay();
	#asm
	in a,($01)
	ld l,a
	ld h,0
	#endasm
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
	debug_puts("cmd0:");
	debug_print_byte(r);
	debug_puts("\n");
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
	debug_puts("cmd8:");
	debug_print_byte(r);
	debug_puts("\n");
#endif
	return r;
}

UBYTE sd_acmd41(UBYTE byte0)
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
	spi_send_byte(byte0);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0x00);
	spi_send_byte(0xff);

	r = sd_wait_r1();

#ifdef DEBUG_SD
	debug_puts("cmd41:");
	debug_print_byte(r);
	debug_puts("\n");
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
	debug_puts("cmd58:");
	debug_print_byte(r);
	debug_puts("\n");
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

	if (sd_cmd8() == 0x01) {
		// SD card V2+
#ifdef DEBUG_SD
		debug_puts("SD card V2+\n");
#endif
		// initialize card
		timeout = 0xff;
		while ((sd_acmd41(0x40)&1)!=0) {
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

	} else {
		// SD card V1 or MMC
		if (sd_acmd41(0x00)<=1) {
			// SD V1
#ifdef DEBUG_SD
			debug_puts("SD V1\n");
#endif
			timeout = 0xff;
			while ((sd_acmd41(0x00)&1)!=0) {
				if (timeout==0) {
					spi_deassert_cs();
					return FALSE;
				}
				timeout = timeout-1;
			}
		} else {
			// MM Card : fail
#ifdef DEBUG_SD
			debug_puts("MMC\n");
#endif
			spi_deassert_cs();
			return FALSE;
		}
	}

	spi_deassert_cs();
	spi_set_speed(0x00); // max speed
	return TRUE;
}

/* loads $200 bytes from spi */
void load_data(UBYTE *target)
{
/*
	int i;
	for (i=0; i<0x200; i++) {
		*target++ = spi_receive_byte();
	}
*/
	#asm
	ld	hl, 2
	add	hl, sp
	ld	e, (hl)
	inc hl
	ld	d, (hl)
	ex de,hl
	ld bc,$0002
load_data_loop:
	ld a,$ff
	out ($c1),a
load_data_wait:
	in a,($00)
	and a,$80
	jr z,load_data_wait
	in a,($01)
	ld (hl),a
	inc hl
	djnz load_data_loop
	dec c
	jr nz,load_data_loop
	#endasm
}

int sd_load_sector(UBYTE* target, DWORD sector)
{
	DWORD address;
	BYTE r;
	BYTE timeout;

	address = sector<<9;

#ifdef DEBUG_SD
	debug_puts("loading address ");
	debug_print_dword(address);
	debug_puts("\n");
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
	debug_puts("cmd17:");
	debug_print_byte(r);
	debug_puts("\n");
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
	load_data(target);

	// skip crc
	spi_delay();
	spi_delay();

	// shutdown
	spi_delay();
	spi_deassert_cs();
	return TRUE;
}


