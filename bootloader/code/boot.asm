org $c000
console_pos:
org $c002
console_style:
org $c003
root_directory_size:
org $c005
root_directory:
org $c009
current_fat_sector:
org $c00d
current_data_sector:
org $c011
first_data_sector:
org $c015
first_fat_sector:
org $c019
sectors_per_cluster:
org $c01a
fat32:
org $c01b
directory_buffer:
org $d01b
data_buffer:
org $d21b
fat_buffer:
org $d41b
music_on:
org $d41c
music_pointer:
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
_global_var_init:
	ld de,$0000
	ld (console_pos),de
	ld a,$00
	ld (console_style),a













	ret
;; void int32_debug(byte* b)
int32_debug:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0003
	add hl,de
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0002
	add hl,de
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0000
	add hl,de
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
_int32_debug_end:
	pop ix
	ret
;; void int32_print(byte* b)
int32_print:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0003
	add hl,de
	ld a,(hl)
	push af
	call console_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0002
	add hl,de
	ld a,(hl)
	push af
	call console_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld a,(hl)
	push af
	call console_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0000
	add hl,de
	ld a,(hl)
	push af
	call console_print_byte
	pop de
_int32_print_end:
	pop ix
	ret
;; bool int32_is_equal(byte* a, byte* b)
int32_is_equal:
	push ix
	ld ix,$0000
	add ix,sp
	push bc
	ld b,$04
_int32_is_equal_71:
	ld l,(ix+$06)
	ld h,(ix+$07)
	ld a,(hl)
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld h,(hl)
	sub h
	jr z,_int32_is_equal_73
	pop bc
	xor a
	jp _int32_is_equal_end
_int32_is_equal_73:
_int32_is_equal_74:
	ld l,(ix+$06)
	ld h,(ix+$07)
	inc hl
	ld (ix+$06),l
	ld (ix+$07),h
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld (ix+$04),l
	ld (ix+$05),h
	djnz _int32_is_equal_71
	pop bc
_int32_is_equal_72:
	ld a,$01
_int32_is_equal_end:
	pop ix
	ret
;; void int32_of_int32(byte* dst, byte* src)
int32_of_int32:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0000
	add hl,de
	ld a,(hl)
	ld hl,$0000
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld a,(hl)
	ld hl,$0001
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0002
	add hl,de
	ld a,(hl)
	ld hl,$0002
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0003
	add hl,de
	ld a,(hl)
	ld hl,$0003
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
_int32_of_int32_end:
	pop ix
	ret
;; void int32_of_byte(byte* dst, byte src)
int32_of_byte:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	ld hl,$0000
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
	ld a,$00
	ld hl,$0001
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
	ld a,$00
	ld hl,$0002
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
	ld a,$00
	ld hl,$0003
	ld e,(ix+$06)
	ld d,(ix+$07)
	add hl,de
	ld (hl),a
_int32_of_byte_end:
	pop ix
	ret
;; bool load_rom(byte* file)
load_rom:
	push ix
	ld ix,$0000
	add ix,sp
_load_rom_end:
	pop ix
	ret
;; void print_dir_entry(byte* entry)
print_dir_entry:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	and $10
	sub $00
	push af
	pop hl
	rl l
	rl l
	rl a
	ld (ix+$00),a
	cpl
	and $01
	jr z,_print_dir_entry_59
	ld hl,_print_dir_entry_61
	push hl
	call console_print
	pop de
	jr _print_dir_entry_60
_print_dir_entry_59:
	ld hl,_print_dir_entry_62
	push hl
	call console_print
	pop de
_print_dir_entry_60:
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	push bc
	ld b,$08
_print_dir_entry_63:
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	push af
	call console_print_char
	pop de
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	djnz _print_dir_entry_63
	pop bc
_print_dir_entry_64:
	ld a,$2e
	push af
	call console_print_char
	pop de
	push bc
	ld b,$03
_print_dir_entry_65:
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	push af
	call console_print_char
	pop de
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	djnz _print_dir_entry_65
	pop bc
_print_dir_entry_66:
	ld a,(ix+$00)
	cpl
	and $01
	jr z,_print_dir_entry_67
	ld hl,_print_dir_entry_69
	push hl
	call console_print
	pop de
	jr _print_dir_entry_68
_print_dir_entry_67:
	ld hl,_print_dir_entry_70
	push hl
	call console_print
	pop de
_print_dir_entry_68:
_print_dir_entry_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void print_dir(byte* buffer, byte* pointer)
print_dir:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffd
	add ix,sp
	ld sp,ix
	ld l,(ix+$0b)
	ld h,(ix+$0c)
	ld (ix+$01),l
	ld (ix+$02),h
	ld a,$00
	ld (ix+$00),a
	push bc
	ld b,$14
_print_dir_51:
	ld a,$06
	push af
	ld a,$04
	ld h,(ix+$00)
	add h
	push af
	call console_move_to
	pop de
	pop de
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld e,(ix+$09)
	ld d,(ix+$0a)
	scf
	ccf
	sbc hl,de
	jr nz,_print_dir_53
	ld a,$c8
	push af
	call console_print_char
	pop de
	ld a,$c9
	push af
	call console_print_char
	pop de
	ld a,$20
	push af
	call console_print_char
	pop de
	jr _print_dir_54
_print_dir_53:
	ld hl,_print_dir_55
	push hl
	call console_print
	pop de
_print_dir_54:
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld a,(hl)
	and a
	jr z,_print_dir_56
	ld l,(ix+$01)
	ld h,(ix+$02)
	push hl
	call print_dir_entry
	pop de
	jr _print_dir_57
_print_dir_56:
	ld hl,_print_dir_58
	push hl
	call console_print
	pop de
_print_dir_57:
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0010
	add hl,de
	ld (ix+$01),l
	ld (ix+$02),h
	inc (ix+$00)
	djnz _print_dir_51
	pop bc
_print_dir_52:
_print_dir_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void main_loop()
main_loop:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffb
	add ix,sp
	ld sp,ix
_main_loop_25:
	ld hl,directory_buffer
	push hl
	call sort_directory
	pop de
	ld hl,directory_buffer
	ld (ix+$03),l
	ld (ix+$04),h
	ld hl,directory_buffer
	ld (ix+$01),l
	ld (ix+$02),h
_main_loop_27:
	ld l,(ix+$03)
	ld h,(ix+$04)
	push hl
	ld l,(ix+$01)
	ld h,(ix+$02)
	push hl
	call print_dir
	pop de
	pop de
	call key_wait
	ld (ix+$00),a
	and $04
	jr z,_main_loop_29
	ld hl,directory_buffer
	ld e,(ix+$01)
	ld d,(ix+$02)
	scf
	ccf
	sbc hl,de
	jr nc,_main_loop_31
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0010
	scf
	ccf
	sbc hl,de
	ld (ix+$01),l
	ld (ix+$02),h
_main_loop_31:
_main_loop_32:
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld e,(ix+$03)
	ld d,(ix+$04)
	scf
	ccf
	sbc hl,de
	jr nc,_main_loop_33
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld (ix+$03),l
	ld (ix+$04),h
