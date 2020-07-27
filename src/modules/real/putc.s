putc:
        push    bp
        mov     bp, sp

        ; レジスタの保存
        push    ax
        push    bx

        mov     al, [bp + 4] ; 引数(出力文字)を取得
        mov     ah, 0x0E
        mov     bx, 0x0000
        int     0x10

        ; レジスタの復帰
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret