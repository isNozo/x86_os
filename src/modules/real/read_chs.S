;; BIOSコール 0x13 Low Level Disk Services
;;   AH = 読み込み命令
;;   AL = 読み込みセクタ数
;;   CX = シリンダ/セクタ
;;   DH = ヘッド位置
;;   DL = ドライブ番号
;;   BX = オフセット
;; 引数
;;   [bp+4] driv構造体アドレス
;;   [bp+6] セクタ数
;;   [bp+8] コピー先アドレス
read_chs:
        ;; スタックフレーム構築
        push    bp
        mov     bp, sp

        ;; ローカル変数
        push    3       ; [bp-2] リトライ回数
        push    0       ; [bp-4] 読み込みセクタ数

        ;; レジスタ退避
        push    bx
        push    cx
        push    dx
        push    es
        push    si

        ;; CXレジスタの設定
        ;;（BIOSコールの呼び出しに適した形に変換）
        ;;
        ;; | CH            | CL            |
        ;; |7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|
        ;; | cylnder           | sector    |
        ;; |7|6|5|4|3|2|1|0|9|8|5|4|3|2|1|0|
        mov     si, [bp + 4]
        mov     ch, [si + drive.cyln + 0]   ; CH   = シリンダ番号（下位バイト）
        mov     cl, [si + drive.cyln + 1]   ; CL   = シリンダ番号（上位バイト）
        shl     cl, 6                       ; CL <<= 6; // 最上位2ビットにシフト
        or      cl, [si + drive.sect]       ; CL  |= セクタ番号;

        ;; セクタ読み込み
        mov     dh, [si + drive.head]       ; DH = ヘッド番号;
        mov     dl, [si + drive.no]         ; DL = ドライブ番号;
        mov     ax, 0x0000                  ; AX = 0x0000;
        mov     es, ax                      ; ES = セグメント
        mov     bx, [bp + 8]                ; BX = コピー先;

.10L:
        mov     ah, 0x02
        mov     al, [bp + 6]
        int     0x13
        jnc     .11E
        mov     al, 0x00
        jmp     .10E
.11E:
        cmp     al, 0
        jne     .10E
        mov     ax, 0x0000
        dec     word [bp - 2]
        jnz     .10L
.10E:
        mov     ah, 0x00

        ;; レジスタ復帰
        pop     si
        pop     es
        pop     dx
        pop     cx
        pop     bx

        ;; スタックフレーム破棄
        mov     sp, bp
        pop     bp
        ret
