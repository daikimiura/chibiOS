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

        ; 次の512バイトを読み込む
        mov     ah, 0x02
        mov     al, 1
        mov     cx, 0x0002 ; シリンダ番号/セクタ番号
        mov     dh, 0x00 ; ヘッド位置
        mov     dl, [BOOT.DRIVE] ; ドライブ位置
        mov     bx, BOOT_LOAD + 512 ; オフセット
        int     0x13
.10Q:  
        jnc     .10E
.10T:
        cdecl   puts, .e0
        call    reboot
.10E:
        
        jmp     stage_2

.s0     db      "Booting...", 0x0A, 0x0D, 0x00
.e0     db      "Error: sector read", 0x0A, 0x0D, 0x00

ALIGN   2, db 0
BOOT:
.DRIVE:         dw      0

%include        "../modules/real/puts.s"
%include        "../modules/real/itoa.s"
%include        "../modules/real/reboot.s"

        times   510 - ($ - $$) db 0x00
        db      0x55, 0xAA

; ブート処理の第二ステージ
stage_2:
        cdecl   puts, .s0
        jmp     $

.s0     db      "2nd stage...", 0x0A, 0x0D, 0x00

        times   (1024 * 8) - ($ - $$)   db 0x00 ; 8K byte