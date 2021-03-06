draw_pixel:
        push    ebp
        mov     ebp, esp

        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     edi, [ebp + 12]
        shl     edi, 4
        lea     edi, [edi * 4 + edi + 0x000A_0000]

        mov     ebx, [ebp + 8]
        mov     ecx, ebx
        shr     ebx, 3
        add     edi, ebx

        and     ecx, 0x07
        mov     ebx, 0x80
        shr     ebx, cl

        mov     ecx, [ebp + 16]

%ifdef	USE_TEST_AND_SET
        cdecl	test_and_set, IN_USE			; TEST_AND_SET(IN_USE); // ���\�[�X�̋󂫑҂�
%endif

        cdecl   vga_set_read_plane, 0x03
        cdecl   vga_set_write_plane, 0x08
        cdecl   vram_bit_copy, ebx, edi, 0x08, ecx

        cdecl   vga_set_read_plane, 0x02
        cdecl   vga_set_write_plane, 0x04
        cdecl   vram_bit_copy, ebx, edi, 0x04, ecx

        cdecl   vga_set_read_plane, 0x01
        cdecl   vga_set_write_plane, 0x02
        cdecl   vram_bit_copy, ebx, edi, 0x02, ecx

        cdecl   vga_set_read_plane, 0x00
        cdecl   vga_set_write_plane, 0x01
        cdecl   vram_bit_copy, ebx, edi, 0x01, ecx

%ifdef	USE_TEST_AND_SET
        mov		[IN_USE], dword 0				; �ϐ��̃N���A
%endif

        pop    edi 
        pop    esi
        pop    edx
        pop    ecx
        pop    ebx
        pop    eax

        mov     esp, ebp
        pop     ebp

        ret
