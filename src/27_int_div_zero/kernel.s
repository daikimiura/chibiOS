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

        ; 割り込みベクタの初期化/登録
        cdecl   init_int
        set_vect        0x00, int_zero_div

        ; フォントの表示
        cdecl   draw_font, 63, 13

        ; 文字列の表示
        cdecl   draw_str, 25, 14, 0x010F, .s0

        ; カラーバーの表示
        cdecl   draw_color_bar, 63, 4

        int     0

        ; 0除算による割り込みを生成
        mov     al, 0
        div     al

.s0     db      "Hello, kernel!", 0
ALIGN 4, db     0
FONT_ADR dd     0
RTC_TIME dd     0  

; モジュール
%include        "../modules/protect/vga.s"
%include        "../modules/protect/draw_char.s"
%include        "../modules/protect/draw_font.s"
%include        "../modules/protect/draw_str.s"
%include        "../modules/protect/draw_color_bar.s"
%include        "../modules/protect/draw_pixel.s"
%include        "../modules/protect/draw_line.s"
%include        "../modules/protect/draw_rect.s"
%include        "../modules/protect/rtc.s"
%include        "../modules/protect/itoa.s"
%include        "../modules/protect/draw_time.s"

%include        "modules/interrupt.s"

        times KERNEL_SIZE - ($ - $$)    db  0