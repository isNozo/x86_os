;; BIOSコール 0x15 Miscellaneous system services
get_mem_info:
        ;; レジスタ退避
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    si
        push    di
        push    bp

        ;; ヘッダー表示
        cdecl   puts, .s0

        ;; メモリ情報の取得
        mov     bp, 0
        mov     ebx, 0
.10L:
        mov     eax, 0x0000E820
        mov     ecx, E820_RECORD_SIZE
        mov     edx, 'PAMS'
        mov     di, .b0
        int     0x15

        ;; BIOSコールに対応していない(EAXにSMAPが設定されない)なら中断
        cmp     eax, 'PAMS'
        je      .12E
        jmp     .10E
.12E:
        ;; エラーなら中断
        jnc     .14E
        jmp     .10E
.14E:
        ;; 1レコード分のメモリ情報を表示
        cdecl   put_mem_info, di

        ;; ACPI dataのアドレス取得
        mov     eax, [di + 16]          ; [di+16] レコードタイプ
        cmp     eax, 3
        jne     .15E
        mov     eax, [di + 0]           ; [di+0] BASEアドレス
        mov     [ACPI_DATA.adr], eax
        mov     eax, [di + 8]           ; [di+8] Length
        mov     [ACPI_DATA.len], eax
.15E:
        ;; EBXに次のインデックスが設定される。0なら最終レコード。
        cmp     ebx, 0
        jne     .10L
.10E:
        ;; フッターの表示
        cdecl   puts, .s1

        ;; レジスタ復帰
        pop     bp
        pop     di
        pop     si
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

.s0:    db      " E820 Memory Map:", 0x0A, 0x0D
        db      " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:    db      " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.d0:    db      "debug:"
.p0:    db      "XXXX", 0x0A, 0x0D, 0

ALIGN 4, db 0
.b0:    times E820_RECORD_SIZE db 0xFF


;; 引数
;;   [bp+4] メモリ情報バッファアドレス
put_mem_info:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    bx
        push    si

        mov     si, [bp + 4]

        ; Base(64bit)
        cdecl   itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
        cdecl   itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

        ; Length(64bit)
        cdecl   itoa, word [si +14], .p4 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si +12], .p4 + 4, 4, 16, 0b0100
        cdecl   itoa, word [si +10], .p5 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

        ; Type(32bit)
        cdecl   itoa, word [si +18], .p6 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si +16], .p6 + 4, 4, 16, 0b0100

        cdecl   puts, .s0

        ;; タイプの表示
        mov     bx, [si + 16]
        and     bx, 0b111
        shl     bx, 1
        add     bx, .t0
        cdecl   puts, word [bx]

        ;; レジスタ復帰
        pop     si
        pop     bx

        ;; ステックフレーム破棄
        mov     sp, bp
        pop     bp
        ret

.s0:    db      " "
.p2:    db      "ZZZZZZZZ_"
.p3:    db      "ZZZZZZZZ "
.p4:    db      "ZZZZZZZZ_"
.p5:    db      "ZZZZZZZZ "
.p6:    db      "ZZZZZZZZ", 0

.s4:    db      " (Unknown)", 0x0A, 0x0D, 0
.s5:    db      " (usable)", 0x0A, 0x0D, 0
.s6:    db      " (reserved)", 0x0A, 0x0D, 0
.s7:    db      " (ACPI data)", 0x0A, 0x0D, 0
.s8:    db      " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:    db      " (bad memory)", 0x0A, 0x0D, 0

;; 文字列テーブル
.t0:	dw      .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4