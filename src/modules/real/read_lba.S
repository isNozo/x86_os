;; 引数
;;   [bp+4] drive構造体アドレス
;;   [bp+6] LBA(2byte)
;;   [bp+8] セクタ数
;;   [bp+10] コピー先アドレス
read_lba:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    si

        ;; LBA->CHS変換
        mov     si, [bp + 4]
        mov     ax, [bp + 6]
        cdecl   lba_chs, si, .chs, ax

        ;; ドライブ番号のコピー
        mov     al, [si + drive.no]
        mov     [.chs + drive.no], al
        
        ;; セクタの読み込み
        cdecl   read_chs, .chs, word [bp + 8], word [bp + 10]
        
        ;; レジスタ復帰
        pop     si

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret
        
ALIGN 2
.chs:   times drive_size db 0

;; 引数
;;   [bp+4] drive構造体アドレス(変換前)
;;   [bp+6] drive構造体アドレス(変換後)
;;   [bp+8] LBA(2byte)
lba_chs:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; レジスタ退避
        push    ax
        push    bx
        push    dx
        push    si
        push    di
        
        mov     si, [bp + 4]
        mov     di, [bp + 6]

        ;; シリンダ番号 = LBA / (ヘッド数 * セクタ数)
        mov     al, [si + drive.head]
        mul     byte [si + drive.sect]
        mov     bx, ax                  ; BX = ヘッド数 * セクタ数
        mov     dx, 0
        mov     ax, [bp + 8]            ; AX = LBA
        div     bx                      ; DX = DX:AX % BX
                                        ; AX = DX:AX / BX
        mov     [di + drive.cyln], ax

        ;; トラック番号 = シリンダ番号の余り / セクタ数
        ;; セクタ番号 = トラック番号の余り + 1
        mov     ax, dx                  ; AX = シリンダ番号の余り
        div     byte [si + drive.sect]  ; AH = AX % セクタ数
                                        ; AL = AX / セクタ数
        movzx   dx, ah
        inc     dx
        mov     ah, 0x00
        mov     [di + drive.head], ax
        mov     [di + drive.sect], dx
        
        ;; レジスタ復帰
        pop     di
        pop     si
        pop     dx
        pop     bx
        pop     ax

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret
