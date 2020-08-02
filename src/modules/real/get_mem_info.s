get_mem_info:
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    si
        push    di
        push    bp

        mov     bp, 0 ; 行数
        mov     ebx, 0 ;　インデックスを初期化
.10L:
        mov     eax, 0x0000E820
        mov     ecx, E820_RECORD_SIZE
        mov     edx, 'PAMS'
        mov     di, .b0
        int     0x15

        cmp     eax, 'PAMS'
        je      .12E
        jmp     .10E
.12E:
        jnc     .14E
        jmp     .10E
.14E:
        ; 1レコード分のメモリ情報を表示
        cdecl   put_mem_info, di

        ; ACPI dataのアドレスを取得
        mov     eax, [di + 16] ; レコードタイプ
        cmp     eax, 3
        jne     .15E

        mov     eax, [di + 0] ; BASEアドレス
        mov     [ACPI_DATA.adr], eax

        mov     eax, [di + 8] ; Length
        mov     [ACPI_DATA.len], eax
.15E:
        cmp     ebx, 0
        jz      .16E

        inc     bp
        and     bp, 0x07 ; 8行表示するたびに中断(ユーザーからのキー入力を待つ)
        jnz     .16E
        
        cdecl   puts, .s2
        mov     ah, 0x10
        int     0x16

        cdecl   puts, .s3
.16E:
        cmp     ebx, 0
        jne     .10L
.10E:

.s2     db      " <more...>", 0
.s3     db      0x0D, "          ", 0x0D, 0
ALIGN 4, db 0
.b0     times   E820_RECORD_SIZE    db  0

put_mem_info:
        push    bp
        mov     bp, sp

        push    bx
        push    si

        mov     si, [bp + 4]

        ; Base(64bit)
        cdecl   itoa, word [si + 6], .p2 + 0, 4, 16, 0b100
        cdecl   itoa, word [si + 4], .p2 + 4, 4, 16, 0b100
        cdecl   itoa, word [si + 2], .p3 + 0, 4, 16, 0b100
        cdecl   itoa, word [si + 0], .p3 + 4, 4, 16, 0b100
        
        ; Length(64bit) 
        cdecl   itoa, word [si + 14], .p4 + 0, 4, 16, 0b100
        cdecl   itoa, word [si + 12], .p4 + 4, 4, 16, 0b100
        cdecl   itoa, word [si + 10], .p5 + 0, 4, 16, 0b100
        cdecl   itoa, word [si + 8], .p5 + 4, 4, 16, 0b100
        
        ; Type(32bit)
        cdecl   itoa, word [si + 18], .p6 + 0, 4, 16, 0b100
        cdecl   itoa, word [si + 16], .p6 + 4, 4, 16, 0b100

        cdecl   puts, .s1

        ; Typeを文字列で表示
        mov     bx, [si + 16]
        and     bx, 0x07
        shl     bx, 1
        add     bx, .t0
        cdecl   puts, word [bx]

        pop     si
        pop     bx

        mov     sp, bp
        pop     bp
        ret

.s1     db      " "
.p2     db      "        _"
.p3     db      "         "
.p4     db      "        _"
.p5     db      "         "
.p6     db      "        ", 0

.s4     db      " (Unkown)", 0x0A, 0x0D, 0
.s5     db      " (usable)", 0x0A, 0x0D, 0
.s6     db      " (reserved)", 0x0A, 0x0D, 0
.s7     db      " (ACPI data)", 0x0A, 0x0D, 0
.s8     db      " (ACPI NVS)", 0x0A, 0x0D, 0
.s9     db      " (bad memory)", 0x0A, 0x0D, 0

.t0     dw      .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4