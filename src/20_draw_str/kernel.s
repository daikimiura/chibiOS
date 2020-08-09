%include        "../include/define.s"
%include        "../include/macro.s"

        ORG     KERNEL_LOAD
[BITS 32]

kernel:
        ; フォントアドレスを取得
        mov     esi, BOOT_LOAD + SECT_SIZE
        movzx   eax, word [esi + 0] ; セグメント FONT.sg
        movzx   ebx, word [esi + 2] ; オフセット FONT.off
        shl     eax, 4
        add     eax, ebx ; セグメント:オフセット の形にする
        mov     [FONT_ADR], eax

        ; フォントの表示
        cdecl   draw_font, 63, 13

        ; 文字列の表示
        cdecl   draw_str, 25, 14, 0x010F, .s0

        jmp     $
.s0     db      "Hello, kernel!", 0
ALIGN 4, db     0
FONT_ADR: dd     0

; モジュール
%include        "../modules/protect/vga.s"
%include        "../modules/protect/draw_char.s"
%include        "../modules/protect/draw_font.s"
%include        "../modules/protect/draw_str.s"

        times KERNEL_SIZE - ($ - $$)    db  0