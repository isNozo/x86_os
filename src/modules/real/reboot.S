;; BIOSコール 0x16 Keyboard services
;;   AH = Function
;; BIOSコール 0x19 Reboot
reboot:
        cdecl   puts, .s0
.10L:
        ;; スペースを読み込むまでループ
        mov     ah, 0x10    ; キーボード読み込み
        int     0x16
        cmp     al, ' '
        jne     .10L

        ;; リブートの実行
        cdecl	puts, .s1
        int     0x19

.s0	db	0x0A, 0x0D, "Push SPACE key to reboot...", 0x00
.s1	db	0x0A, 0x0D, 0x0A, 0x0D, 0x00
