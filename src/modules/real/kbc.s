KBC_data_write:
        push    bp
        mov     bp, sp

        push    cx

        mov     cx, 0
.10L:
        in      al, 0x64
        test    al, 0x02
        loopnz  .10L

        cmp     cx, 0
        jz      .20E

        mov     al, [bp + 4] ; 書き込みたいデータ
        out     0x60, al
.20E:
        mov     cx, ax

        pop     cx

        mov     sp, bp
        pop     bp

        ret

KBC_data_read:
        push    bp
        mov     bp, sp

        push    cx

        mov     cx, 0
.10L:
        in      al, 0x64
        test    al, 0x01
        loopnz  .10L

        cmp     cx, 0
        jz      .20E

        mov     al, 0x00
        in      al, 0x60

        mov     di, [bp + 4] ; 読み込みデータ格納アドレス
        mov     [di + 0], ax
.20E:
        mov     cx, ax

        pop     cx

        mov     sp, bp
        pop     bp

        ret

KBC_cmd_write:
        push    bp
        mov     bp, sp

        push    cx

        mov     cx, 0
.10L:
        in      al, 0x64
        test    al, 0x02
        loopnz  .10L

        cmp     cx, 0
        jz      .20E

        mov     al, [bp + 4] ; 書き込みたいコマンド
        out     0x64, al
.20E:
        mov     cx, ax

        pop     cx

        mov     sp, bp
        pop     bp

        ret