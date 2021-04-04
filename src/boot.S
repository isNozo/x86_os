%include "./include/define.S"
%include "./include/macro.S"

        ORG     BOOT_LOAD

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
.s1:    db      "Drive:0x"
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
        
        jmp     $

.s0:    db      "=== 3rd stage ===", 0x0A, 0x0D, 0x00
.s1:    db      "Font Address="
.p1:    db      "----:"
.p2:    db      "----", 0x0A, 0x0D, 0x00
.s2:    db      "ACPI Address="
.p3:    db      "----"
.p4:    db      "----", 0x0A, 0x0D, 0

        ;; パディング
        times   BOOT_SIZE - ($ - $$) db 0x00