_main_loop_33:
_main_loop_34:
_main_loop_29:
_main_loop_30:
	ld a,(ix+$00)
	and $02
	jr z,_main_loop_35
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0010
	add hl,de
	ld a,(hl)
	and a
	jr z,_main_loop_37
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0010
	add hl,de
	ld (ix+$01),l
	ld (ix+$02),h
_main_loop_37:
_main_loop_38:
	ld l,(ix+$03)
	ld h,(ix+$04)
	push hl
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0130
	scf
	ccf
	sbc hl,de
	ex de,hl
	pop hl
	scf
	ccf
	sbc hl,de
	jr nc,_main_loop_39
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0130
	scf
	ccf
	sbc hl,de
	ld (ix+$03),l
	ld (ix+$04),h
_main_loop_39:
_main_loop_40:
_main_loop_35:
_main_loop_36:
	ld a,(ix+$00)
	and $10
	jr z,_main_loop_41
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$0000
	add hl,de
	ld a,(hl)
	and $10
	jr z,_main_loop_43
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$000c
	add hl,de
	push hl
	call load_rom
	pop de
	cpl
	and $01
	jr z,_main_loop_45
	ld hl,_main_loop_47
	push hl
	call console_print
	pop de
_main_loop_45:
_main_loop_46:
	call start_rom
	jr _main_loop_44
_main_loop_43:
	ld l,(ix+$01)
	ld h,(ix+$02)
	ld de,$000c
	add hl,de
	push hl
	call fat_open_directory
	pop de
	cpl
	and $01
	jr z,_main_loop_48
	ld hl,_main_loop_50
	push hl
	call console_print
	pop de
	jp _main_loop_end
_main_loop_48:
_main_loop_49:
	jr _main_loop_28
_main_loop_44:
_main_loop_41:
_main_loop_42:
	jp _main_loop_27
_main_loop_28:
	jp _main_loop_25
_main_loop_26:
_main_loop_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void draw_sega_logo()
draw_sega_logo:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,$80
	ld (ix+$00),a
	ld a,$16
	push af
	ld a,$00
	push af
	call console_move_to
	pop de
	pop de
	push bc
	ld b,$0a
_draw_sega_logo_17:
	ld a,(ix+$00)
	push af
	call vdp_write
	pop de
	ld a,$00
	push af
	call vdp_write
	pop de
	inc (ix+$00)
	djnz _draw_sega_logo_17
	pop bc
_draw_sega_logo_18:
	ld a,$16
	push af
	ld a,$01
	push af
	call console_move_to
	pop de
	pop de
	push bc
	ld b,$0a
_draw_sega_logo_19:
	ld a,(ix+$00)
	push af
	call vdp_write
	pop de
	ld a,$00
	push af
	call vdp_write
	pop de
	inc (ix+$00)
	djnz _draw_sega_logo_19
	pop bc
_draw_sega_logo_20:
	ld a,$16
	push af
	ld a,$02
	push af
	call console_move_to
	pop de
	pop de
	push bc
	ld b,$0a
_draw_sega_logo_21:
	ld a,(ix+$00)
	push af
	call vdp_write
	pop de
	ld a,$00
	push af
	call vdp_write
	pop de
	inc (ix+$00)
	djnz _draw_sega_logo_21
	pop bc
_draw_sega_logo_22:
	ld a,$16
	push af
	ld a,$03
	push af
	call console_move_to
	pop de
	pop de
	push bc
	ld b,$0a
_draw_sega_logo_23:
	ld a,(ix+$00)
	push af
	call vdp_write
	pop de
	ld a,$00
	push af
	call vdp_write
	pop de
	inc (ix+$00)
	djnz _draw_sega_logo_23
	pop bc
_draw_sega_logo_24:
_draw_sega_logo_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void main()
main:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	call console_init
	call draw_sega_logo
	ld hl,$3800
	push hl
	call vdp_set_address
	pop de
	push bc
	ld b,$14
_main_1:
	push bc
	ld b,$20
_main_3:
	ld a,$00
	push af
	call vdp_write
	pop de
	ld a,$00
	push af
	call vdp_write
	pop de
	djnz _main_3
	pop bc
_main_4:
	djnz _main_1
	pop bc
_main_2:
	call music_stop
	ld hl,$8140
	push hl
	call vdp_set_address
	pop de
	ld a,$00
	push af
	ld a,$00
	push af
	call console_move_to
	pop de
	pop de
	ld hl,_main_5
	push hl
	call console_print
	pop de
	call console_new_line
	call sd_init
	and $01
	jr z,_main_6
	ld hl,_main_8
	push hl
	call console_print
	pop de
	call console_new_line
	jr _main_7
_main_6:
	ld hl,_main_9
	push hl
	call console_print
	pop de
	jp _main_end
_main_7:
	call fat_init
	and $01
	jr z,_main_10
	ld hl,_main_12
	push hl
	call console_print
	pop de
	call console_new_line
	jr _main_11
_main_10:
	ld hl,_main_13
	push hl
	call console_print
	pop de
	jp _main_end
_main_11:
	call fat_open_root_directory
	cpl
	and $01
	jr z,_main_14
	ld hl,_main_16
	push hl
	call console_print
	pop de
	jp _main_end
_main_14:
_main_15:
	call main_loop
_main_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void nmi_handler()
nmi_handler:
	push ix
	ld ix,$0000
	add ix,sp
_nmi_handler_end:
	pop ix
	ret
;; void irq_handler()
irq_handler:
	push ix
	ld ix,$0000
	add ix,sp
_irq_handler_end:
	pop ix
	ret
;; void console_print_int32(byte* i)
console_print_int32:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0003
	add hl,de
	ld a,(hl)
	push af
	call console_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0002
	add hl,de
	ld a,(hl)
	push af
	call console_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld a,(hl)
	push af
	call console_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0000
	add hl,de
	ld a,(hl)
	push af
	call console_print_byte
	pop de
_console_print_int32_end:
	pop ix
	ret
;; void console_print(byte* str)
console_print:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	call console_reset_position
_console_print_7:
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	ld (ix+$00),a
	and a
	jr z,_console_print_8
_console_print_10:
	ld a,(ix+$00)
	sub $20
	push af
	call vdp_write
	pop de
	ld a,(console_style)
	push af
	call vdp_write
	pop de
	ld hl,(console_pos)
	ld de,$0002
	add hl,de
	ld (console_pos),hl
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	jp _console_print_7
_console_print_8:
_console_print_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void console_print_chars(byte n, byte* str)
console_print_chars:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	call console_reset_position
	push bc
	ld a,(ix+$0a)
	ld b,a
_console_print_chars_5:
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	ld (ix+$00),a
	sub $20
	push af
	call vdp_write
	pop de
	ld a,(console_style)
	push af
	call vdp_write
	pop de
	ld hl,(console_pos)
	ld de,$0002
	add hl,de
	ld (console_pos),hl
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	djnz _console_print_chars_5
	pop bc
