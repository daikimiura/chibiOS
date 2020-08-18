task_1:
        cdecl   SS_GATE_0:0, 58, 0, 0x07, .s0

.10L:
        ; 時刻の表示
        ; mov     eax, [RTC_TIME]
        ; cdecl   draw_time, 72, 0, 0x0700, eax

        jmp     .10L

.s0     db  "Task-1 (via call gate)", 0