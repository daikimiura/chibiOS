vga_set_read_plane:
        push    ebp
        mov     ebp, esp

        push    eax
        push    edx

        ; 読み込みプレーンの選択
        mov     ah, [ebp + 8]
        and     ah, 0x03 ; 余計なビットをマスク
        mov     al, 0x04
        mov     dx, 0x03CE
        out     dx, ax

        pop     edx
        pop     eax

        mov     esp,ebp
        pop     ebp

        ret

vga_set_write_plane:
        push    ebp
        mov     ebp, esp

        push    eax
        push    edx

        ; 読み込みプレーンの選択
        mov     ah, [ebp + 8]
        and     ah, 0x0F ; 余計なビットをマスク
        mov     al, 0x02
        mov     dx, 0x03C4
        out     dx, ax

        pop     edx
        pop     eax

        mov     esp,ebp
        pop     ebp

        ret

vram_font_copy:
        push    ebp
        mov     ebp, esp

        push    esi
        push    edi
        push    eax
        push    ebx
        push    ecx
        push    edx


        mov     esi, [ebp + 8]; フォントアドレス
        mov     edi, [ebp + 12] ; VRAMアドレス
        movzx   eax, byte [ebp + 16] ; プレーン
        movzx   ebx, word [ebp + 20] ; 色

        ; マスクデータの作成
        test    bh, al
        setz    dh
        dec     dh

        test    bl, al
        setz    dl
        dec     dl

        ; 8*16ドットフォントのコピー
        cld

        mov     ecx, 16
.10L:
        ; フォントマスクの作成
        lodsb ; AL = *ESI++ // フォント
        mov     ah, al
        not     ah ; 反転

        ; 前景色
        and     al, dl

        ; 背景色
        test    ebx, 0x0010 ; 透過モードかどうか
        jz      .11F
        and     ah, [edi]
        jmp     .11E
.11F:
        and     ah, dh
.11E:
        or      al, ah
        mov     [edi], al

        add     edi, 80
        loop    .10L

        pop    edx     
        pop    ecx
        pop    ebx
        pop    eax
        pop    edi
        pop    esi

        mov     esp, ebp
        pop     ebp
        
        ret

vram_bit_copy:
        push    ebp
        mov     ebp, esp

        push    esi
        push    edi
        push    eax
        push    ebx
        push    ecx
        push    edx


        mov     edi, [ebp + 12] ; VRAMアドレス
        movzx   eax, byte [ebp + 16] ; プレーン
        movzx   ebx, word [ebp + 20] ; 色

        ; マスクデータの作成
        test    bl, al
        setz    bl
        dec     bl

        mov     al, [ebp + 8] ; 出力ビットパターン
        mov     ah, al
        not     ah

        and     ah, [edi]
        and     al, bl
        or      al, ah
        mov     [edi], al

        pop    edx     
        pop    ecx
        pop    ebx
        pop    eax
        pop    edi
        pop    esi

        mov     esp, ebp
        pop     ebp
        
        ret