_console_print_chars_6:
_console_print_chars_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void console_print_char(byte c)
console_print_char:
	push ix
	ld ix,$0000
	add ix,sp
	call console_reset_position
	ld a,(ix+$05)
	sub $20
	push af
	call vdp_write
	pop de
	ld a,(console_style)
	push af
	call vdp_write
	pop de
	ld hl,(console_pos)
	ld de,$0002
	add hl,de
	ld (console_pos),hl
_console_print_char_end:
	pop ix
	ret
;; void console_reset_position()
console_reset_position:
	push ix
	ld ix,$0000
	add ix,sp
	ld hl,(console_pos)
	push hl
	call vdp_set_address
	pop de
_console_reset_position_end:
	pop ix
	ret
;; void console_new_line()
console_new_line:
	push ix
	ld ix,$0000
	add ix,sp
	ld hl,(console_pos)
	ld de,$ffc0
	ld a,l
	and e
	ld l,a
	ld a,h
	and d
	ld h,a
	ld (console_pos),hl
	ld de,$0040
	add hl,de
	ld (console_pos),hl
	push hl
	call vdp_set_address
	pop de
_console_new_line_end:
	pop ix
	ret
;; void console_set_style(byte style)
console_set_style:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	and $08
	ld (console_style),a
_console_set_style_end:
	pop ix
	ret
;; void console_move_to(byte x, byte y)
console_move_to:
	push ix
	ld ix,$0000
	add ix,sp
	ld de,$3800
	ld (console_pos),de
	push bc
	ld a,(ix+$05)
	ld b,a
_console_move_to_3:
	ld hl,(console_pos)
	ld de,$0040
	add hl,de
	ld (console_pos),hl
	djnz _console_move_to_3
	pop bc
_console_move_to_4:
	ld hl,(console_pos)
	push hl
	ld a,(ix+$07)
	ld h,(ix+$07)
	add h
	pop hl
	ld e,a
	ld d,$00
	add hl,de
	ld (console_pos),hl
	push hl
	call vdp_set_address
	pop de
_console_move_to_end:
	pop ix
	ret
;; void console_init()
console_init:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffe
	add ix,sp
	ld sp,ix
	ld hl,$8004
	push hl
	call vdp_set_address
	pop de
	ld hl,$8100
	push hl
	call vdp_set_address
	pop de
	ld hl,$820e
	push hl
	call vdp_set_address
	pop de
	ld hl,$8560
	push hl
	call vdp_set_address
	pop de
	ld hl,$8700
	push hl
	call vdp_set_address
	pop de
	ld hl,$8800
	push hl
	call vdp_set_address
	pop de
	ld hl,$8900
	push hl
	call vdp_set_address
	pop de
	ld hl,$c000
	push hl
	call vdp_set_address
	pop de
	ld hl,palette_data
	ld (ix+$00),l
	ld (ix+$01),h
	push bc
	ld b,$20
_console_init_1:
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld a,(hl)
	push af
	call vdp_write
	pop de
	ld l,(ix+$00)
	ld h,(ix+$01)
	inc hl
	ld (ix+$00),l
	ld (ix+$01),h
	djnz _console_init_1
	pop bc
_console_init_2:
	ld hl,$0000
	push hl
	call vdp_set_address
	pop de
	ld a,$00
	push af
	ld a,$00
	push af
	call console_move_to
	pop de
	pop de
_console_init_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool sd_load_sector(byte* target, byte* sector)
sd_load_sector:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffa
	add ix,sp
	ld sp,ix
	ld a,$00
	push af
	ld hl,$0000
	push hl
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	ld de,$0000
	add hl,de
	ld a,(hl)
	push af
	ld hl,$0001
	push hl
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	inc hl
	ld a,(hl)
	push af
	ld hl,$0002
	push hl
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	ld de,$0002
	add hl,de
	ld a,(hl)
	push af
	ld hl,$0003
	push hl
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	call int32_add_int32
	pop de
	pop de
	ld hl,_sd_load_sector_22
	push hl
	call console_print
	pop de
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	call int32_print
	pop de
	call console_new_line
	call spi_assert_cs
	ld a,$51
	push af
	call spi_send_byte
	pop de
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ld de,$0003
	add hl,de
	ld a,(hl)
	push af
	call spi_send_byte
	pop de
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ld de,$0002
	add hl,de
	ld a,(hl)
	push af
	call spi_send_byte
	pop de
	push ix
	pop hl
	ld de,$0002
	add hl,de
	inc hl
	ld a,(hl)
	push af
	call spi_send_byte
	pop de
	push ix
	pop hl
	ld de,$0002
	add hl,de
	ld de,$0000
	add hl,de
	ld a,(hl)
	push af
	call spi_send_byte
	pop de
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$01),a
	and $80
	jr z,_sd_load_sector_23
	call spi_deassert_cs
	xor a
	jp _sd_load_sector_end
_sd_load_sector_23:
_sd_load_sector_24:
	ld a,$ff
	ld (ix+$00),a
_sd_load_sector_25:
	call spi_receive_byte
	sub $fe
	jp z,_sd_load_sector_26
	ld a,(ix+$00)
	and a
	jr nz,_sd_load_sector_27
	call spi_deassert_cs
	xor a
	jp _sd_load_sector_end
_sd_load_sector_27:
_sd_load_sector_28:
	dec (ix+$00)
	jp _sd_load_sector_25
_sd_load_sector_26:
	push bc
	ld bc,$0200
_sd_load_sector_29:
	call spi_receive_byte
	ld l,(ix+$0e)
	ld h,(ix+$0f)
	ld (hl),a
	ld l,(ix+$0e)
	ld h,(ix+$0f)
	inc hl
	ld (ix+$0e),l
	ld (ix+$0f),h
	dec bc
	ld a,b
	or  c
	jr nz,_sd_load_sector_29
	pop bc
_sd_load_sector_30:
	call spi_delay
	call spi_delay
	call spi_delay
	call spi_deassert_cs
	ld a,$01
_sd_load_sector_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; byte sd_cmd16()
sd_cmd16:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,$50
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$02
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$00),a
_sd_cmd16_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; byte sd_cmd58()
sd_cmd58:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,$7a
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$00),a
	call spi_delay
	call spi_delay
	call spi_delay
	call spi_delay
	ld a,(ix+$00)
_sd_cmd58_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; byte sd_acmd41()
sd_acmd41:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,$77
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$00),a
	ld a,$69
	push af
	call spi_send_byte
	pop de
	ld a,$40
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$00),a
_sd_acmd41_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; byte sd_cmd8()
sd_cmd8:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,$48
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$01
	push af
	call spi_send_byte
	pop de
	ld a,$aa
	push af
	call spi_send_byte
	pop de
	ld a,$87
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$00),a
	call spi_delay
	call spi_delay
	call spi_delay
	call spi_delay
	call spi_delay
	ld a,(ix+$00)
_sd_cmd8_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; byte sd_cmd0()
sd_cmd0:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,$40
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$00
	push af
	call spi_send_byte
	pop de
	ld a,$95
	push af
	call spi_send_byte
	pop de
	call sd_wait_r1
	ld (ix+$00),a
