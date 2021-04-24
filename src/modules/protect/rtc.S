;; 引数
;;   [ebp + 8] 時刻データ保存先
rtc_get_time:
        ;; スタックフレーム構築
        push    ebp
        mov     ebp, esp

        ;;　レジスタ退避
        push    eax
        push    ebx

        ;; 時データ取得
        mov     al, 0x04
        out     0x70, al
        in      al, 0x71
        shl     eax, 8

        ;; 分データ取得
        mov     al, 0x02
        out     0x70, al
        in      al, 0x71
        shl     eax, 8

        ;; 秒データ取得
        mov     al, 0x00
        out     0x70, al
        in      al, 0x71

        ;; 時刻データ保存先に格納
        and     eax, 0x00FF_FFFF
        mov     ebx, [ebp + 8]
        mov     [ebx], eax

        ;;　レジスタ復帰
        pop     ebx
        pop     eax

        ;; スタックフレーム破棄
        mov     esp, ebp
        pop     ebp
        ret