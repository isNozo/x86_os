;; 引数
;;   [ebp+ 8] X0
;;   [ebp+12] Y0
;;   [ebp+16] X1
;;   [ebp+20] Y1
;;   [ebp+24] 色
draw_line:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        push    dword 0 ; [ebp -  4] sum
        push    dword 0 ; [ebp -  8] X0
        push    dword 0 ; [ebp - 12] X幅
        push    dword 0 ; [ebp - 16] X増分
        push    dword 0 ; [ebp - 20] Y0
        push    dword 0 ; [ebp - 24] Y幅
        push    dword 0 ; [ebp - 28] Y増分

        ;;　レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ;; 幅 EBX = |X1-X0| ESI = (X1-X0)<0 ? -1 : 1
        mov     eax, [ebp + 8]
        mov     ebx, [ebp + 16]
        sub     ebx, eax
        jge     .10F
        neg     ebx
        mov     esi, -1
        jmp     .10E
.10F:
        mov     esi, 1
.10E:

        ;; 高さ EDX = |Y1-Y0| EDI = (X1-X0)<0 ? -1 : 1
        mov     ecx, [ebp + 12]
        mov     edx, [ebp + 20]
        sub     edx, ecx
        jge     .20F
        neg     edx
        mov     edi, -1
        jmp     .20E
.20F:
        mov     edi, 1
.20E:

        mov     [ebp -  8], eax ; X0
        mov     [ebp - 12], ebx ; X幅
        mov     [ebp - 16], esi ; X増分

        mov     [ebp - 20], ecx ; Y0
        mov     [ebp - 24], edx ; Y幅
        mov     [ebp - 28], edi ; Y増分

        ;; 基準軸 ESI, 相対軸 EDI
        cmp     ebx, edx
        jg      .22F
        lea     esi, [ebp - 20]
        lea     edi, [ebp -  8]
        jmp     .22E
.22F:
        lea     esi, [ebp -  8]
        lea     edi, [ebp - 20]
.22E:

        ;; 繰り返し回数
        mov     ecx, [esi - 4]
        cmp     ecx, 0
        jnz     .23E
        mov     ecx, 1
.23E:

        ;; 線の描画
.30L:
        cdecl   draw_pixel,  dword [ebp -  8], \
                             dword [ebp - 20], \
                             dword [ebp + 24]

        ;; 基本軸座標更新
        mov     eax, [esi - 8]
        add     [esi - 0], eax

        ;; 相対軸座標更新
        mov     eax, [ebp - 4]
        mov     ebx, [esi - 4]
        cmp     eax, ebx
        jl      .31E            ; sum <= 基本軸幅
        sub     eax, ebx        ; sum -= 基本軸幅
        
        mov     ebx, [edi - 8]
        add     [edi - 0], ebx
.31E:
        add     eax, [edi - 4]  ; sum += 相対軸幅
        mov     [ebp - 4], eax
        loop    .30L
.30E:

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