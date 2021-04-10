%include "./include/define.S"
%include "./include/macro.S"

[BITS 32]

kernel:
        jmp     $

        times KERNEL_SIZE - ($ - $$) db 0
