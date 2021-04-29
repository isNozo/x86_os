int_default:
        pushf
        push    cs
        push    int_stop

        mov     eax, .s0
        iret

.s0     db      " <    STOP    > ", 0

int_stop:
        cdecl   draw_str, 25, 15, 0x060F, eax

        ;; スタックデータの取得
        mov     eax, [esp + 0]
        cdecl   itoa, eax, .p0, 8, 16, 0b0100
        mov     eax, [esp + 4]
        cdecl   itoa, eax, .p1, 8, 16, 0b0100
        mov     eax, [esp + 8]
        cdecl   itoa, eax, .p2, 8, 16, 0b0100
        mov     eax, [esp +12]
        cdecl   itoa, eax, .p3, 8, 16, 0b0100

        ;; スタックデータの表示
        cdecl   draw_str, 25, 16, 0x0F04, .s0
        cdecl   draw_str, 25, 17, 0x0F04, .s1
        cdecl   draw_str, 25, 18, 0x0F04, .s2
        cdecl   draw_str, 25, 19, 0x0F04, .s3

        jmp     $

.s0     db      "ESP+ 0:"
.p0     db      "-------- ", 0
.s1     db      "   + 4:"
.p1     db      "-------- ", 0
.s2     db      "   + 8:"
.p2     db      "-------- ", 0
.s3     db      "   +12:"
.p3     db      "-------- ", 0
