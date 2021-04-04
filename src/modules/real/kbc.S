;; 引数
;;   [bp+4] 書き込みデータ
KBC_Data_Write:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    cx

        ;; 書き込み可能かチェック
        mov     cx, 0
.10L:
        in      al, 0x64
        test    al, 0x02
        loopnz  .10L

        ;; 未タイムアウトならデータの書き込み
        cmp     cx, 0
        jz      .20E
        mov     al, [bp + 4]
        out     0x60, al        ; データ書き込み
.20E:
        ;; cxを返り値とする
        mov     ax, cx

        ;; レジスタ復帰
        pop     cx

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret

;; 引数
;;   [bp+4] 読み込み先アドレス
KBC_Data_Read:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    cx
        push    di

        ;; 読み込み可能かチェック
        mov     cx, 0
.10L:
        in      al, 0x64
        test    al, 0x01
        loopz  .10L

        ;; 未タイムアウトならデータの書き込み
        cmp     cx, 0
        jz      .20E
        mov     ah, 0x00
        in      al, 0x60        ; データ読み込み
        mov     di, [bp + 4]
        mov     [di + 0], ax
.20E:
        ;; cxを返り値とする
        mov     ax, cx

        ;; レジスタ復帰
        pop     di
        pop     cx

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret

;; 引数
;;   [bp+4] 書き込みデータ
KBC_Cmd_Write:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    cx

        ;; 書き込み可能かチェック
        mov     cx, 0
.10L:
        in      al, 0x64
        test    al, 0x02
        loopnz  .10L

        ;; 未タイムアウトならデータの書き込み
        cmp     cx, 0
        jz      .20E
        mov     al, [bp + 4]
        out     0x64, al        ; コマンド書き込み
.20E:
        ;; cxを返り値とする
        mov     ax, cx

        ;; レジスタ復帰
        pop     cx

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret
