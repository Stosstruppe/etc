;z80asm -b -oplay.com play.asm

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
	ld	hl, fseq
	or	(hl)
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

	ld	hl, (pseq)
	ld	a, (hl)
	or	a
	jr	nz, hook1

	dec	a
	ld	(fseq), a	; 終了フラグ
	jr	htimi
hook1:
	sub	60
	ld	l, a
	ld	h, 0
	add	hl, hl
	ld	de, divrat
	add	hl, de
	sound	0, (hl)		; Ch.A 音程分周比 L 8bit
	inc	hl
	sound	1, (hl)		; Ch.A 音程分周比 H 8bit
	sound	13, 0		; エンベロープ波形
	ld	hl, (pseq)
	inc	hl
	ld	a, (hl)
	ld	(tick), a
	inc	hl
	ld	(pseq), hl
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

; 分周比テーブル(division ratio)
divrat:	dw	$01ac,$0194,$017d,$0168,$0153,$0140	; C4(60)
	dw	$012e,$011d,$010d,$00fe,$00f0,$00e3
	dw	$00d6,$00ca,$00be,$00b4,$00aa,$00a0	; C5(72)

; sequence
seq:	db	74,24, 73,18, 71,6, 69,36, 67,12
	db	66,24, 64,24, 62,36, 69,12
	db	71,36, 71,12, 73,36, 73,12
	db	74,84, 0,8
pseq:	dw	seq	; シーケンスポインタ
fseq:	db	0	; 終了フラグ
