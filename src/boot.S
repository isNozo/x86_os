%include "./include/macro.S"

	BOOT_LOAD equ 0x7C00	; Start address of boot program
	ORG	BOOT_LOAD	
entry:	
	jmp	ipl

	;; BIOS Parameter Block
	times	90 - ($ - $$) db 0x90

ipl:
	cli
	mov	ax, 0x0000
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, BOOT_LOAD
	sti

	mov	[BOOT.DRIVE], dl

	cdecl	putc, word 'A'
	cdecl	putc, word 'B'
	cdecl	putc, word 'C'
	
	jmp	$

ALIGN 2, db 	0x00
BOOT:	
.DRIVE:	dw 	0x0000

%include	"./modules/real/putc.S"
	
	;; Boot flag
	times	510 - ($ - $$) db 0x00
	db 	0x55, 0xAA
