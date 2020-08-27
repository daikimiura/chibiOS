%define         USE_SYSTEM_CALL
%define         USE_TEST_AND_SET

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

        ; TSSディスクリプタのベースアドレスの設定
        set_desc        GDT.tss_0, TSS_0
        set_desc        GDT.tss_1, TSS_1
        set_desc        GDT.tss_2, TSS_2
        set_desc        GDT.tss_3, TSS_3
        set_desc        GDT.tss_4, TSS_4
        set_desc        GDT.tss_5, TSS_5
        set_desc        GDT.tss_6, TSS_6

        ; コールゲートディスクリプタのベースアドレスの設定
        set_gate        GDT.call_gate, call_gate

        ; LDTディスクリプタのベースアドレスの設定
        set_desc        GDT.ldt, LDT, word LDT_LIMIT

        ; GDTの再読みこみ
        lgdt    [GDTR]

        mov     esp, SP_TASK_0 ; espをタスク0用のスタックポインタへ移行
        mov     ax, SS_TASK_0 ; これからタスク0として動作する
        ltr     ax 

        ; 割り込みベクタ/PIC/タイマーの初期化
        cdecl   init_int
        cdecl   init_pic
        
        ; ページディレクトリ/ページテーブルの初期化
        cdecl   init_page

        ; 割り込みベクタの登録
        set_vect        0x00, int_zero_div
        set_vect        0x07, int_nm
        set_vect        0x0E, int_pf
        set_vect        0x20, int_timer
        set_vect        0x21, int_keyboard
        set_vect        0x28, int_rtc
        set_vect        0x81, trap_gate_81, word 0xEF00 ; トラップゲートの登録
        set_vect        0x82, trap_gate_82, word 0xEF00 ; トラップゲートの登録

        ; RTCの割り込みを有効化
        cdecl   enable_rtc_int, 0x10

        ; タイマーの割り込みを有効化
        cdecl   enable_timer0_int

        ; 割り込みマスクの設定
        outp    0x21, 0b_1111_1000
        outp    0xA1, 0b_1111_1110

        mov     eax, CR3_BASE
        mov     cr3, eax
        mov     eax, cr0
        or      eax, (1 << 31)
        mov     cr0, eax
        jmp     $ + 2

        ; CPUの割り込み許可
        sti

        ; フォントの表示
        cdecl   draw_font, 63, 13

        ; 文字列の表示
        cdecl   draw_str, 25, 14, 0x010F, .s0

.10L:
        ; キーボード入力の表示
        cdecl   ring_rd, _KEY_BUFF, .int_key
        cmp     eax, 0
        je      .10E

        cdecl   draw_items, 2, 29, _KEY_BUFF

        mov     al, [.int_key]
        cmp     al, 0x02 ; '1' == AL
        jne     .12E

        ; ファイル読み込み
        call    [BOOT_LOAD + BOOT_SIZE - 16]

        mov     esi, 0x7800
        mov     [esi + 32], byte 0 ; 最大で32文字
        cdecl   draw_str, 0, 0, 0x0F04, esi

.12E:
.10E:
        ; 回転する棒の表示(タイマー割り込みの確認)
        cdecl   draw_rotation_bar
        jmp     .10L

.s0     db      "Hello, kernel!", 0

ALIGN 4, db     0
.int_key dd     0

ALIGN 4, db     0
FONT_ADR dd     0
RTC_TIME dd     0  

; タスク
%include        "descriptor.s"
%include        "tasks/task_1.s"
%include        "tasks/task_2.s"
%include        "tasks/task_3.s"

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
%include        "../modules/protect/interrupt.s"
%include        "../modules/protect/pic.s"
%include        "../modules/protect/int_rtc.s"
%include        "../modules/protect/int_keyboard.s"
%include        "../modules/protect/ring_buff.s"
%include        "../modules/protect/timer.s"
%include        "../modules/protect/draw_rotation_bar.s"
%include        "../modules/protect/call_gate.s"
%include        "../modules/protect/trap_gate.s"
%include        "../modules/protect/test_and_set.s"
%include        "../modules/protect/int_nm.s"
%include        "../modules/protect/wait_tick.s"
%include        "../modules/protect/memcpy.s"
%include        "modules/int_timer.s"
%include        "modules/int_pf.s"
%include        "modules/paging.s"

        times KERNEL_SIZE - ($ - $$)    db  0

%include        "fat.s"