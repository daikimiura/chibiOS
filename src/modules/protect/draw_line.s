draw_line:
        push    ebp
        mov     ebp, esp

        push    dword 0 ; -4: sum // 相対軸の積算値
        push    dword 0 ; -8: x0 // x座標
        push    dword 0 ; -12: dx // x増分
        push    dword 0 ; -16: inc_x // x座標増分
        push    dword 0 ; -20: y0 // y座標
        push    dword 0 ; -24: dy // y増分
        push    dword 0 ; -28: inc_y // y座標増分

        push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

        ; 幅を計算(x軸)
        mov     eax, [ebp + 8]
        mov     ebx, [ebp + 16]
        sub     ebx, eax
        jge     .10F

        neg     ebx
        mov     esi, -1
        jmp     .10E
.10F:
        mov     esi, 1
.10E:

        ; 高さを計算(y軸)
        mov     ecx, [ebp + 12]
        mov     edx, [ebp + 20]
        sub     edx, ecx
        jge     .20F

        neg     edx
        mov     edi, -1
        jmp     .20E
.20F:
        mov     edi, 1
.20E:
        mov     [ebp -8], eax
        mov     [ebp -12], ebx
        mov     [ebp -16], esi

        mov     [ebp -20], ecx
        mov     [ebp -24], edx
        mov     [ebp -28], edi

        ; 基準軸を決める
        ; 基準軸がesi, 相対軸がedi
        cmp     ebx, edx
        jg      .22F

        lea     esi, [ebp - 20]
        lea     edi, [ebp - 8]

        jmp     .22E
.22F:
        lea     esi, [ebp - 8]
        lea     edi, [ebp - 20]
.22E:

        ; 繰り返し回数(基準軸のドット数)
        mov     ecx, [esi - 4]
        cmp     ecx, 0
        jnz     .30E
        mov     ecx, 1
.30E:
        ; 線を描画
.50L:
%ifdef	USE_SYSTEM_CALL
        mov     eax, ecx

        mov     ebx, [ebp + 24]
        mov     ecx, [ebp - 8]
        mov     edx, [ebp - 20]

        int 0x82

        mov     ecx, eax
%else
        cdecl   draw_pixel, dword [ebp - 8], \
                            dword [ebp - 20], \
                            dword [ebp + 24]
%endif

        ; 基準軸は毎回更新
        mov     eax, [esi - 8] 
        add     [esi - 0], eax

        ; 相対軸の積算が基準軸の積算を超えたら相対軸を更新
        mov     eax, [ebp - 4]
        add     eax, [edi - 4]

        mov     ebx, [esi - 4] ; 基準軸の描画幅
        cmp     eax, ebx
        jl      .52E
        sub     eax, ebx

        ; 相対軸の座標を更新
        mov     ebx, [edi - 8]
        add     [edi - 0], ebx
.52E:
        mov     [ebp - 4], eax
        
        loop    .50L
.50E:

        pop		edi
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

        mov     esp, ebp
        pop     ebp

        ret
