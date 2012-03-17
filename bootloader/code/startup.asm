org $0000
	di
	im 1
	ld sp,0xdff0
	jr start

org $0008
	push af
	ld a,e
	out ($bf),a
	ld a,d
	out ($bf),a
	pop af
	ret

seek $0018
org $0018
	ret

seek $0020
org $0020
	ret

seek $0028
org $0028
	ret

seek $0030
org $0030
	ret

seek $0038
org $0038
	ex af,af'
	exx
	call irq_handler
	ex af,af'
	exx
	ei
	reti

seek $0066
org $0066
	ex af,af'
	exx
	call nmi_handler
	ex af,af'
	exx
	retn

start:
;	ei
	call main

end:
stop:
	jr stop
	


word_of_bytes:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+7)
	ld h,(ix+5)
	pop ix
	ret

sla_word:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+4)
	ld h,(ix+5)
	sla l
	rl h
	pop ix
	ret

srl_word:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+4)
	ld h,(ix+5)
	srl h
	rr l
	pop ix
	ret

wait_vbl:
	halt
	ret
	
key_read:
	in a,($dc)
	ret

key_wait:
;	call wait_vbl
	in a,($dc)
	cpl
	and $3f
	jr nz,key_wait
key_wait_loop:
;	call wait_vbl
	in a,($dc)
	cpl
	and $3f
	jr z,key_wait_loop
	ret


psg_write:
	pop hl
	pop af
	push af
	out ($7e),a
	jp (hl)











debug_print_char:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	out ($c2),a
	pop ix
	ret

debug_print_hex_digit:
	push ix
	ld ix,$0000
	add ix,sp
	ld hl,console_digit_table
	ld e,(ix+$05)
	ld d,0
	add hl,de
	ld a,(hl)
	push af
	call debug_print_char
	pop de
	pop ix
	ret

debug_print_byte:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	rrc a
	rrc a
	rrc a
	rrc a
	and $f
	push af
	call debug_print_hex_digit
	pop de
	ld a,(ix+$05)
	and $f
	push af
	call debug_print_hex_digit
	pop de
	pop ix
	ret

debug_print_address:
debug_print_word:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	push af
	call debug_print_byte
	pop de
	ld a,(ix+$04)
	push af
	call debug_print_byte
	pop de
	pop ix
	ret
	
start_rom:
	jp $0
