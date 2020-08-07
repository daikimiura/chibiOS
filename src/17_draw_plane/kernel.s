%include    "../include/define.s"
%include    "../include/macro.s"

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

        ; 8ビットの横線
        mov     ah, 0x07 ; 書き込みプレーンの指定 IRGB
        mov     al, 0x02
        mov     dx, 0x3C4
        out     dx, ax

        mov     [0x000A_0000 + 0], byte 0xFF

        mov     ah, 0x04
        out     dx, ax

        mov     [0x000A_0000 + 1], byte 0xFF

        mov     ah, 0x02
        out     dx, ax

        mov     [0x000A_0000 + 2], byte 0xFF

        mov     ah, 0x01
        out     dx, ax

        mov     [0x000A_0000 + 3], byte 0xFF

        ; 画面を横切る横線
        mov     ah, 0x02
        out     dx, ax

        lea     edi, [0x000A_0000 + 80]
        mov     ecx, 80
        mov     al, 0xFF
        rep stosb

        ; 2行目に8ドットの矩形を描画
        mov     edi, 1
        shl     edi, 8
        lea     edi, [edi * 4 + edi + 0x000A_0000]

        mov     [edi + (80 * 0)], word 0xFF
        mov     [edi + (80 * 1)], word 0xFF
        mov     [edi + (80 * 2)], word 0xFF
        mov     [edi + (80 * 3)], word 0xFF
        mov     [edi + (80 * 4)], word 0xFF
        mov     [edi + (80 * 5)], word 0xFF
        mov     [edi + (80 * 6)], word 0xFF
        mov     [edi + (80 * 7)], word 0xFF

        ; 3行目に文字を描画
        mov     esi, 'A'
        shl     esi, 4
        add     esi, [FONT_ADR]

        mov     edi, 2
        shl     edi, 8
        lea     edi, [edi * 4 + edi + 0x000A_0000]

        mov     ecx, 16
.10L:
        movsb
        add     edi, 80 - 1
        loop    .10L

        jmp     $
ALIGN 4, db     0
FONT_ADR: dd     0

        times KERNEL_SIZE - ($ - $$)    db  0