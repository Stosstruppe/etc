;z80asm -b -osound.com sound.asm

C_STAT	equ	$0b	; Console status

PSLTRG	equ	$a8	; primary slot register

EXPTBL	equ	$fcc1
H_TIMI	equ	$fd9f

sound: macro adr, dat
	ld	a, adr
	out	($a0), a	; アドレスラッチ
	ld	a, dat
	out	($a1), a	; データライト
endm

	org	$0100

	call	sound_init
	call	hook_init
main1:
	ld	c, C_STAT
	call	5
	or	a
	jr	z, main1

	call	hook_term
	ret

sound_init:
	sound	7, %10111110	; ミキシング
	sound	8, $10		; Ch.A 音量／エンベロープ
	sound	11, $00		; エンベロープ周期 L 8bit
	sound	12, $10		; エンベロープ周期 H 8bit
	ret

hook:
	ld	hl, tick
	dec	(hl)
	jr	nz, htimi
	ld	(hl), 30
	sound	0, $ac		; Ch.A 音程分周比 L 8bit
	sound	1, $01		; Ch.A 音程分周比 H 4bit
	sound	13, 0		; エンベロープ波形
htimi:	ds	5
tick:	db	1

hook_init:
	di
	ld	hl, H_TIMI
	ld	de, htimi
	ld	bc, 5
	ldir

	in	a, (PSLTRG)
	rrca
	rrca
	and	$03
	ld	c, a
	ld	b, 0
	ld	hl, EXPTBL
	add	hl, bc
	or	(hl)
	ld	c, a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	and	$0c
	or	c

	ld	ix, H_TIMI
	ld	hl, hook
	ld	(ix+0), $f7	; rst $30
	ld	(ix+1), a
	ld	(ix+2), l
	ld	(ix+3), h
	ld	(ix+4), $c9	; ret
	ei
	ret

hook_term:
	di
	ld	hl, htimi
	ld	de, H_TIMI
	ld	bc, 5
	ldir
	ei
	ret
