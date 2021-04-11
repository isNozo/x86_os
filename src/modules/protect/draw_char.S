;; 引数
;;   [ebp+8]  X
;;   [ebp+12] Y
;;   [ebp+16] 背景色+前景色(2byte) ----IRGB---TIRGB
;;   [ebp+20] 文字
draw_char:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;;　レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ;; フォントアドレス設定
        movzx   esi, byte [ebp + 20]
        shl     esi, 4
        add     esi, [FONT_ADR]

        ;; VRAMアドレス設定
        mov     eax, [ebp + 12]
        mov     ebx, 1280
        mul     ebx
        add     eax, [ebp + 8]
        add     eax, 0x000A_0000        ; Y*80*16 + X + 0x000A_0000
        mov     edi, eax

        ;; 描画色
        movzx   ebx, word [ebp + 16]

        ;; Bプレーンへの書き込み
        cdecl   vga_set_read_plane, 0
        cdecl   vga_set_write_plane, 0b0001
        cdecl   vram_font_copy, esi, edi, 0b0001, ebx
        ;; Gプレーンへの書き込み
        cdecl   vga_set_read_plane, 1
        cdecl   vga_set_write_plane, 0b0010
        cdecl   vram_font_copy, esi, edi, 0b0010, ebx
        ;; Rプレーンへの書き込み
        cdecl   vga_set_read_plane, 2
        cdecl   vga_set_write_plane, 0b0100
        cdecl   vram_font_copy, esi, edi, 0b0100, ebx
        ;; Iプレーンへの書き込み
        cdecl   vga_set_read_plane, 3
        cdecl   vga_set_write_plane, 0b1000
        cdecl   vram_font_copy, esi, edi, 0b1000, ebx

        ;;　レジスタ復帰
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ;; スタックフレーム破棄
        mov     esp, ebp
        pop     ebp
        ret
