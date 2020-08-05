read_lba:
        push    bp
        mov     bp, sp

        push    si

        ; LBA->CHS 変換
        mov     si, [bp + 4]
        mov     ax, [bp + 6]
        cdecl   lba_chs, si, .chs, ax

        mov     al, [si + drive.no]
        mov     [.chs + drive.no], al

        ; CHS方式によるセクタの読み込み
        cdecl   read_chs, .chs, word [bp + 8], word [bp + 10]

        pop     si

        mov     sp, bp
        pop     bp

        ret

ALIGN 2
.chs	times drive_size	db	0