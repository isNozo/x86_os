;; 引数
;;   [ebp+8]  X
;;   [ebp+12] Y
;;   [ebp+16] 前景色(1byte) ----IRGB
draw_pixel:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;;　レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edi

        ;; VRAMアドレス設定
        mov     ecx, [ebp + 12]     ; Y
        shl     ecx, 4
        lea     edi, [ecx * 4 + ecx + 0x000A_0000] ; Y*80 + 0x000A_0000

        mov     ebx, [ebp + 8]      ; X
        mov     ecx, ebx
        shr     ebx, 3
        add     edi, ebx            ; Y*80 + X/8 + 0x000A_0000

        ;; 出力ビットパターン
        and     ecx, 0b0111         ; X = X % 8
        mov     ebx, 0b10000000
        shr     ebx, cl             ; 0b10000000 >> (X % 8)

        ;; 描画色
        movzx   ecx, byte [ebp + 16]

        ;; Bプレーンへの書き込み
        cdecl   vga_set_read_plane, 0
        cdecl   vga_set_write_plane, 0b0001
        cdecl   vram_bit_copy, ebx, edi, 0b0001, ecx
        ;; Gプレーンへの書き込み
        cdecl   vga_set_read_plane, 1
        cdecl   vga_set_write_plane, 0b0010
        cdecl   vram_bit_copy, ebx, edi, 0b0010, ecx
        ;; Rプレーンへの書き込み
        cdecl   vga_set_read_plane, 2
        cdecl   vga_set_write_plane, 0b0100
        cdecl   vram_bit_copy, ebx, edi, 0b0100, ecx
        ;; Iプレーンへの書き込み
        cdecl   vga_set_read_plane, 3
        cdecl   vga_set_write_plane, 0b1000
        cdecl   vram_bit_copy, ebx, edi, 0b1000, ecx

        ;;　レジスタ復帰
        pop     edi
        pop     ecx
        pop     ebx
        pop     eax

        ;; スタックフレーム破棄
        mov     esp, ebp
        pop     ebp
        ret
