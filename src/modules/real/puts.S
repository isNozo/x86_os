puts:
	push	bp
	mov	bp, sp

	;; save regs
	push	ax
	push	bx
	push	si

	mov	si, [bp + 4]	; SI = &str
	mov	ah, 0x0E
	mov	bx, 0x0000
	cld
.10L:
	lodsb			; AL = *SI++
	cmp	al, 0
	je	.10E
	int	0x10
	jmp	.10L
.10E:
	;; restore regs
	pop	si
	pop	bx
	pop	ax

	mov	sp, bp
	pop	bp
	ret