_sd_cmd0_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; byte sd_wait_r1()
sd_wait_r1:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	push bc
	ld b,$20
_sd_wait_r1_18:
	call spi_receive_byte
	ld (ix+$00),a
	and $80
	jr nz,_sd_wait_r1_20
	pop bc
	ld a,(ix+$00)
	jp _sd_wait_r1_end
_sd_wait_r1_20:
_sd_wait_r1_21:
	djnz _sd_wait_r1_18
	pop bc
_sd_wait_r1_19:
	ld a,(ix+$00)
_sd_wait_r1_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool sd_init()
sd_init:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld hl,_sd_init_1
	push hl
	call console_print
	pop de
	call console_new_line
	ld a,$7f
	push af
	call spi_set_speed
	pop de
	call spi_assert_cs
	push bc
	ld b,$10
_sd_init_2:
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	djnz _sd_init_2
	pop bc
_sd_init_3:
	call spi_deassert_cs
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	ld a,$ff
	push af
	call spi_send_byte
	pop de
	call spi_assert_cs
	ld a,$ff
	ld (ix+$00),a
_sd_init_4:
	call sd_cmd0
	dec a
	jp z,_sd_init_5
	ld a,(ix+$00)
	and a
	jr nz,_sd_init_6
	call spi_deassert_cs
	xor a
	jp _sd_init_end
_sd_init_6:
_sd_init_7:
	dec (ix+$00)
	jp _sd_init_4
_sd_init_5:
	call sd_cmd8
	dec a
	jr z,_sd_init_8
	call spi_deassert_cs
	xor a
	jp _sd_init_end
_sd_init_8:
_sd_init_9:
	ld a,$ff
	ld (ix+$00),a
_sd_init_10:
	call sd_acmd41
	and $01
	jp z,_sd_init_11
	ld a,(ix+$00)
	and a
	jr nz,_sd_init_12
	call spi_deassert_cs
	xor a
	jp _sd_init_end
_sd_init_12:
_sd_init_13:
	dec (ix+$00)
	jp _sd_init_10
_sd_init_11:
	call sd_cmd58
	and a
	jr z,_sd_init_14
	call spi_deassert_cs
	xor a
	jp _sd_init_end
_sd_init_14:
_sd_init_15:
	call sd_cmd16
	and a
	jr z,_sd_init_16
	call spi_deassert_cs
	xor a
	jp _sd_init_end
_sd_init_16:
_sd_init_17:
	call spi_deassert_cs
	ld a,$01
_sd_init_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool fat_process_directory_entry(byte* target, byte* data)
fat_process_directory_entry:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffc
	add ix,sp
	ld sp,ix
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld a,(hl)
	sub $e5
	jr nz,_fat_process_directory_entry_82
	xor a
	jp _fat_process_directory_entry_end
_fat_process_directory_entry_82:
_fat_process_directory_entry_83:
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld de,$000b
	add hl,de
	ld a,(hl)
	and $0d
	jr z,_fat_process_directory_entry_84
	xor a
	jp _fat_process_directory_entry_end
_fat_process_directory_entry_84:
_fat_process_directory_entry_85:
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld de,$000b
	add hl,de
	ld a,(hl)
	and $10
	xor $10
	or  $01
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	ld (hl),a
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	inc hl
	ld (ix+$0c),l
	ld (ix+$0d),h
	push bc
	ld b,$0b
_fat_process_directory_entry_86:
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld a,(hl)
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	ld (hl),a
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	inc hl
	ld (ix+$0c),l
	ld (ix+$0d),h
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	inc hl
	ld (ix+$0a),l
	ld (ix+$0b),h
	djnz _fat_process_directory_entry_86
	pop bc
_fat_process_directory_entry_87:
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld de,$000f
	add hl,de
	ld a,(hl)
	ld hl,$0000
	ld e,(ix+$0c)
	ld d,(ix+$0d)
	add hl,de
	ld (hl),a
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld de,$0010
	add hl,de
	ld a,(hl)
	ld hl,$0001
	ld e,(ix+$0c)
	ld d,(ix+$0d)
	add hl,de
	ld (hl),a
	ld a,(fat32)
	and $01
	jr z,_fat_process_directory_entry_88
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld de,$0009
	add hl,de
	ld a,(hl)
	ld hl,$0002
	ld e,(ix+$0c)
	ld d,(ix+$0d)
	add hl,de
	ld (hl),a
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	ld de,$000a
	add hl,de
	ld a,(hl)
	ld hl,$0003
	ld e,(ix+$0c)
	ld d,(ix+$0d)
	add hl,de
	ld (hl),a
	jr _fat_process_directory_entry_89
_fat_process_directory_entry_88:
	ld a,$00
	ld hl,$0002
	ld e,(ix+$0c)
	ld d,(ix+$0d)
	add hl,de
	ld (hl),a
	ld a,$00
	ld hl,$0003
	ld e,(ix+$0c)
	ld d,(ix+$0d)
	add hl,de
	ld (hl),a
_fat_process_directory_entry_89:
	ld a,$01
_fat_process_directory_entry_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void fat_clear_directory_buffer()
fat_clear_directory_buffer:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffe
	add ix,sp
	ld sp,ix
	ld hl,directory_buffer
	ld (ix+$00),l
	ld (ix+$01),h
	push bc
	ld bc,$0100
_fat_clear_directory_buffer_80:
	ld a,$00
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld (hl),a
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld de,$0010
	add hl,de
	ld (ix+$00),l
	ld (ix+$01),h
	dec bc
	ld a,b
	or  c
	jr nz,_fat_clear_directory_buffer_80
	pop bc
_fat_clear_directory_buffer_81:
_fat_clear_directory_buffer_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool process_directory_sector(byte** directory_ptr, byte* buffer_ptr)
process_directory_sector:
	push ix
	ld ix,$0000
	add ix,sp
	push bc
	ld b,$10
_process_directory_sector_74:
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld a,(hl)
	and a
	jr nz,_process_directory_sector_76
	pop bc
	ld a,$01
	jp _process_directory_sector_end
_process_directory_sector_76:
_process_directory_sector_77:
	ld l,(ix+$06)
	ld h,(ix+$07)
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	push hl
	ld l,(ix+$04)
	ld h,(ix+$05)
	push hl
	call fat_process_directory_entry
	pop de
	pop de
	and $01
	jr z,_process_directory_sector_78
	ld l,(ix+$06)
	ld h,(ix+$07)
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	ld de,$0010
	add hl,de
	ex de,hl
	ld l,(ix+$06)
	ld h,(ix+$07)
	ld (hl),e
	inc hl
	ld (hl),d
_process_directory_sector_78:
_process_directory_sector_79:
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0020
	add hl,de
	ld (ix+$04),l
	ld (ix+$05),h
	djnz _process_directory_sector_74
	pop bc
_process_directory_sector_75:
	xor a
_process_directory_sector_end:
	pop ix
	ret
