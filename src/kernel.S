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

        cdecl   draw_char, 0, 1, 0x010F, 'A'
        cdecl   draw_char, 1, 1, 0x010F, 'B'
        cdecl   draw_char, 2, 1, 0x010F, 'C'

        cdecl   draw_char, 0, 1, 0x0402, '0'
        cdecl   draw_char, 1, 1, 0x0012, '1'
        cdecl   draw_char, 2, 1, 0x0012, '_'

        jmp     $

ALIGN 4, db 0
FONT_ADR: dd 0

%include "./modules/protect/vga.S"
%include "./modules/protect/draw_char.S"

        times KERNEL_SIZE - ($ - $$) db 0
