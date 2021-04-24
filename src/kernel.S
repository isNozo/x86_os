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

        ;; 文字列描画
        cdecl   draw_str, 25, 14, 0x010F, .s0

        ;; 線描画
        cdecl   draw_line, 100, 100, 0, 0, 0x0F
        cdecl   draw_line, 100, 100, 200, 0, 0x0F
        cdecl   draw_line, 100, 100, 200, 200, 0x0F
        cdecl   draw_line, 100, 100, 0, 200, 0x0F
        cdecl   draw_line, 100, 100, 50, 0, 0x02
        cdecl   draw_line, 100, 100, 150, 0, 0x03
        cdecl   draw_line, 100, 100, 150, 200, 0x04
        cdecl   draw_line, 100, 100, 50, 200, 0x05
        cdecl   draw_line, 100, 100, 0, 50, 0x02
        cdecl   draw_line, 100, 100, 200, 50, 0x03
        cdecl   draw_line, 100, 100, 200, 150, 0x04
        cdecl   draw_line, 100, 100, 0, 150, 0x05
        cdecl   draw_line, 100, 100, 100, 0, 0x0F
        cdecl   draw_line, 100, 100, 200, 100, 0x0F
        cdecl   draw_line, 100, 100, 100, 200, 0x0F
        cdecl   draw_line, 100, 100, 0, 100, 0x0F

        jmp     $

.s0     db      " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0

%include "./modules/protect/vga.S"
%include "./modules/protect/draw_char.S"
%include "./modules/protect/draw_str.S"
%include "./modules/protect/draw_font.S"
%include "./modules/protect/draw_pixel.S"
%include "./modules/protect/draw_line.S"

        times KERNEL_SIZE - ($ - $$) db 0