;; bool fat_open_directory(byte* first_cluster)
fat_open_directory:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fff6
	add ix,sp
	ld sp,ix
	ld a,(fat32)
	cpl
	and $01
	jr z,_fat_open_directory_59
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	ld a,$00
	push af
	call int32_of_byte
	pop de
	pop de
	ld l,(ix+$10)
	ld h,(ix+$11)
	push hl
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	call int32_is_equal
	pop de
	pop de
	and $01
	jr z,_fat_open_directory_61
	ld hl,_fat_open_directory_63
	push hl
	call console_print
	pop de
	call console_new_line
	call fat_open_root_directory16
	jp _fat_open_directory_end
_fat_open_directory_61:
_fat_open_directory_62:
_fat_open_directory_59:
_fat_open_directory_60:
	call fat_clear_directory_buffer
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	ld l,(ix+$10)
	ld h,(ix+$11)
	push hl
	call int32_of_int32
	pop de
	pop de
	ld hl,directory_buffer
	ld (ix+$00),l
	ld (ix+$01),h
_fat_open_directory_64:
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	call first_sector_of_cluster
	pop de
	pop de
	push bc
	ld b,$08
_fat_open_directory_66:
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	call load_data_sector
	pop de
	cpl
	and $01
	jr z,_fat_open_directory_68
	pop bc
	xor a
	jp _fat_open_directory_end
_fat_open_directory_68:
_fat_open_directory_69:
	push ix
	pop hl
	ld de,$0000
	add hl,de
	push hl
	ld hl,data_buffer
	push hl
	call process_directory_sector
	pop de
	pop de
	and $01
	jr z,_fat_open_directory_70
	pop bc
	ld a,$01
	jp _fat_open_directory_end
_fat_open_directory_70:
_fat_open_directory_71:
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	ld a,$01
	push af
	call int32_add_byte
	pop de
	pop de
	djnz _fat_open_directory_66
	pop bc
_fat_open_directory_67:
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	call fat_next_cluster
	pop de
	pop de
	and $01
	jr z,_fat_open_directory_72
	xor a
	jp _fat_open_directory_end
_fat_open_directory_72:
_fat_open_directory_73:
	push ix
	pop hl
	ld de,$0006
	add hl,de
	push hl
	call fat_is_last_cluster
	pop de
	cpl
	and $01
	jp nz,_fat_open_directory_64
_fat_open_directory_65:
	ld a,$01
_fat_open_directory_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool fat_open_root_directory16()
fat_open_root_directory16:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fff8
	add ix,sp
	ld sp,ix
	call fat_clear_directory_buffer
	push ix
	pop hl
	ld de,$0004
	add hl,de
	push hl
	ld hl,root_directory
	push hl
	call int32_of_int32
	pop de
	pop de
	ld hl,directory_buffer
	ld (ix+$02),l
	ld (ix+$03),h
	push bc
	ld bc,(root_directory_size)
_fat_open_root_directory16_53:
	push ix
	pop hl
	ld de,$0004
	add hl,de
	push hl
	call load_data_sector
	pop de
	cpl
	and $01
	jr z,_fat_open_root_directory16_55
	pop bc
	xor a
	jp _fat_open_root_directory16_end
_fat_open_root_directory16_55:
_fat_open_root_directory16_56:
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	ld hl,data_buffer
	push hl
	call process_directory_sector
	pop de
	pop de
	and $01
	jr z,_fat_open_root_directory16_57
	pop bc
	ld a,$01
	jp _fat_open_root_directory16_end
_fat_open_root_directory16_57:
_fat_open_root_directory16_58:
	push ix
	pop hl
	ld de,$0004
	add hl,de
	push hl
	ld a,$01
	push af
	call int32_add_byte
	pop de
	pop de
	dec bc
	ld a,b
	or  c
	jr nz,_fat_open_root_directory16_53
	pop bc
_fat_open_root_directory16_54:
	ld a,$00
	ld l,(ix+$02)
	ld h,(ix+$03)
	ld (hl),a
	ld a,$01
_fat_open_root_directory16_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool fat_open_root_directory()
fat_open_root_directory:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(fat32)
	and $01
	jr z,_fat_open_root_directory_51
	ld hl,root_directory
	push hl
	call fat_open_directory
	pop de
	jp _fat_open_root_directory_end
_fat_open_root_directory_51:
_fat_open_root_directory_52:
	call fat_open_root_directory16
_fat_open_root_directory_end:
	pop ix
	ret
;; bool fat_is_last_cluster(byte* cluster)
fat_is_last_cluster:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0000
	add hl,de
	ld a,(hl)
	and $f8
	sub $f8
	jr z,_fat_is_last_cluster_43
	xor a
	jp _fat_is_last_cluster_end
_fat_is_last_cluster_43:
_fat_is_last_cluster_44:
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld a,(hl)
	sub $ff
	jr z,_fat_is_last_cluster_45
	xor a
	jp _fat_is_last_cluster_end
_fat_is_last_cluster_45:
_fat_is_last_cluster_46:
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0002
	add hl,de
	ld a,(hl)
	sub $ff
	jr z,_fat_is_last_cluster_47
	xor a
	jp _fat_is_last_cluster_end
_fat_is_last_cluster_47:
_fat_is_last_cluster_48:
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0003
	add hl,de
	ld a,(hl)
	sub $ff
	jr z,_fat_is_last_cluster_49
	xor a
	jp _fat_is_last_cluster_end
_fat_is_last_cluster_49:
_fat_is_last_cluster_50:
	ld a,$01
_fat_is_last_cluster_end:
	pop ix
	ret
;; bool fat_next_cluster(byte* next, byte* current)
fat_next_cluster:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffa
	add ix,sp
	ld sp,ix
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	push hl
	call int32_of_int32
	pop de
	pop de
	push bc
	ld b,$07
_fat_next_cluster_39:
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	call int32_srl
	pop de
	djnz _fat_next_cluster_39
	pop bc
_fat_next_cluster_40:
	push ix
	pop hl
	ld de,$0002
	add hl,de
	push hl
	call load_fat_sector
	pop de
	cpl
	and $01
	jr z,_fat_next_cluster_41
	xor a
	jp _fat_next_cluster_end
_fat_next_cluster_41:
_fat_next_cluster_42:
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	ld de,$0000
	add hl,de
	ld a,(hl)
	and $7f
	ld l,a
	ld h,$00
	ld (ix+$00),l
	ld (ix+$01),h
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld e,(ix+$00)
	ld d,(ix+$01)
	add hl,de
	ld (ix+$00),l
	ld (ix+$01),h
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld e,(ix+$00)
	ld d,(ix+$01)
	add hl,de
	ld (ix+$00),l
	ld (ix+$01),h
	ld l,(ix+$0e)
	ld h,(ix+$0f)
	push hl
	ld hl,fat_buffer
	ld e,(ix+$00)
	ld d,(ix+$01)
	add hl,de
	push hl
	call int32_of_int32
	pop de
	pop de
	ld a,$01
