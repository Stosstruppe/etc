;asm6 sound2.asm sound2.nes

btna	equ	$00
tick	equ	$01

	; iNES header
	db	"NES", $1a
	db	$01	; PRG-ROM
	db	$01	; CHR-ROM
	db	$00
	dsb	9, $00

	base	$c000
Reset:
	lda	#%00000001
	sta	$4015		; 音声チャンネル制御レジスタ
	lda	#%10001000
	sta	$4000		; 矩形波CH1制御レジスタ
	lda	#%00000000
	sta	$4001
;	lda	#84		; 1,790,000/(f*32)-1
;	sta	$4002		; 矩形波CH1周波数値レジスタ

	lda	#$00
	sta	btna
	sta	tick

	lda	#%10001000
	sta	$2000		; PPU制御レジスタ
	lda	#%00000000
	sta	$2001
-:
	jmp	-

VBlank:
	lda	#$01
	sta	$4016
	lda	#$00
	sta	$4016
	lda	$4016		; ジョイパッド1レジスタ
	and	#$01
	tax
	beq	+		; 今のAボタン == 1
	and	btna
	bne	+		; 前のAボタン == 0
	lda	#112
	sta	$4002		; 矩形波CH1周波数値レジスタ
	lda	#(1<<3)
	sta	$4003
	lda	#1
	sta	tick
+:
	stx	btna		; ボタン状態
	lda	tick
	beq	+
	inc	tick
	cmp	#5
	bne	+
	lda	#84
	sta	$4002		; 矩形波CH1周波数値レジスタ
	lda	#(1<<3)
	sta	$4003
+:
	rti

	org	$fffa
	dw	VBlank
	dw	Reset
	dw	0

	incbin character.chr

; 周波数 f=440*2^((n-69)/12)
; 分周比 1,790,000/(f*32)-1
; B4 n71 500Hz 112
; E5 n76 659Hz 84
