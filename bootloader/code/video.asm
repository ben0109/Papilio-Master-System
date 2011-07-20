vdp_set_address:
	pop hl
	pop de
	push de
	ld a,e
	out ($bf),a
	ld a,d
	out ($bf),a
	jp (hl)

vdp_write:
	pop hl
	pop af
	push af
	out ($be),a
	jp (hl)

video_copy:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+6)
	ld h,(ix+7)
	push bc
	ld c,(ix+4)
	ld b,(ix+5)
video_copy_loop:
	ld a,(hl)
	out ($be),a
	inc hl
	dec bc
	ld a,b
	or c
	jr nz,video_copy_loop
	pop bc
	pop ix
	ret



; load tiles into vram
; p1 number of tiles
; p2 tile data address
video_load_tiles_1bpp:
	push ix
	push iy
	ld iy,0
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,(ix+$08)
	ld (ix+$00),a
	ld l,(ix+$09)
	ld h,(ix+$0a)
video_load_tiles_loop1:
	ld bc,$08be
video_load_tiles_loop2:
	ld a,(hl)
	inc hl
	out (c),a
	out (c),a
	out (c),a
	out (c),a
	djnz video_load_tiles_loop2
	dec (ix+$00)
	jr nz,video_load_tiles_loop1
	ld sp,iy
	pop iy
	pop ix
	ret



video_clear_screen:
	ld de,$3800
	rst 8h
	xor a
	ld bc,$800
video_clear_screen_loop:
	out ($be),a
	dec bc
	jr nz,video_clear_screen_loop

	ld a,$0
	push af
	ld a,$0
	push af
	call console_move_to
	pop hl
	pop hl
	ret



	

console_print_hex_digit:
	push ix
	ld ix,$0000
	add ix,sp
	ld hl,console_digit_table
	ld e,(ix+$05)
	ld d,0
	add hl,de
	ld a,(hl)
	push af
	call console_print_char
	pop de
	pop ix
	ret
console_digit_table:
	db '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'

console_print_byte:
	push ix
	ld ix,$0000
	add ix,sp
	call console_reset_position
	ld a,(ix+$05)
	rrc a
	rrc a
	rrc a
	rrc a
	and $f
	push af
	call console_print_hex_digit
	pop de
	ld a,(ix+$05)
	and $f
	push af
	call console_print_hex_digit
	pop de
	pop ix
	ret

console_print_address:
console_print_word:
	push ix
	ld ix,$0000
	add ix,sp
	call console_reset_position
	ld a,(ix+$05)
	push af
	call console_print_byte
	pop de
	ld a,(ix+$04)
	push af
	call console_print_byte
	pop de
	pop ix
	ret
	
