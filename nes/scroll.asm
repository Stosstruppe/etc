;asm6 scroll.asm scroll.nes

posx	equ	$00

	; iNES header
	db	"NES", $1a
	db	$01	; PRG-ROM
	db	$01	; CHR-ROM
	db	$00
	dsb	9, $00

	base	$c000
Reset:
	sei
	ldx	#$ff
	txs

	; スクリーンoff
	lda	#$00
	sta	$2000
	sta	$2001

	; パレットテーブルへ転送
	lda	#$3f
	sta	$2006
	lda	#$00
	sta	$2006
	ldx	#$00
	ldy	#$10
-:
	lda	palettes, x
	sta	$2007
	inx
	dey
	bne	-

	; ネームテーブルへ転送
	lda	#$21
	sta	$2006
	lda	#$c9
	sta	$2006
	ldx	#$00
	ldy	#12
-:
	lda	string, x
	sta	$2007
	inx
	dey
	bne	-

	; スクリーンon
	lda	#$08
	sta	$2000
	lda	#$1e
	sta	$2001

	lda	#0
	sta	posx

mainloop:
	; VBlank待ち
-:
	lda	$2002		; PPUステータス
	bmi	-
-:
	lda	$2002
	bpl	-

	; スクロール設定
	inc	posx
	lda	posx
	sta	$2005		; スクロール
	lda	#0
	sta	$2005
	jmp	mainloop

palettes:
	db	$0f, $00, $10, $20
	db	$0f, $06, $16, $26
	db	$0f, $08, $18, $28
	db	$0f, $0a, $1a, $2a

string:
	db	"HELLO, WORLD"

	org	$fffa
	dw	0
	dw	Reset
	dw	0

	incbin character.chr
