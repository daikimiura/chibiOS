entry:
        jmp ipl
        times 90 - ($ - $$) db 0x90 ; BPB(90 byte)をNOP命令で埋める

ipl:
        jmp $ ; 無限ループ
        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA