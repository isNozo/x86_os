%include "./include/define.S"
%include "./include/macro.S"

[BITS 32]

kernel:
        ;; フォントアドレス取得
        mov     esi, BOOT_LOAD + SECT_SIZE
        movzx   eax, word [esi + 0]
        movzx   ebx, word [esi + 2]
        shl     eax, 4
        add     eax, ebx
        mov     [FONT_ADR], eax

        ;; VRAM書き込み設定
        mov     ah, 0x02
        mov     al, 0x02
        mov     dx, 0x03C4
        out     dx, ax

        ;; フォントデータ書き込み
        mov     esi, 'B'
        shl     esi, 4
        add     esi, [FONT_ADR]
        lea     edi, [0x000A_0000]

        mov     ecx, 16
.10L:   movsb
        add     edi, 80-1
        loop    .10L

        jmp     $

ALIGN 4, db 0
FONT_ADR: dd 0

        times KERNEL_SIZE - ($ - $$) db 0