_fat_next_cluster_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void first_sector_of_cluster(byte* sector, byte* cluster)
first_sector_of_cluster:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffc
	add ix,sp
	ld sp,ix
	ld a,$fe
	push af
	ld hl,$0000
	push hl
	push ix
	pop hl
	ld de,$0000
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld a,$ff
	push af
	ld hl,$0001
	push hl
	push ix
	pop hl
	ld de,$0000
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld a,$ff
	push af
	ld hl,$0002
	push hl
	push ix
	pop hl
	ld de,$0000
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld a,$ff
	push af
	ld hl,$0003
	push hl
	push ix
	pop hl
	ld de,$0000
	add hl,de
	ex de,hl
	pop hl
	pop af
	add hl,de
	ld (hl),a
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	push hl
	ld hl,first_data_sector
	push hl
	call int32_of_int32
	pop de
	pop de
	push bc
	ld a,(sectors_per_cluster)
	ld b,a
_first_sector_of_cluster_37:
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	push hl
	push ix
	pop hl
	ld de,$0000
	add hl,de
	push hl
	call int32_add_int32
	pop de
	pop de
	ld l,(ix+$0c)
	ld h,(ix+$0d)
	push hl
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	push hl
	call int32_add_int32
	pop de
	pop de
	djnz _first_sector_of_cluster_37
	pop bc
_first_sector_of_cluster_38:
_first_sector_of_cluster_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool load_data_sector(byte* sector)
load_data_sector:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	push hl
	ld hl,current_data_sector
	push hl
	call int32_is_equal
	pop de
	pop de
	and $01
	jr z,_load_data_sector_33
	ld a,$01
	jp _load_data_sector_end
_load_data_sector_33:
_load_data_sector_34:
	ld hl,data_buffer
	push hl
	ld l,(ix+$04)
	ld h,(ix+$05)
	push hl
	call sd_load_sector
	pop de
	pop de
	and $01
	jr z,_load_data_sector_35
	ld hl,current_data_sector
	push hl
	ld l,(ix+$04)
	ld h,(ix+$05)
	push hl
	call int32_of_int32
	pop de
	pop de
	ld a,$01
	jp _load_data_sector_end
_load_data_sector_35:
_load_data_sector_36:
	xor a
_load_data_sector_end:
	pop ix
	ret
;; bool load_fat_sector(byte* s)
load_fat_sector:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffc
	add ix,sp
	ld sp,ix
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	push hl
	ld hl,current_fat_sector
	push hl
	call int32_is_equal
	pop de
	pop de
	and $01
	jr z,_load_fat_sector_29
	ld a,$01
	jp _load_fat_sector_end
_load_fat_sector_29:
_load_fat_sector_30:
	push ix
	pop hl
	ld de,$0000
	add hl,de
	push hl
	ld hl,first_fat_sector
	push hl
	call int32_of_int32
	pop de
	pop de
	push ix
	pop hl
	ld de,$0000
	add hl,de
	push hl
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	push hl
	call int32_add_int32
	pop de
	pop de
	ld hl,fat_buffer
	push hl
	push ix
	pop hl
	ld de,$0000
	add hl,de
	push hl
	call sd_load_sector
	pop de
	pop de
	and $01
	jr z,_load_fat_sector_31
	ld hl,current_fat_sector
	push hl
	ld l,(ix+$0a)
	ld h,(ix+$0b)
	push hl
	call int32_of_int32
	pop de
	pop de
	ld a,$01
	jp _load_fat_sector_end
_load_fat_sector_31:
_load_fat_sector_32:
	xor a
_load_fat_sector_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void fat_init16()
fat_init16:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffe
	add ix,sp
	ld sp,ix
	ld hl,root_directory
	push hl
	ld hl,first_fat_sector
	push hl
	call int32_of_int32
	pop de
	pop de
	ld hl,data_buffer
	ld de,$0016
	add hl,de
	ld a,(hl)
	push af
	ld hl,data_buffer
	ld de,$0017
	add hl,de
	ld a,(hl)
	push af
	call word_of_bytes
	pop de
	pop de
	ld (ix+$00),l
	ld (ix+$01),h
	push bc
	ld hl,data_buffer
	ld de,$0010
	add hl,de
	ld a,(hl)
	ld b,a
_fat_init16_25:
	ld hl,root_directory
	push hl
	ld l,(ix+$00)
	ld h,(ix+$01)
	push hl
	call int32_add_word
	pop de
	pop de
	djnz _fat_init16_25
	pop bc
_fat_init16_26:
	ld hl,data_buffer
	ld de,$0011
	add hl,de
	ld a,(hl)
	push af
	ld hl,data_buffer
	ld de,$0012
	add hl,de
	ld a,(hl)
	push af
	call word_of_bytes
	pop de
	pop de
	ld (root_directory_size),hl
	push bc
	ld b,$04
_fat_init16_27:
	ld hl,(root_directory_size)
	push hl
	call srl_word
	pop de
	ld (root_directory_size),hl
	djnz _fat_init16_27
	pop bc
_fat_init16_28:
	ld hl,first_data_sector
	push hl
	ld hl,root_directory
	push hl
	call int32_of_int32
	pop de
	pop de
	ld hl,first_data_sector
	push hl
	ld hl,(root_directory_size)
	push hl
	call int32_add_word
	pop de
	pop de
_fat_init16_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void fat_init32()
fat_init32:
	push ix
	ld ix,$0000
	add ix,sp
	ld hl,first_data_sector
	push hl
	ld hl,first_fat_sector
	push hl
	call int32_of_int32
	pop de
	pop de
	push bc
	ld hl,data_buffer
	ld de,$0010
	add hl,de
	ld a,(hl)
	ld b,a
_fat_init32_23:
	ld hl,first_data_sector
	push hl
	ld hl,data_buffer
	ld de,$0024
	add hl,de
	push hl
	call int32_add_int32
	pop de
	pop de
	djnz _fat_init32_23
	pop bc
_fat_init32_24:
	ld hl,root_directory
	push hl
	ld hl,data_buffer
	ld de,$002c
	add hl,de
	push hl
	call int32_of_int32
	pop de
	pop de
_fat_init32_end:
	pop ix
	ret
;; bool fat_init()
fat_init:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffb
	add ix,sp
	ld sp,ix
	push ix
	pop hl
	inc hl
	push hl
	ld a,$00
	push af
	call int32_of_byte
	pop de
	pop de
	ld hl,data_buffer
	push hl
	push ix
	pop hl
	inc hl
	push hl
	call sd_load_sector
	pop de
	pop de
	cpl
	and $01
	jr z,_fat_init_1
	ld hl,_fat_init_3
	push hl
	call console_print
	pop de
	call console_new_line
	xor a
	jp _fat_init_end
_fat_init_1:
_fat_init_2:
	ld hl,data_buffer
	ld de,$01fe
	add hl,de
	ld a,(hl)
	sub $55
	push af
	pop hl
	rl l
	rl l
	ccf
	rl a
	push af
	ld hl,data_buffer
	ld de,$01ff
	add hl,de
	ld a,(hl)
	sub $aa
	push af
	pop hl
	rl l
	rl l
	ccf
	rl a
	push af
	pop hl
	pop af
	or  l
	and $01
	jr z,_fat_init_4
	ld hl,_fat_init_6
	push hl
	call console_print
	pop de
	call console_new_line
	xor a
	jp _fat_init_end
