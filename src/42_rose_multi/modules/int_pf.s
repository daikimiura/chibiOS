int_pf:
        push    ebp
        mov     ebp, esp

        pusha
        push    ds
        push    es

        mov     ax, 0x0010
        mov     ds, ax
        mov     es, ax

        mov     eax, cr2
        ; jmp     .10F ; ページフォルトでint_stopされるか確認
        and     eax, ~0x0FFF
        cmp     eax, 0x0010_7000
        jne     .10F

        mov     [0x0010_6000 + 0x107 * 4], dword 0x0010_7007 ; ページの有効化
        cdecl   memcpy, 0x0010_7000, DRAW_PARAM, rose_size
        jmp     .10E 
.10F:
        add     esp, 4
        add     esp, 4
        popa
        pop     ebp

        pushf
        push    cs
        push    int_stop

        mov     eax, .s0
        iret
.10E:
        pop     es
        pop     ds
        popa

        mov     esp, ebp
        pop     ebp

        ; エラーコードの破棄
        add     esp, 4
        iret

.s0     db      " < PAGE FAULT > ", 0