draw_str:
        push    ebp
        mov     ebp, esp

        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     ecx, [ebp + 8] ; 列
        mov     edx, [ebp + 12] ; 行
        movzx   ebx, word [ebp + 16] ; 表示色
        mov     esi, [ebp + 20] ; 文字列のアドレス

        cld

.10L:
        lodsb ; AL = *ESI++
        cmp     al, 0 ; 文字列の最後は0で終端されている
        je      .10E

        cdecl   draw_char, ecx, edx, ebx, eax

        inc     ecx
        cmp     ecx, 80
        jl      .12E
        mov     ecx, 0

        inc     edx
        cmp     edx, 30
        jl      .12E
        mov     edx, 0

.12E:
        jmp     .10L

.10E:
        pop    edi        
        pop    esi
        pop    edx
        pop    ecx
        pop    ebx
        pop    eax


        mov     esp, ebp
        pop     ebp

        ret
        