_fat_init_4:
_fat_init_5:
	ld hl,data_buffer
	ld de,$01c2
	add hl,de
	ld a,(hl)
	ld (ix+$00),a
	sub $06
	jr nz,_fat_init_7
	xor a
	ld (fat32),a
	jr _fat_init_8
_fat_init_7:
	ld a,(ix+$00)
	sub $0b
	jr nz,_fat_init_9
	ld a,$01
	ld (fat32),a
	jr _fat_init_10
_fat_init_9:
	ld hl,_fat_init_11
	push hl
	call console_print
	pop de
	call console_new_line
	xor a
	jp _fat_init_end
_fat_init_10:
_fat_init_8:
	push ix
	pop hl
	inc hl
	push hl
	ld hl,data_buffer
	ld de,$01c6
	add hl,de
	push hl
	call int32_of_int32
	pop de
	pop de
	ld hl,data_buffer
	push hl
	push ix
	pop hl
	inc hl
	push hl
	call sd_load_sector
	pop de
	pop de
	cpl
	and $01
	jr z,_fat_init_12
	ld hl,_fat_init_14
	push hl
	call console_print
	pop de
	call console_new_line
	xor a
	jp _fat_init_end
_fat_init_12:
_fat_init_13:
	ld hl,data_buffer
	ld de,$01fe
	add hl,de
	ld a,(hl)
	sub $55
	push af
	pop hl
	rl l
	rl l
	ccf
	rl a
	push af
	ld hl,data_buffer
	ld de,$01ff
	add hl,de
	ld a,(hl)
	sub $aa
	push af
	pop hl
	rl l
	rl l
	ccf
	rl a
	push af
	pop hl
	pop af
	or  l
	and $01
	jr z,_fat_init_15
	ld hl,_fat_init_17
	push hl
	call console_print
	pop de
	call console_new_line
	xor a
	jp _fat_init_end
_fat_init_15:
_fat_init_16:
	ld hl,data_buffer
	ld de,$000b
	add hl,de
	ld a,(hl)
	sub $00
	push af
	pop hl
	rl l
	rl l
	ccf
	rl a
	push af
	ld hl,data_buffer
	ld de,$000c
	add hl,de
	ld a,(hl)
	sub $02
	push af
	pop hl
	rl l
	rl l
	ccf
	rl a
	push af
	pop hl
	pop af
	or  l
	and $01
	jr z,_fat_init_18
	ld hl,_fat_init_20
	push hl
	call console_print
	pop de
	call console_new_line
	xor a
	jp _fat_init_end
_fat_init_18:
_fat_init_19:
	ld hl,data_buffer
	ld de,$000d
	add hl,de
	ld a,(hl)
	ld (sectors_per_cluster),a
	ld hl,first_fat_sector
	push hl
	push ix
	pop hl
	inc hl
	push hl
	call int32_of_int32
	pop de
	pop de
	ld hl,first_fat_sector
	push hl
	ld hl,data_buffer
	ld de,$000e
	add hl,de
	ld a,(hl)
	push af
	call int32_add_byte
	pop de
	pop de
	ld a,(fat32)
	and $01
	jr z,_fat_init_21
	call fat_init32
	jr _fat_init_22
_fat_init_21:
	call fat_init16
_fat_init_22:
	ld a,$01
_fat_init_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void sort_swap_entries(byte* a, byte* b)
sort_swap_entries:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	push bc
	ld b,$10
_sort_swap_entries_11:
	ld l,(ix+$09)
	ld h,(ix+$0a)
	ld a,(hl)
	ld (ix+$00),a
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	ld l,(ix+$09)
	ld h,(ix+$0a)
	ld (hl),a
	ld a,(ix+$00)
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld (hl),a
	ld l,(ix+$09)
	ld h,(ix+$0a)
	inc hl
	ld (ix+$09),l
	ld (ix+$0a),h
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	djnz _sort_swap_entries_11
	pop bc
_sort_swap_entries_12:
_sort_swap_entries_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; bool sort_compare_entries(byte* a, byte* b)
sort_compare_entries:
	push ix
	ld ix,$0000
	add ix,sp
	push bc
	ld b,$0c
_sort_compare_entries_7:
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld a,(hl)
	ld l,(ix+$06)
	ld h,(ix+$07)
	ld h,(hl)
	sub h
	jr z,_sort_compare_entries_9
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld a,(hl)
	ld l,(ix+$06)
	ld h,(ix+$07)
	ld h,(hl)
	sub h
	push af
	pop hl
	pop bc
	ld a,l
	jp _sort_compare_entries_end
_sort_compare_entries_9:
_sort_compare_entries_10:
	ld l,(ix+$06)
	ld h,(ix+$07)
	inc hl
	ld (ix+$06),l
	ld (ix+$07),h
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld (ix+$04),l
	ld (ix+$05),h
	djnz _sort_compare_entries_7
	pop bc
_sort_compare_entries_8:
	xor a
_sort_compare_entries_end:
	pop ix
	ret
;; void sort_directory(byte* directory)
sort_directory:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$fffb
	add ix,sp
	ld sp,ix
_sort_directory_1:
	ld l,(ix+$0b)
	ld h,(ix+$0c)
	ld (ix+$02),l
	ld (ix+$03),h
	ld l,(ix+$02)
	ld h,(ix+$03)
	ld de,$0010
	add hl,de
	ld (ix+$00),l
	ld (ix+$01),h
	xor a
	ld (ix+$04),a
_sort_directory_3:
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld a,(hl)
	and a
	jp z,_sort_directory_4
	ld l,(ix+$02)
	ld h,(ix+$03)
	push hl
	ld l,(ix+$00)
	ld h,(ix+$01)
	push hl
	call sort_compare_entries
	pop de
	pop de
	and $01
	jr z,_sort_directory_5
	ld l,(ix+$02)
	ld h,(ix+$03)
	push hl
	ld l,(ix+$00)
	ld h,(ix+$01)
	push hl
	call sort_swap_entries
	pop de
	pop de
	ld a,$01
	ld (ix+$04),a
_sort_directory_5:
_sort_directory_6:
	ld l,(ix+$00)
	ld h,(ix+$01)
	ld (ix+$02),l
	ld (ix+$03),h
	ld l,(ix+$02)
	ld h,(ix+$03)
	ld de,$0010
	add hl,de
	ld (ix+$00),l
	ld (ix+$01),h
	jp _sort_directory_3
_sort_directory_4:
	ld a,(ix+$04)
	and $01
	jp nz,_sort_directory_1
_sort_directory_2:
_sort_directory_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void debug_new_line()
debug_new_line:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,$0a
	push af
	call debug_print_char
	pop de
_debug_new_line_end:
	pop ix
	ret
;; void debug_print_int32(byte* i)
debug_print_int32:
	push ix
	ld ix,$0000
	add ix,sp
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0003
	add hl,de
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0002
	add hl,de
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld de,$0000
	add hl,de
	ld a,(hl)
	push af
	call debug_print_byte
	pop de
