;; BIOSコール 0x10 Video Services
;;   AH = Function
;;   AL = Charactor
;;   BH = Page Number
;;   BL = Color
;; 引数
;;   [bp+4] 文字列アドレス
puts:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    ax
        push    bx
        push    si

        mov     si, [bp + 4]
        mov     ah, 0x0E
        mov     bx, 0x0000
        cld
.10L:
        lodsb                   ; AL = *SI++
        cmp     al, 0
        je      .10E
        int     0x10
        jmp     .10L
.10E:
        ;; レジスタ復帰
        pop     si
        pop     bx
        pop     ax

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret
