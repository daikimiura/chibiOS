%include        "../include/macro.s"
%include        "../include/define.s"

        ORG     BOOT_LOAD

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

        mov     [BOOT + drive.no], dl ; ブートドライブを保存

        ; 文字列の表示
        cdecl   puts, .s0 

        ; 残りのセクタを読み込む
        mov     bx, BOOT_SECT - 1 ; 残りのブートセクタ数
        mov     cx, BOOT_LOAD + SECT_SIZE ; 次のロードアドレス

        cdecl   read_chs, BOOT, bx, cx
        
        cmp     ax, bx
.10Q:  
        jz     .10E ; ax == bx (正常に読み出せた)
.10T:
        cdecl   puts, .e0
        call    reboot
.10E:
        jmp     stage_2

.s0     db      "Booting...", 0x0A, 0x0D, 0x00
.e0     db      "Error: sector read", 0x0A, 0x0D, 0x00

ALIGN   2, db 0
; http://www7a.biglobe.ne.jp/~iell/nasm/nasmdoc_2.03j/nasmdoc4.html#section-4.8.9
BOOT:
        istruc  drive
                at drive.no, dw      0
                at drive.cyln, dw      0
                at drive.head, dw       0
                at drive.sect, dw       2
        iend
        

%include        "../modules/real/puts.s"
%include        "../modules/real/reboot.s"
%include        "../modules/real/read_chs.s"

        times   510 - ($ - $$) db 0x00
        db      0x55, 0xAA

; ブート処理の第二ステージ
stage_2:
        cdecl   puts, .s0
        jmp     $

.s0     db      "2nd stage...", 0x0A, 0x0D, 0x00

        times   BOOT_SIZE - ($ - $$)   db 0x00 ; 8K byte