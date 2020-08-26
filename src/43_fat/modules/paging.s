page_set_4m:
        push    ebp
        mov     ebp, esp
        pusha

        ; ページディレクトリの作成
        cld
        mov     edi, [ebp + 8]
        mov     eax, 0x0000_0000
        mov     ecx, 1024
        rep stosd

        ; 先頭のエントリを設定
        mov     eax, edi
        and     eax, ~0x0000_0FFF
        or      eax, 7
        mov     [edi - (1024 * 4)], eax

        ; ページテーブルの設定
        mov     eax, 0x0000_0007
        mov     ecx, 1024
.10L:
        stosd
        add     eax, 0x0000_1000 ; ページテーブルのアドレスは4Kバイトごとに設定
        loop    .10L

        popa
        mov     esp, ebp
        pop     ebp

        ret

init_page:
        pusha

        cdecl   page_set_4m, CR3_BASE
        cdecl   page_set_4m, CR3_TASK_4
        cdecl   page_set_4m, CR3_TASK_5
        cdecl   page_set_4m, CR3_TASK_6

        mov     [0x0010_6000 + 0x107 * 4], dword 0 ; 0x0010_7000をページ不在に設定

        ; アドレス変換設定
        mov     [0x00020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7
        mov     [0x00020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7
        mov     [0x00020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7

        ; 描画パラメータの設定(配置)
        cdecl   memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size  
        cdecl   memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size  
        cdecl   memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size  

        
        popa
        ret