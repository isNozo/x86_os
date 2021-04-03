;; BIOSコール 0x15 Miscellaneous system services
get_mem_info:
        ;; レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    si
        push    di
        push    bp

        ;; メモリ情報の取得
        mov     eax, 0x0000E820
        mov     ecx, E820_RECORD_SIZE
        mov     edx, 'PAMS'
        mov     di, .b0
        int     0x15

        cmp     eax, 'PAMS'
        je      .12E
.12E:
        cdecl   puts, .s0
.10E:
        cdecl   itoa, ax, .p0, 4, 16, 0b0100
        cdecl   puts, .d0

        cdecl   puts, .s1

        ;; レジスタ復帰
        pop     bp
        pop     di
        pop     si
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

.s0:    db      " E820 Memory Map:", 0x0A, 0x0D
        db      " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:    db      " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.d0:    db      "debug:"
.p0:    db      "XXXX", 0xA, 0x0D, 0

ALIGN 4, db 0
.b0:    times E820_RECORD_SIZE db 0xFF
