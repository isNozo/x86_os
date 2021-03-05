get_mem_info:
		;; レジスタの保存
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	si
		push	di
		push	bp

		cdecl	puts, .s0						; // ヘッダを表示

		mov		bp, 0							; lines = 0; // 行数
		mov		ebx, 0							; index = 0; // インデックスを初期化
.10L:											; do
												; {
		mov		eax, 0x0000E820					;   EAX   = 0xE820
												;   EBX   = インデックス
		mov		ecx, E820_RECORD_SIZE			;   ECX   = 要求バイト数
		mov 	edx, 'PAMS'						;   EDX   = 'SMAP';
		mov		di, .b0							;   ES:DI = バッファ
		int		0x15							;   BIOS(0x15, 0xE820);

		; コマンドに対応か？
		cmp		eax, 'PAMS'						;   if ('SMAP' != EAX)
		je		.12E							;   {
		jmp		.10E							;     break; // コマンド未対応
.12E:											;   }

		; エラー無し？							;   if (CF)
		jnc		.14E							;   {
		jmp		.10E							;     break; // エラー発生
.14E:											;   }
		; 1レコード分のメモリ情報を表示
		cdecl	puts, .s1						; // フッダを表示

		; ACPI dataのアドレスを取得
		mov		eax, [di + 16]					;   EAX = レコードタイプ;
		cmp		eax, 3							;   if (3 == EAX) // ACPI data
		jne		.15E							;   {
												;     
		mov		eax, [di +  0]					;     EAX   = BASEアドレス;
		mov		[ACPI_DATA.adr], eax			;     ACPI_DATA.adr = EAX;
												;     
		mov		eax, [di +  8]					;     EAX   = Length;
		mov		[ACPI_DATA.len], eax			;     ACPI_DATA.len = EAX;
.15E:											;   }
		cmp		ebx, 0							;   
		jne		.10L							; }
.10E:											; while (0 != EBX);

		cdecl	puts, .s1						; // フッダを表示
	
		;; レジスタの復帰
		pop		bp
		pop		di
		pop		si
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		ret

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
		db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	db " <more...>", 0
.s3:	db 0x0D, "          ", 0x0D, 0

ALIGN 4, db 0
.b0:	times E820_RECORD_SIZE db 0
