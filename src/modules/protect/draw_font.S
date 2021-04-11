;; 引数
;;   [ebp+8]  X
;;   [ebp+12] Y
draw_font:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;; レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ;; 引数読み込み
        mov     esi, [ebp + 8]
        mov     edi, [ebp + 12]

        ;; フォント一覧描画
        mov     ecx, 0
.10L:   cmp     ecx, 256
        jae     .10E

        ;; X = ecx % 16 + x
        mov     eax, ecx
        and     eax, 0x0F
        add     eax, esi

        ;; Y = ecx / 16 + y
        mov     ebx, ecx
        shr     ebx, 4
        add     ebx, edi

        mov     edx, ecx
        and     edx, 0x0F
        or      edx, 0x0010

        cdecl   draw_char, eax, ebx, edx, ecx
        
        inc     ecx
        jmp     .10L
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