_debug_print_int32_end:
	pop ix
	ret
;; void debug_print(byte* str)
debug_print:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
_debug_print_3:
	ld l,(ix+$07)
	ld h,(ix+$08)
	ld a,(hl)
	ld (ix+$00),a
	and a
	jr z,_debug_print_4
_debug_print_6:
	ld a,(ix+$00)
	push af
	call debug_print_char
	pop de
	ld l,(ix+$07)
	ld h,(ix+$08)
	inc hl
	ld (ix+$07),l
	ld (ix+$08),h
	jp _debug_print_3
_debug_print_4:
_debug_print_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void debug_print_chars(byte n, byte* str)
debug_print_chars:
	push ix
	ld ix,$0000
	add ix,sp
	push bc
	ld a,(ix+$07)
	ld b,a
_debug_print_chars_1:
	ld l,(ix+$04)
	ld h,(ix+$05)
	ld a,(hl)
	push af
	call debug_print_char
	pop de
	ld l,(ix+$04)
	ld h,(ix+$05)
	inc hl
	ld (ix+$04),l
	ld (ix+$05),h
	djnz _debug_print_chars_1
	pop bc
_debug_print_chars_2:
_debug_print_chars_end:
	pop ix
	ret
;; byte music_read_byte()
music_read_byte:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld hl,(music_pointer)
	ld a,(hl)
	ld (ix+$00),a
	ld hl,(music_pointer)
	inc hl
	ld (music_pointer),hl
	ld a,(ix+$00)
_music_read_byte_end:
	ld sp,iy
	pop iy
	pop ix
	ret
;; void music_stop()
music_stop:
	push ix
	ld ix,$0000
	add ix,sp
_music_stop_end:
	pop ix
	ret
;; void music_start()
music_start:
	push ix
	ld ix,$0000
	add ix,sp
_music_start_end:
	pop ix
	ret
;; void music_on_irq()
music_on_irq:
	push ix
	push iy
	ld iy,$0000
	add iy,sp
	ld ix,$ffff
	add ix,sp
	ld sp,ix
	ld a,(music_on)
	and $01
	jr z,_music_on_irq_1
	call music_read_byte
	ld (ix+$00),a
	sub $ff
	jr nz,_music_on_irq_3
	call music_start
	jr _music_on_irq_4
_music_on_irq_3:
	ld a,(ix+$00)
	and a
	jr z,_music_on_irq_5
	push bc
	ld a,(ix+$00)
	ld b,a
_music_on_irq_7:
	call music_read_byte
	push af
	call psg_write
	pop de
	djnz _music_on_irq_7
	pop bc
_music_on_irq_8:
_music_on_irq_5:
_music_on_irq_6:
_music_on_irq_4:
_music_on_irq_1:
_music_on_irq_2:
_music_on_irq_end:
	ld sp,iy
	pop iy
	pop ix
	ret
int32_of_word:
	push ix
	ld ix,0
	add ix,sp
	ld e,(ix+4)
	ld d,(ix+5)
	ld l,(ix+6)
	ld h,(ix+7)
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	xor a
	ld (hl),a
	inc hl
	ld (hl),a
	pop ix
	ret



int32_add_byte:
	push ix
	ld ix,0
	add ix,sp
	ld a,(ix+5)
	ld l,(ix+6)
	ld h,(ix+7)

	add a,(hl)
	ld (hl),a

	inc hl
	xor a
	adc a,(hl)
	ld (hl),a

	inc hl
	xor a
	adc a,(hl)
	ld (hl),a

	inc hl
	xor a
	adc a,(hl)
	ld (hl),a

	pop ix
	ret



int32_add_word:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+6)
	ld h,(ix+7)

	ld a,(ix+4)
	add (hl)
	ld (hl),a

	inc hl
	ld a,(ix+5)
	adc a,(hl)
	ld (hl),a

	inc hl
	xor a
	adc a,(hl)
	ld (hl),a

	inc hl
	xor a
	adc a,(hl)
	ld (hl),a

	pop ix
	ret



int32_add_int32:
	push ix
	ld ix,0
	add ix,sp
	ld e,(ix+4)
	ld d,(ix+5)
	ld l,(ix+6)
	ld h,(ix+7)

	ld a,(de)
	add (hl)
	ld (hl),a

	inc de
	inc hl
	ld a,(de)
	adc a,(hl)
	ld (hl),a

	inc de
	inc hl
	ld a,(de)
	adc a,(hl)
	ld (hl),a

	inc de
	inc hl
	ld a,(de)
	adc a,(hl)
	ld (hl),a

	pop ix
	ret


int32_srl:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+4)
	ld h,(ix+5)

	inc hl
	inc hl
	inc hl
	srl (hl)
	dec hl
	rl (hl)
	dec hl
	rl (hl)
	dec hl
	rl (hl)

	pop ix
	ret


int32_sla:
	push ix
	ld ix,0
	add ix,sp
	ld l,(ix+4)
	ld h,(ix+5)

	sla (hl)
	inc hl
	rl (hl)
	inc hl
	rl (hl)
	inc hl
	rl (hl)

	pop ix
	ret

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
	
spi_write0:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	out ($c0),a
	pop ix
	ret

spi_write1:
	push ix
	ld ix,$0000
	add ix,sp
	ld a,(ix+$05)
	out ($c1),a
	pop ix
	ret

spi_read0:
	in a,($00)
	ret

spi_read1:
	in a,($01)
	ret

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
;	push af
;	call console_print_byte
;	pop af
	pop ix
	ret

spi_send_byte:
	push ix
	ld ix,$0000
	add ix,sp
;	push af
;	call console_print_byte
;	pop af
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
palette_data:
db $20,$33,$30,$3f,$00,$33,$03,$33,$03,$08,$33,$33,$1b,$33,$33,$3f
db $20,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$0f







_print_dir_entry_62:
	db "[",0
_print_dir_entry_61:
	db " ",0
_print_dir_entry_70:
	db "]",0
_print_dir_entry_69:
	db " ",0
_print_dir_55:
	db "   ",0
_print_dir_58:
	db "              ",0
_main_loop_50:
	db "error while reading file",0
_main_loop_47:
	db "error while reading rom",0

_main_5:
	db "SMS Bootloader v0.91",0
_main_9:
	db "sd initialization error",0
_main_8:
	db "sd card ok",0
_main_13:
	db "fat init error",0
_main_12:
	db "fat init ok",0
_main_16:
	db "error while reading root directory",0













_sd_load_sector_22:
	db "loading address ",0






_sd_init_1:
	db "sd: set speed",0



_fat_open_directory_63:
	db "root",0









_fat_init_3:
	db "error while loading mbr",0
_fat_init_6:
	db "wrong mbr",0
_fat_init_11:
	db "unknown filesystem type (fat16/32 only)",0
_fat_init_14:
	db "error while loading boot sector",0
_fat_init_17:
	db "wrong boot record",0
_fat_init_20:
	db "sector size != 0x200",0
























