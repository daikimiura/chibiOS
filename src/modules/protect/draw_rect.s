draw_rect:
        push    ebp
        mov     ebp, esp

        mov     eax, [ebp + 8]
        mov     ebx, [ebp + 12]
        mov     ecx, [ebp + 16]
        mov     edx, [ebp + 20]
        mov     esi, [ebp + 24]

        cmp     eax, ecx
        jl      .10E
        xchg    eax, ecx
.10E:
        cmp     ebx, edx
        jl      .20E
        xchg    ebx, edx
.20E:
        ; 矩形を描画
        cdecl   draw_line, eax, ebx, ecx, ebx, esi ; 上線
        cdecl   draw_line, eax, ebx, eax, edx, esi ; 左線
        cdecl   draw_line, eax, edx, ecx, edx, esi ; 下線
        cdecl   draw_line, ecx, ebx, ecx, edx, esi ; 右線

        mov     esp, ebp
        pop     ebp

        ret