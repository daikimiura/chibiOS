read_chs:
        push    bp
        mov     bp, sp
        push    3 ; リトライ回数
        push    0 ; 読み出しセクタ数

        push    bx
        push    cx
        push    dx
        push    es
        push    si

        mov     si, [bp + 4] ; drive構造体のアドレス

        ; cxレジスタの設定
        mov     ch, [si + drive.cyln + 0]
        mov     cl, [si + drive.cyln + 1]
        shl     cl, 6
        or      cl, [si + drive.sect]

        ; セクタ読み込み
        mov     dh, [si + drive.head]
        mov     dl, [si + 0]
        mov     ax, 0x0000
        mov     es, ax ; es = セグメント (0x0000)
        mov     bx, [bp + 8] ; コピー先
.10L:
        mov     ah, 0x02
        mov     al, [bp + 6] ; セクタ数

        int     0x13
        jnc     .11E

        mov     al, 0
        jmp     .10E
.11E:
        cmp     al, 0
        jne     .10E

        mov     ax, 0 ; 戻り値の設定
        dec     word [bp - 2] ; リトライ回数をデクリメント
        jnz     .10L
.10E:
        mov     ah, 0 ; ステータス情報(BIOSコールの戻り値)は破棄

        pop     si
        pop     es
        pop     dx
        pop     cx
        pop     bx

        mov     sp, bp
        pop     bp

        ret
