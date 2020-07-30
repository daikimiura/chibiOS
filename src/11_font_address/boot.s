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

; リアルモード時に取得した情報を分かりやすいアドレスに保存する(0x7C00+512 = 0x7E00 番地)
FONT:
.seg    dw      0
.off    dw      0

; モジュール(先頭512バイト以降に配置)
%include        "../modules/real/itoa.s"
%include        "../modules/real/get_drive_param.s"
%include        "../modules/real/get_font_addr.s"

; ブート処理の第二ステージ
stage_2:
        cdecl   puts, .s0

        ; ドライブ情報を取得
        cdecl   get_drive_param, BOOT
        cmp     ax, 0
.10Q:
        jne     .10E
.10T:
        cdecl   puts, .e0
        call    reboot
.10E:
        ; ドライブ情報を表示
        mov     ax, [BOOT + drive.no]
        cdecl   itoa, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]
        cdecl   itoa, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]
        cdecl   itoa, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]
        cdecl   itoa, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1

        jmp     stage_3

.s0     db      "2nd stage...", 0x0A, 0x0D, 0x00

.s1     db      " Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive parameter.", 0

stage_3:
        cdecl   puts, .s0
        
        ; フォントアドレスの取得
        ; プロテクトモードではBIOSのフォントを利用
        cdecl   get_font_addr, FONT

        ; フォントアドレスの表示
        cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        jmp     $

.s0     db      "3rd stage...", 0x0A, 0x0D, 0

.s1     db      " Font Address="
.p1     db      "    :"
.p2     db      "    ", 0x0A, 0x0D, 0
        db      0x0A, 0x0D, 0

        times   BOOT_SIZE - ($ - $$)   db 0x00 ; 8K byte