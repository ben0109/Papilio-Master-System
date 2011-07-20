spi_set_speed:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	and $7f
	out ($c0),a
	pop ix
	ret

spi_assert_cs:
	push ix
	ld ix,$0000
	add ix,sp
	in a,($00)
	and $7f
	out ($c0),a
	pop ix
	ret

spi_deassert_cs:
	push ix
	ld ix,$0000
	add ix,sp
	in a,($00)
	or $80
	out ($c0),a
	pop ix
	ret

spi_delay:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,$ff
	jr spi_send_byte0

spi_receive_byte:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,$ff
	call spi_send_byte
	in a,($01)
;	call console_print_byte
	pop ix
	ret

spi_send_byte:
	push ix
	ld ix,$0000
	add ix,sp
;	call console_print_byte
spi_send_byte0:
	push af
	out ($c1),a
spi_send_byte0_loop:
	in a,($00)
	and $80
	jr z,spi_send_byte0_loop
	pop af
	pop ix
	ret

