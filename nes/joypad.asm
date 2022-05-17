;asm6 joypad.asm joypad.nes

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
	sta	$2006		; VRAMアドレス
	lda	#$00
	sta	$2006
	ldx	#$00
	ldy	#$10
-:
	lda	palettes, x
	sta	$2007		; VRAMアクセス
	inx
	dey
	bne	-

	; スクリーンon
	lda	#%00001000
	sta	$2000		; PPU制御1
	lda	#%00001110
	sta	$2001		; PPU制御2

mainloop:
	; VBlank待ち
-:
	lda	$2002		; PPUステータス
	bmi	-
-:
	lda	$2002
	bpl	-

	lda	#$01
	sta	$4016		; ジョイパッド1
	lda	#$00
	sta	$4016

	lda	#$21
	sta	$2006		; VRAMアドレス
	lda	#$cc
	sta	$2006
	ldy	#8
-:
	lda	$4016
	and	#$01
	ora	#$30
	sta	$2007		; VRAMアクセス
	dey
	bne	-

	; スクロール設定
	lda	#$00
	sta	$2005		; スクロール
	sta	$2005
	jmp	mainloop

palettes:
	db	$0f, $00, $10, $20
	db	$0f, $06, $16, $26
	db	$0f, $08, $18, $28
	db	$0f, $0a, $1a, $2a

	org	$fffa
	dw	0
	dw	Reset
	dw	0

	incbin character.chr
