;; ************************************************************************
;;  マクロ
;; ************************************************************************
%include "./include/define.S"
%include "./include/macro.S"

	ORG	BOOT_LOAD

;; ************************************************************************
;;  エントリポイント
;; ************************************************************************
entry:	
	jmp	ipl

	;; BIOS Parameter Block (nop埋め)
	times	90 - ($ - $$) db 0x90

ipl:
	cli
	;; セグメントレジスタの初期化
	mov	ax, 0x0000
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	;; スタックポインタの設定
	mov	sp, BOOT_LOAD
	sti

	;; ---------------------------------------
	;;  ブートドライブ番号を保存
	;; ---------------------------------------
	mov	[BOOT + drive.no], dl		; ブートドライブを保存

	;; ---------------------------------------
	;;  残りのセクタをすべて読み込む
	;; ---------------------------------------
	mov 	bx, BOOT_SECT - 1 		; BX = 残りのブートセクタ数;
	mov 	cx, BOOT_LOAD + SECT_SIZE 	; CX = 次のロードアドレス;
	cdecl	read_chs, BOOT, bx, cx  	; AX = read_chs(BOOT, BX, CX);

	cdecl	itoa, ax, .s0, 2, 10, 0b0001
	cdecl	puts, .s0

	cmp	ax, bx 				; if (AX != 残りのセクタ数)
.10Q:	jz	.10E				; {
.10T:	cdecl	puts, .e0			;   puts(.e0);
	call	reboot				;   reboot(); // 再起動
.10E:						; }

	;; ---------------------------------------
	;;  次のステージへ移行
	;; ---------------------------------------
	jmp	stage_2

.s0	db	"-- sector read", 0x0A, 0x0D, 0x00
.e0	db	"Err:sector read", 0x00

;; ************************************************************************
;;  ブートドライブに関する情報
;; ************************************************************************
BOOT:
	istruc drive
	    at drive.no,   dw 0		; ドライブ番号
	    at drive.cyln, dw 0 	; C:シリンダ
	    at drive.head, dw 0 	; H:ヘッド
	    at drive.sect, dw 2 	; S:セクタ
	iend

;; ************************************************************************
;;  モジュール
;; ************************************************************************
%include	"./modules/real/puts.S"
%include	"./modules/real/itoa.S"
%include	"./modules/real/reboot.S"
%include	"./modules/real/read_chs.S"

;; ************************************************************************
;;  ブートフラグ
;; ************************************************************************
	times	510 - ($ - $$) db 0x00
	db 	0x55, 0xAA

;; ************************************************************************
;;  リアルモード時に取得した情報
;; ************************************************************************
FONT:
.seg:	dw 0
.off:	dw 0

ACPI_DATA:
.adr:	dd 0			; ACPI data address
.len:	dd 0			; ACPI data length
;; ************************************************************************
;;  モジュール（先頭512バイト以降に配置）
;; ************************************************************************
%include	"./modules/real/get_drive_param.S"
%include	"./modules/real/get_font_adr.S"
%include	"./modules/real/get_mem_info.S"

;; ************************************************************************
;;  ブート処理の第2ステージ
;; ************************************************************************
stage_2:
	cdecl	puts, .s0

	;; ---------------------------------------
	;;  ドライブ情報を取得
	;; ---------------------------------------
	cdecl	get_drive_param, BOOT 		; get_drive_param(DX, BOOT.CYLN);
	cmp	ax, 0		    		; if (0 == AX)
.10Q:	jne	.10E		    		; {
.10T:	cdecl	puts, .e0	    		;   puts(.e0);
	call	reboot		    		;   reboot(); // 再起動
.10E:						; }

	;; ---------------------------------------
	;;  ドライブ情報を表示
	;; ---------------------------------------
	mov	ax, [BOOT + drive.no]		; AX = ブートドライブ;
	cdecl	itoa, ax, .p1, 2, 16, 0b0100	;
	mov	ax, [BOOT + drive.cyln]		;
	cdecl	itoa, ax, .p2, 4, 16, 0b0100	;
	mov	ax, [BOOT + drive.head]		; AX = ヘッド数;
	cdecl	itoa, ax, .p3, 2, 16, 0b0100	;
	mov	ax, [BOOT + drive.sect]		; AX = トラックあたりのセクタ数;
	cdecl	itoa, ax, .p4, 2, 16, 0b0100	;
	cdecl	puts, .s1

	jmp 	stage_3rd

.s0	db	"=== 2nd stage ===", 0x0A, 0x0D, 0x00
.s1	db	"Drive:0x"
.p1	db	"--, C:0x"
.p2	db	"----, H:0x"
.p3	db	"--, S:0x"
.p4	db	"--", 0x0A, 0x0D, 0x00
.e0 	db	"Can't get drive parameter.", 0x00

;; ************************************************************************
;;  ブート処理の第3ステージ
;; ************************************************************************

stage_3rd:
	cdecl	puts, .s0

	; BIOSのFONTデータのアドレスを保存する
	cdecl 	get_font_adr, FONT

	cdecl	itoa, word [FONT.seg], .p1, 4, 16, 0b0100
	cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100
	cdecl	puts, .s1

	; メモリ情報の取得
	cdecl	get_mem_info
	mov		eax, [ACPI_DATA.adr]

	cmp		eax, 0							; if (EAX)
	je		.10E							; {
	cdecl	itoa, ax, .p4, 4, 16, 0b0100	;   itoa(AX); // 下位アドレスを変換
	shr		eax, 16							;   EAX >>= 16;
	cdecl	itoa, ax, .p3, 4, 16, 0b0100	;   itoa(AX); // 上位アドレスを変換
	cdecl	puts, .s2						;   puts(.s2); // アドレスを表示
.10E:										; }

	jmp	$

.s0	db	"=== 3rd stage ===", 0x0A, 0x0D, 0x00
.s1	db	"Font Address="
.p1	db	"----:"
.p2	db	"----", 0x0A, 0x0D, 0x00

.s2	db	"ACPI Address="
.p3	db	"----"
.p4 db	"----", 0x0A, 0x0D, 0

;; ************************************************************************
;;  パディング
;; ************************************************************************
	times	BOOT_SIZE - ($ - $$) db 0x00
