enable_timer0_int:
        push    eax ; outpマクロ内でEAXの値を書き換えているので

        outp    0x43, 0b_00_11_010_0
        outp    0x40, 0x9C
        outp    0x40, 0x2E

        pop     eax
        ret