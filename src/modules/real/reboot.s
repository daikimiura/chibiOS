reboot:
        cdecl   puts, .s0

.10L:
        mov     ah, 0x10
        int     0x16 ; キー入力待ち

        cmp     al, ' '
        jne     .10L ; スペースキーが押されるまで待つ

        cdecl   puts, .s1 ; 改行

        int     0x19 ; 再起動

.s0:
        db  0x0A, 0x0D, "Push SPACE key to reboot ...", 0
.s1:
        db  0x0A, 0x0D, 0x0A, 0x0D, 0