%include "./include/define.S"
%include "./include/macro.S"

        ORG     KERNEL_LOAD

[BITS 32]

kernel:
        jmp     $

        times KERNEL_SIZE - ($ - $$) db 0