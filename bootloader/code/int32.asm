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

