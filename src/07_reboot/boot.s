        BOOT_LOAD       equ     0x7C00 ; ブートプログラムのロード位置
        ORG     BOOT_LOAD

%include        "../include/macro.s"

entry:
        jmp     ipl
        times   90 - ($ - $$) db 0x90 ; BPB(90 byte)をNOP命令で埋める

ipl:
        cli ; 割り込み禁止

        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti ; 割り込み許可

        mov     [BOOT.DRIVE], dl ; ブートドライブを保存

        ; 文字列の表示
        cdecl   puts, .s0 

        cdecl   reboot

        jmp     $

.s0:    db      "Booting...", 0x0A, 0x0D, 0x00
.s1:    db      "--------", 0x0A, 0x0D, 0x00

ALIGN   2, db 0
BOOT:
.DRIVE:         dw      0

%include        "../modules/real/puts.s"
%include        "../modules/real/itoa.s"
%include        "../modules/real/reboot.s"

        times   510 - ($ - $$) db 0x00
        db      0x55, 0xAA