reboot:
	cdecl	puts, .s0
.10L:
	;; スペースキー入力待ち
	mov	ah, 0x10
	int	0x16
	cmp	al, ' '
	jne	.10L

	cdecl	puts, .s1

	int	0x19		; BIOS call (reboot)

.s0	db	0x0A, 0x0D, "Push SPACE key to reboot...", 0x00
.s1	db	0x0A, 0x0D, 0x0A, 0x0D, 0x00
