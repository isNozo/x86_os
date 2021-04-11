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

        ;; フォント一覧の表示
        cdecl   draw_font, 63, 13

        jmp     $

ALIGN 4, db 0
FONT_ADR: dd 0

%include "./modules/protect/vga.S"
%include "./modules/protect/draw_char.S"
%include "./modules/protect/draw_font.S"

        times KERNEL_SIZE - ($ - $$) db 0
