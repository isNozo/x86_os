;; 引数
;;   [ebp+ 8] X0
;;   [ebp+12] Y0
;;   [ebp+16] X1
;;   [ebp+20] Y1
;;   [ebp+24] 色
draw_rect:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;;　レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi

        mov     eax, [ebp + 8] ; EAX = X0;
        mov     ebx, [ebp +12] ; EBX = Y0;
        mov     ecx, [ebp +16] ; ECX = X1;
        mov     edx, [ebp +20] ; EDX = Y1;
        mov     esi, [ebp +24] ; ESI = 色;

        cmp     eax, ecx
        jl      .10E
        xchg    eax, ecx
.10E:
        cmp     ebx, edx
        jl      .20E
        xchg    ebx, edx
.20E:

        cdecl   draw_line, eax, ebx, ecx, ebx, esi
        cdecl   draw_line, eax, ebx, eax, edx, esi
        cdecl   draw_line, eax, edx, ecx, edx, esi
        cdecl   draw_line, ecx, ebx, ecx, edx, esi

        ;;　レジスタ復帰
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ;; スタックフレーム破棄
        mov     esp, ebp
        pop     ebp
        ret
