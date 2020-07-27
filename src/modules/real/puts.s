puts:
        push    bp
        mov     bp, sp

        push    ax
        push    bx
        push    si

        mov     si, [bp + 4] ; 引数(文字列のアドレス)を取得

        mov     ah, 0x0E
        mov     bx, 0x0000
        cld ; DFレジスタの値を0にする => ストリング命令が実行されたときにアドレスを加算していく(DFが1なら減算)

.10L:
        lodsb
        cmp     al, 0
        je      .10E

        int     0x10
        jmp     .10L

.10E:
        pop     si
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret