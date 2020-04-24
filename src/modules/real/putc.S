putc:
	push	bp
	mov	bp, sp

	;; save regs
	push	ax
	push	bx

	;; BIOS call
	mov	al, [bp + 4]
	mov	ah, 0x0E
	mov	bx, 0x0000
	int	0x10

	;; restore regs
	pop	bx
	pop	ax

	mov	sp, bp
	pop	bp
	ret
