enable_rtc_int:
        push    ebp
        mov     ebp, esp

        push    eax

        ; 割り込み許可設定
        outp    0x70, 0x0B
        in      al, 0x71
        or      al, [ebp + 8]
        out     0x71, al

        pop     eax

        mov     esp, ebp
        pop     ebp

        ret

int_rtc:
        pusha
        push    ds
        push    es

        ; データ用セグメントセレクタの設定
        mov     ax, 0x0010
        mov     ds, ax
        mov     es, ax

        cdecl   rtc_get_time, RTC_TIME

        ; RTCの割り込み要因を取得
        outp    0x70, 0x0C
        in      al, 0x71

        ; 割り込みフラグをクリア(EOI)
        outp     0xA0, 0x20
        outp     0x20, 0x20

        pop     es
        pop     ds
        popa

        iret