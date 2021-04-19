;; 引数
;;   [ebp+8]  X
;;   [ebp+12] Y
;;   [ebp+16] 背景色+前景色(2byte) ----IRGB---TIRGB
;;   [ebp+20] 文字列アドレス
draw_str:
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
        mov     ecx, [ebp + 8]
        mov     edx, [ebp + 12]
        movzx   ebx, word [ebp + 16]
        mov     esi, [ebp + 20]

        cld
.10L:
        lodsb           ; AL = *ESI++
        cmp     al, 0
        je      .10E

        cdecl   draw_char, ecx, edx, ebx, eax

        inc     ecx
        cmp     ecx, 80
        jl      .12E
        mov     ecx, 0
        inc     edx
        cmp     edx, 30
        jl      .12E
        mov     edx, 0
.12E:
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
