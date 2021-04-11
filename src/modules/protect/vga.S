;; 引数
;;   [ebp+8] 読み込みプレーン(下位2bit) 0~3でIRGB
vga_set_read_plane:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;;　レジスタ退避
        push    eax
        push    edx

        ;; 読み込みプレーン選択
        mov     ah, [bp + 8]
        and     ah, 0b11
        mov     al, 0x04
        mov     dx, 0x03CE
        out     dx, ax

        ;;　レジスタ復帰
        pop     edx
        pop     eax

        ;; スタックフレーム破棄
        mov     esp, ebp
        pop     ebp
        ret

;; 引数
;;   [ebp+8] 書き込みプレーン(下位4bit) 各bitでIRGB
vga_set_write_plane:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;;　レジスタ退避
        push    eax
        push    edx

        ;; 書き込みプレーン選択
        mov     ah, [bp + 8]
        and     ah, 0b1111
        mov     al, 0x02
        mov     dx, 0x03C4
        out     dx, ax

        ;;　レジスタ復帰
        pop     edx
        pop     eax

        ;; スタックフレーム破棄
        mov     esp, ebp
        pop     ebp
        ret

;; 引数
;;   [ebp+8]  FONTアドレス
;;   [ebp+12] VRAMアドレス
;;   [ebp+16] 出力プレーン(1byte)
;;   [ebp+20] 背景色+前景色(2byte) ----IRGB---TIRGB
vram_font_copy:
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

        ;; 引数読み込み
        mov     esi, [ebp + 8]
        mov     edi, [ebp + 12]
        movzx   eax, byte [ebp + 16]
        movzx   ebx, word [ebp + 20]

        ;; 前景色マスク
        test    bl, al      ; ZF = 前景色 & プレーン
        setz    dl          ; DH = ZF ? 0x01 : 0x00
        dec     dl          ; 0x00 or 0xFF

        ;; 背景色マスク
        test    bh, al      ; ZF = 背景色 & プレーン
        setz    dh          ; DH = ZF ? 0x01 : 0x00
        dec     dh          ; 0x00 or 0xFF

        ;; 8x16ビットフォントコピー
        cld
        mov     ecx, 16
.10L:
        ;; フォントマスク作成
        lodsb               ; AL = *ESI++
        mov     ah, al
        not     ah          ; AH = not AL

        ;; 前景
        and     al, dl

        ;; 背景
        test    ebx, 0x0010
        jz      .11F
        and     ah, [edi]
        jmp     .11E
.11F:
        and     ah, dh
.11E:
        ;; 前景+背景
        or      al, ah

        ;; VRAMに書き込み
        mov     [edi], al
        add     edi, 80
        loop    .10L
.10E:        

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
