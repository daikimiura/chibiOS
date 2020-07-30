get_font_addr:
        push    bp
        mov     bp, sp

        push    ax
        push    bx
        push    si
        push    es
        push    bp

        mov     si, [bp + 4] ; フォントアドレスの保存先

        ; フォントアドレスの取得
        mov     ax, 0x1130
        mov     bh, 0x06
        int     0x10

        ; フォントアドレスの保存
        mov     [si + 0], es ; セグメント
        mov     [si + 2], bp ; オフセット

        pop     bp
        pop     es
        pop     si
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret