%include "./include/define.S"
%include "./include/macro.S"

[BITS 16]

entry:
        jmp     ipl
        ;; BIOS Parameter Block
        times   90 - ($ - $$) db 0x90

ipl:    ;; Initial Program Loader
        cli
        ;; セグメントレジスタの初期化
        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        ;; スタックポインタの設定
        mov     sp, BOOT_LOAD
        sti

        ;; ブートドライブを保存
        mov     [BOOT + drive.no], dl

        ;; ブートメッセージ表示
        cdecl   puts, .s0

        ;; 残りのセクタをすべて読み込む
        mov     bx, BOOT_SECT - 1
        mov     cx, BOOT_LOAD + SECT_SIZE
        cdecl   read_chs, BOOT, bx, cx
        ;; セクタの読み込みに失敗したら再起動
        cmp     ax, bx
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:
        ;; 次のステージへ移行
        jmp     stage_2

.s0:    db      "Booting...", 0x0A, 0x0D, 0x00
.e0:    db      "Err:sector read", 0x00

;; 2バイト境界に配置
ALIGN 2, db 0x00
;; ブートドライブに関する情報
BOOT:
istruc drive
    at drive.no,   dw 0 ; ドライブ番号
    at drive.cyln, dw 0 ; C:シリンダ
    at drive.head, dw 0 ; H:ヘッド
    at drive.sect, dw 2 ; S:セクタ
iend

;; ブートセクタで使うモジュール
%include "./modules/real/puts.S"
%include "./modules/real/reboot.S"
%include "./modules/real/read_chs.S"

        ;; ブートフラグ(先頭512バイトの終了)
        times   510 - ($ - $$) db 0x00
        db      0x55, 0xAA



;; リアルモード時に取得した情報
FONT:
.seg:   dw      0
.off:   dw      0
ACPI_DATA:
.adr:   dd      0 ; ACPI data address
.len:   dd      0 ; ACPI data length

;; 512バイト以降のモジュール
%include "./modules/real/itoa.S"
%include "./modules/real/get_drive_param.S"
%include "./modules/real/get_font_adr.S"
%include "./modules/real/get_mem_info.S"
%include "./modules/real/kbc.S"
%include "./modules/real/read_lba.S"

stage_2:
        cdecl   puts, .s0

        ;; ドライブ情報を取得
        cdecl   get_drive_param, BOOT
        ;; ドライブ情報を取得に失敗したら再起動
        cmp     ax, 0
.10Q:   jne     .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:
        ;; ドライブ情報を表示
        mov     ax, [BOOT + drive.no]
        cdecl   itoa, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]
        cdecl   itoa, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]
        cdecl   itoa, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]
        cdecl   itoa, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1

        ;; 次のステージへ移行
        jmp     stage_3rd

.s0:    db      "=== 2nd stage ===", 0x0A, 0x0D, 0x00
.s1:    db      " Drive:0x"
.p1:    db      "--, C:0x"
.p2:    db      "----, H:0x"
.p3:    db      "--, S:0x"
.p4:    db      "--", 0x0A, 0x0D, 0x00
.e0:    db      "Can't get drive parameter.", 0x00



stage_3rd:
        cdecl   puts, .s0

        ;; BIOSのFONTデータのアドレスを保存する
        cdecl   get_font_adr, FONT
        cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ;; メモリ情報の取得
        cdecl   get_mem_info

        ;; ACPIアドレス表示
        mov     eax, [ACPI_DATA.adr]
        cdecl   itoa, ax, .p4, 4, 16, 0b0100
        shr     eax, 16
        cdecl   itoa, ax, .p3, 4, 16, 0b0100
        cdecl   puts, .s2
        
        jmp     stage_4

.s0:    db      "=== 3rd stage ===", 0x0A, 0x0D, 0x00
.s1:    db      " Font Address="
.p1:    db      "----:"
.p2:    db      "----", 0x0A, 0x0D, 0x00
.s2:    db      " ACPI Address="
.p3:    db      "----"
.p4:    db      "----", 0x0A, 0x0D, 0



stage_4:
        cdecl   puts, .s0

        cli
        cdecl   KBC_Cmd_Write, 0xAD     ; キーボード無効化
        cdecl   KBC_Cmd_Write, 0xD0     ; 出力ポート読み出し
        cdecl   KBC_Data_Read, .key
        mov     bl, [.key]
        or      bl, 0x02                ; A20ゲート有効化
        cdecl   KBC_Cmd_Write, 0xD1     ; 出力ポート書き込み
        cdecl   KBC_Data_Write, bx
        cdecl   KBC_Cmd_Write, 0xAE     ; キーボード有効化
        sti

        cdecl   itoa, bx, .p0, 4, 16, 0b0100
        cdecl   puts, .s1

        jmp     stage_5

.s0:    db      "=== 4th stage ===", 0x0A, 0x0D, 0x00
.s1:    db      " A20 Gate Enabled:"
.p0:    db      "----", 0x0A, 0x0D, 0x00
.key:   dw      0



stage_5:
        cdecl   puts, .s0

        ;; カーネルの読み込み
        cdecl   read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
        cmp     ax, KERNEL_SECT
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        jmp     stage_6

.s0:    db      "=== 5th stage ===", 0x0A, 0x0D, 0x00
.e0:    db      " Failure load kernel...", 0x0A, 0x0D, 0x00



stage_6:
        cdecl   puts, .s0

;        ;; ユーザ入力待ち
;.10L:   mov     ah, 0x00
;        int     0x16
;        cmp     al, ' '
;        jne     .10L
        
        ;; ビデオモード設定
        mov     ax, 0x0012
        int     0x10
        
        jmp     stage_7

.s0:    db      "=== 6th stage ===", 0x0A, 0x0D
        db      " [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0



ALIGN 4, db 0
;; Global Descriptor Table
GDT:    dq      0x0000000000000000
;; CODE 4G
;;  BASE=0x0000_0000
;; LIMIT=0xF_FFFF
;;     G=1
;;     D=1
;;   AVL=0
;;     P=1
;;   DPL=0
;;    DT=1
;;  Type=0xA (実行/リード)
.cs:    dq      0x00CF9A000000FFFF
;; DATA 4G
;;  BASE=0x0000_0000
;; LIMIT=0xF_FFFF
;;     G=1
;;     D=1
;;   AVL=0
;;     P=1
;;   DPL=0
;;    DT=1
;;  Type=0x2 (データRW)
.ds:    dq      0x00CF92000000FFFF
.gdt_end:

;; GDTセレクタ
SEL_CODE equ .cs - GDT               ; CSセレクタ
SEL_DATA equ .ds - GDT               ; DSセレクタ

;; GDTRへロードするデータ
GDTR:   dw      GDT.gdt_end - GDT -1 ; テーブルサイズ
        dd      GDT                  ; ベースアドレス

;; IDTRへロードするデータ(空)
IDTR:   dw      0
        dd      0

stage_7:
        cli

        lgdt    [GDTR]
        lidt    [IDTR]

        ;; PEビットをセット
        mov     eax, cr0
        or      ax, 1
        mov     cr0, eax

        ;; 先読みをクリア
        jmp     $ + 2

        ;; セグメント間ジャンプ
[BITS 32]
        DB      0x66
        jmp     SEL_CODE:CODE_32 ; CSにセレクタをセット



CODE_32:
        mov     ax, SEL_DATA
        mov     ds, ax           ; DSにセレクタをセット
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax
        
        ;; カーネルを上位メモリにコピーする
        mov     ecx, (KERNEL_SIZE) / 4
        mov     esi, BOOT_END
        mov     edi, KERNEL_LOAD
        cld
        rep movsd

        ;; カーネルの先頭にジャンプ
        jmp     KERNEL_LOAD

        
        ;; パディング
        times   BOOT_SIZE - ($ - $$) db 0x00
