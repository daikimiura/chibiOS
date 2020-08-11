itoa:
        push    ebp
        mov     ebp, esp

        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     eax, [ebp + 8] ; 数値
        mov     esi, [ebp + 12] ; バッファアドレス
        mov     ecx, [ebp + 16] ; 残りバッファサイズ
        
        mov     edi, esi ; // バッファの最後尾
        add     edi, ecx ; dst = &dst[size - 1]
        dec     edi

        mov     ebx, [ebp + 24] ; オプション(flags)
        
        ; 符号付き判定
        test    ebx, 0b0001
.10Q:   
        je      .10E
        cmp     eax, 0
.12Q:   
        jge     .12E
        or      ebx, 0b0010
.12E:
.10E:

        ; 符号出力判定
        test    ebx, 0b0010
.20Q:   
        je      .20E
        cmp     eax, 0
.22Q:   
        jge     .22F
        neg     eax
        mov     [esi], byte '-'
        jmp     .22E
.22F:   
        mov     [esi], byte '+'
.22E:   
        dec     ecx
.20E:

        ; ASCII変換
        mov     ebx, [ebp + 20] ; 基数
.30L:
        mov     edx, 0
        div     ebx

        mov     esi, edx
        mov     dl, byte [.ascii + esi]

        mov     [edi], dl
        dec     edi

        cmp     eax, 0
        loopnz  .30L
.30E:

        ; 空欄を埋める
        cmp     ecx, 0
.40Q:
        je      .40E
        mov     al, ' '
        cmp     [ebp + 12], word 0b0100
.42Q:
        jne     .42E
        mov     al, '0'
.42E:   
        std
        rep stosb
.40E:

        ; レジスタの復帰
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        mov     esp, ebp
        pop     ebp

        ret

.ascii:
         db     "0123456789ABCDEF"