;;; 関数呼び出しマクロ
%macro cdecl 1-*.nolist
    %rep %0 - 1
        push    %{-1:-1} ; 引数の右端からスタックにプッシュ
        %rotate -1
    %endrep
    %rotate -1
        call    %1
    %if 1 < %0
        add     sp, (__BITS__ >> 3) * (%0 - 1) ; スタックの解放
    %endif
%endmacro

struc drive
        .no      resw 1 ; ドライブ番号
        .cyln    resw 1 ; シリンダ
        .head    resw 1 ; ヘッド
        .sect    resw 1 ; セクタ
endstruc
