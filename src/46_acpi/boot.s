%include        "../include/macro.s"
%include        "../include/define.s"

        ORG     BOOT_LOAD

; entry:
;         jmp     ipl
;         times 3 - ($ - $$) db 0x90
;         db      "OEM-NAME"

;         dw      512
;         db      1
;         dw      32
;         db      2
;         dw      512
;         dw      0xFFF0
;         db      0xF8
;         dw      256
;         dw      0x10
;         dw      2
;         dd      0

;         dd      0
;         db      0x80
;         db      0
;         db      0x29
;         dd      0xbeef
;         db      "BOOTABLE   "
;         db      "FAT16   "
entry:
        ;---------------------------------------
        ; BPB(BIOS Parameter Block)
        ;---------------------------------------
        jmp		ipl								; 0x00( 3) �u�[�g�R�[�h�ւ̃W�����v����
        times	3 - ($ - $$) db 0x90			; 
        db		'OEM-NAME'						; 0x03( 8) OEM��
                                                                                        ; -------- --------------------------------
        dw		512								; 0x0B( 2) �Z�N�^�̃o�C�g��
        db		1								; 0x0D( 1) �N���X�^�̃Z�N�^��
        dw		32								; 0x0E( 2) �\��Z�N�^��
        db		2								; 0x10( 1) FAT��
        dw		512								; 0x11( 2) ���[�g�G���g����
        dw		0xFFF0							; 0x13( 2) ���Z�N�^��16
        db		0xF8							; 0x15( 1) ���f�B�A�^�C�v
        dw		256								; 0x16( 2) FAT�̃Z�N�^��
        dw		0x10							; 0x18( 2) �g���b�N�̃Z�N�^��
        dw		2								; 0x1A( 2) �w�b�h��
        dd		0								; 0x1C( 4) �B���ꂽ�Z�N�^��
                                                                                        ; -------- --------------------------------
        dd		0								; 0x20( 4) ���Z�N�^��32
        db		0x80							; 0x24( 1) �h���C�u�ԍ�
        db		0								; 0x25( 1) �i�\��j
        db		0x29							; 0x26( 1) �u�[�g�t���O
        dd		0xbeef							; 0x27( 4) �V���A���i���o�[
        db		'BOOTABLE   '					; 0x2B(11) �{�����[�����x��
        db		'FAT16   '
ipl:
        cli ; 割り込み禁止

        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti ; 割り込み許可

        mov     [BOOT + drive.no], dl ; ブートドライブを保存

        ; 文字列の表示
        cdecl   puts, .s0 

        ; 残りのセクタを読み込む
        mov     bx, BOOT_SECT - 1 ; 残りのブートセクタ数
        mov     cx, BOOT_LOAD + SECT_SIZE ; 次のロードアドレス

        cdecl   read_chs, BOOT, bx, cx
        
        cmp     ax, bx
.10Q:  
        jz     .10E ; ax == bx (正常に読み出せた)
.10T:
        cdecl   puts, .e0
        call    reboot
.10E:
        jmp     stage_2

.s0     db      "Booting...", 0x0A, 0x0D, 0x00
.e0     db      "Error: sector read", 0x0A, 0x0D, 0x00

ALIGN   2, db 0
; http://www7a.biglobe.ne.jp/~iell/nasm/nasmdoc_2.03j/nasmdoc4.html#section-4.8.9
BOOT:
        istruc  drive
                at drive.no, dw      0
                at drive.cyln, dw      0
                at drive.head, dw       0
                at drive.sect, dw       2
        iend
        

%include        "../modules/real/puts.s"
%include        "../modules/real/reboot.s"
%include        "../modules/real/read_chs.s"

        times   510 - ($ - $$) db 0x00
        db      0x55, 0xAA

; リアルモード時に取得した情報を分かりやすいアドレスに保存する(0x7C00+512 = 0x7E00 番地)
FONT:
.seg    dw      0
.off    dw      0
ACPI_DATA:
.adr    dd      0
.len    dd      0

; モジュール(先頭512バイト以降に配置)
%include        "../modules/real/itoa.s"
%include        "../modules/real/get_drive_param.s"
%include        "../modules/real/get_font_addr.s"
%include        "../modules/real/get_mem_info.s"
%include        "../modules/real/kbc.s"
%include        "../modules/real/read_lba.s"
%include        "../modules/real/lba_chs.s"
%include        "../modules/real/memcpy.s"
%include        "../modules/real/memcmp.s"

; ブート処理の第二ステージ
stage_2:
        cdecl   puts, .s0

        ; ドライブ情報を取得
        cdecl   get_drive_param, BOOT
        cmp     ax, 0
.10Q:
        jne     .10E
.10T:
        cdecl   puts, .e0
        call    reboot
.10E:
        ; ドライブ情報を表示
        mov     ax, [BOOT + drive.no]
        cdecl   itoa, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]
        cdecl   itoa, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]
        cdecl   itoa, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]
        cdecl   itoa, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1

        jmp     stage_3

.s0     db      "2nd stage...", 0x0A, 0x0D, 0x00

.s1     db      " Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive parameter.", 0

; ブート処理の第三ステージ
stage_3:
        cdecl   puts, .s0
        
        ; フォントアドレスの取得
        ; プロテクトモードではBIOSのフォントを利用
        cdecl   get_font_addr, FONT

        ; フォントアドレスの表示
        cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ; メモリ情報の取得と表示
        cdecl   get_mem_info

        mov     eax, [ACPI_DATA.adr]
        cmp     eax, 0
        je      .10E

        cdecl   itoa, ax, .p4, 4, 16, 0b0100
        shr     eax, 16
        cdecl   itoa, ax, .p3, 4, 16, 0b0100

        cdecl   puts, .s2
.10E:
        jmp     stage_4

.s0     db      "3rd stage...", 0x0A, 0x0D, 0

.s1     db      " Font Address="
.p1     db      "    :"
.p2     db      "    ", 0x0A, 0x0D, 0

.s2     db      " ACPI data="
.p3     db      "    "
.p4     db      "    ", 0x0A, 0x0D, 0

; ブート処理の第四ステージ
stage_4:
        cdecl   puts, .s0

        ; A20ゲートの有効化
        cli

        cdecl   KBC_cmd_write, 0xAD ; キーボード無効化
        cdecl   KBC_cmd_write, 0xD0 ; 出力ポート読み出しコマンド
        cdecl   KBC_data_read, .key ; 出力ポートデータ

        mov     bl, [.key]
        or      bl, 0x02 ; A20ゲートの有効化

        cdecl   KBC_cmd_write, 0xD1 ; 出力ポート書き込みコマンド
        cdecl   KBC_data_write, bx ; 出力ポートデータ

        cdecl   KBC_cmd_write, 0xAE ; キーボード有効化

        sti
        ; cdecl   puts, .s1

        ; キーボードのLEDのテスト
        cdecl   puts, .s2

        mov     bx, 0
.10L:  
        mov     ah, 0x00
        int     0x16 ; キーボード入力待ち

        cmp     al, '1' ; // キーボード入力は1から3までしか受け付けない
        jb      .10E
        cmp     al, '3'
        ja      .10E

        mov     cl, al
        dec     cl
        and     cl, 0x03
        mov     ax, 0x0001
        shl     ax, cl
        xor     bx, ax

        ; LEDコマンドの送信
        cli

        cdecl   KBC_cmd_write, 0xAD ; キーボード無効化
        cdecl   KBC_data_read, .key ; 受信応答

        cmp     [.key], byte 0xFA ; 0xFA == ACK
        jne     .11F

        cdecl   KBC_data_write, bx
        jmp     .11E
.11F:
        cdecl   itoa, word [.key], .e1, 2, 16, 0b0100
        cdecl   puts, .e0
.11E:
        cdecl   KBC_cmd_write, 0xAE ; キーボード有効化
        sti
        jmp     .10L
.10E:
        cdecl   puts, .s3

        jmp     stage_5

.s0     db      "4th stage...", 0x0A, 0x0D, 0
.s1     db      " A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2     db      " Keyboard LED test...", 0
.s3     db      " (done)", 0x0A, 0x0D, 0
.e0     db      "["
.e1     db      "  ]", 0

.key    dw      0

; ブート処理の第五ステージ
stage_5:
        cdecl   puts, .s0
        cdecl   read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END

        cmp     ax, KERNEL_SECT
.10Q: 
        jz      .10E
.10T:
        cdecl   puts, .e0
        call    reboot
.10E:
        jmp     stage_6

.s0     db      "5th stage...", 0x0A, 0x0D, 0
.e0     db      " Failed to load kenel...", 0x0A, 0x0D, 0

; ブート処理の第六ステージ
stage_6:
        cdecl   puts, .s0

        ; ユーザーからの入力待ち
.10L:
        mov     ah, 0x00
        int     0x16
        cmp     al, ' '
        jne     .10L

        ; ビデオモードの設定
        mov     ax, 0x0012
        int     0x10

        jmp     stage_7

.s0     db      "6th stage...", 0x0A, 0x0D
        db      " [Push SPACE key to change from real mode to protect mode...", 0x0A, 0x0D, 0

; セグメントディスクリプタテーブル
ALIGN 4,        db      0
GDT:
        dq      0x00_0_0_0_0_000000_0000 ; NULL
.cs     dq      0x00_C_F_9_A_000000_FFFF ; CODE
.ds     dq      0x00_C_F_9_2_000000_FFFF ; DATA
.gdt_end:

; セレクタ
SEL_CODE        equ     .cs - GDT
SEL_DATA        equ     .ds - GDT

; GDTR
GDTR:
        dw      GDT.gdt_end - GDT - 1 ; ディスクリプタテーブルのリミット
        dd      GDT ; ディスクリプタテーブルのアドレス

; IDTR
IDTR:
        dw      0 ; 割り込み禁止にするため0に設定
        dd      0 ; 割り込み禁止にするため0に設定

read_file:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	ax
		push	bx
		push	cx

		;---------------------------------------
		; �f�t�H���g�̕������ݒ�
		;---------------------------------------
		cdecl	memcpy, 0x7800, .s0, .s1 - .s0

		;---------------------------------------
		; 
		; 
		;          |____________| 
		; 0000_7600|            | FAT�p�o�b�t�@
		;          =            = 
		;          |____________| 
		; 0000_7800|            | �f�[�^�p�o�b�t�@
		;          =            = 
		;          |____________| 
		; 0000_7A00|            | �X�^�b�N
		;          =            = 
		;          |____________| 
		; 0000_7C00|            | �u�[�g
		;          =            = 
		;          |____________| 
		;          |////////////| 
		;          |            | 
		;---------------------------------------

		;---------------------------------------
		; ���[�g�f�B���N�g���̃Z�N�^��ǂݍ���
		;---------------------------------------
		mov		bx, 32 + 256 + 256				; BX = �f�B���N�g���G���g���̐擪�Z�N�^
		mov		cx, (512 * 32) / 512			; CX = 512�G���g�����̃Z�N�^��
.10L:											; do
												; {
		;---------------------------------------
		; 1�Z�N�^�i16�G���g���j����ǂݍ���
		;---------------------------------------
		cdecl	read_lba, BOOT, bx, 1, 0x7600	;   AX = read_lba();
		cmp		ax, 0							;   if (0 == AX)
		je		.10E							;     break;

		;---------------------------------------
		; �f�B���N�g���G���g������t�@�C����������
		;---------------------------------------
		cdecl	fat_find_file					;     AX = �t�@�C���̌���
		cmp		ax, 0							;     if (AX)
		je		.12E							;     {
												;       
		add		ax, 32 + 256 + 256 + 32 - 2		;       // �Z�N�^�ʒu�ɃI�t�Z�b�g�����Z
		cdecl	read_lba, BOOT, ax, 1, 0x7800	;       read_lba() // �t�@�C���̓ǂݍ���
												;       
		jmp		.10E							;       break;
.12E:											;     }
		inc		bx								;     BX++; //���̃Z�N�^�i16�G���g���j
		loop	.10L							;   
.10E:											; } while (--CX);

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		cx
		pop		bx
		pop		ax

		ret

.s0:	db		'File not found.', 0
.s1:


; read_file:
;         push    ax
;         push    bx
;         push    cx

;         cdecl   memcpy, 0x7800, .s0, .s1 - .s0

;         ; ルートディレクトリのセクタを読み込む
;         mov     bx, 32 + 256 + 256 ; 予約セクタ　+ FAT領域2つ
;         mov     cx, (512 * 32) / 512 ; 512エントリ分のセクタ数
; .10L:
;         ; 1セクタ分読みこむ
;         cdecl   read_lba, BOOT, bx, 1, 0x7600
;         cmp     ax, 0
;         je      .10E

;         ; ディレクトリエントリからファイル名を検索
;         cdecl   fat_find_file
;         cmp     ax, 0
;         je      .12E

;         ;　見つかった場合
;         add     ax, 32 + 256 + 256 + 32 - 2
;         cdecl   read_lba, BOOT, ax, 1, 0x7800
;         jmp     .10E
; .12E:
;         inc     bx
;         loop    .10L
; .10E:
;         pop     cx
;         pop     bx
;         pop     ax

;         ret
; .s0:    db      "File not found.", 0
; .s1:

fat_find_file:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	bx
		push	cx
		push	si

		;---------------------------------------
		; �t�@�C��������
		;---------------------------------------
		cld										; // DF�N���A�i+�����j
		mov		bx, 0							; BX = �t�@�C���̐擪�Z�N�^; // �����l
		mov		cx, 512 / 32					; CX = �G���g����;           // 1�Z�N�^/32�o�C�g
		mov		si, 0x7600						; SI = �ǂݍ��񂾃Z�N�^�̃A�h���X; 
												; do
.10L:											; {
		and		[si + 11], byte 0x18			;   // �t�@�C�������̃`�F�b�N
		jnz		.12E							;   if (�f�B���N�g��/�{�����[�����x���ȊO)
												;   {
		cdecl	memcmp, si, .s0, 8 + 3			;     AX = memcmp(�t�@�C�������r);
		cmp		ax, 0							;     if (����t�@�C����)
		jne		.12E							;     {
												;       
		mov		bx, word [si + 0x1A]			;       BX = �t�@�C���̐擪�Z�N�^;
		jmp		.10E							;       break;
												;     }
.12E:											;   }
		add		si, 32							;   SI += 32; // ���̃G���g��
		loop	.10L							;   
.10E:											; } while (--CX);
		mov		ax, bx							; ret = ���������t�@�C���̐擪�Z�N�^;

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		si
		pop		cx
		pop		bx

		ret

.s0:	db		'SPECIAL TXT', 0
; fat_find_file:
;         push    bx
;         push    cx
;         push    si

;         cld
;         mov     bx, 0
;         mov     cx, 512 / 32 ; エントリ数(1セクタ = 512 byte, 1エントリ = 32 byte)
;         mov     si, 0x7600 ; 読み込んだセクタのアドレス
; .10L:
;         and     [si + 11], byte 0x18
;         jnz     .12E

;         cdecl   memcmp, si, .s0, 8 + 3
;         cmp     ax, 0
;         jne     .12E

;         mov     bx, word [si + 0x1A]
;         jmp     .10E
; .12E:
;         add     si, 32
;         loop    .10L
; .10E:
;         mov     ax, bx

; .s0:    db      "SPECIAL TXT", 0


; ブート処理の第七ステージ
stage_7:
        cli

        ; GDTのロード
        lgdt    [GDTR]
        lidt    [IDTR]

        ; プロテクトモードへ移行
        mov     eax, cr0
        or      ax, 1
        mov     cr0, eax

        jmp     $ + 2 ; 先読みしたリアルモード時のコードをクリア

        ; セグメント間ジャンプ
[BITS 32]
        db      0x66
        jmp     SEL_CODE:CODE_32

; 32ビットコード開始
CODE_32:
        ; セレクタを初期化
        ; データ用セグメントだけでいいけど、一応残りも初期化
        mov     ax, SEL_DATA
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax

        ; カーネルをコピー
        mov     ecx, KERNEL_SIZE / 4
        mov     esi, BOOT_END ; ブートプログラムの直後にカーネルが配置されている
        mov     edi, KERNEL_LOAD
        cld
        rep movsd

        ; カーネル処理に移行
        jmp     KERNEL_LOAD


; リアルモードへ移行するプログラム
TO_REAL_MODE:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
												; ------|--------
												; EBP+ 8| col�i��j
												; EBP+12| row�i�s�j
												; EBP+16| color�i�F�j
												; EBP+20| *p�i������ւ̃A�h���X�j
												; ---------------
		push	ebp								; EBP+ 4| EIP�i�߂�Ԓn�j
		mov		ebp, esp						; EBP+ 0| EBP�i���̒l�j
												; ---------------

		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		pusha

		cli										; // ���荞�݋֎~

		;---------------------------------------
		; ���݂̐ݒ�l��ۑ�
		;---------------------------------------
		mov		eax, cr0						; 
		mov		[.cr0_saved], eax				; // CR0���W�X�^��ۑ�
		mov		[.esp_saved], esp				; // ESP���W�X�^��ۑ�
		sidt	[.idtr_save]					; // IDTR��ۑ�
		lidt	[.idtr_real]					; // ���A�����[�h�̊��荞�ݐݒ�

		;---------------------------------------
		; 16�r�b�g�̃v���e�N�g���[�h�Ɉڍs
		;---------------------------------------
		jmp		0x0018:.bit16					; CS = 0x18�i�R�[�h�Z�O�����g�Z���N�^�j
[BITS 16]
.bit16:	mov		ax, 0x0020						; DS = 0x20�i�f�[�^�Z�O�����g�Z���N�^�j
		mov		ds, ax							; 
		mov		es, ax							; 
		mov		ss, ax							; 

		;---------------------------------------
		; ���A�����[�h�ֈڍs�i�y�[�W���O�������j
		;---------------------------------------
		mov		eax, cr0						; // PG/PE�r�b�g���N���A
		and		eax,  0x7FFF_FFFE				; CR0 &= ~(PG | PE);
		mov		cr0, eax						; 
		jmp		$ + 2							; 

		;---------------------------------------
		; �Z�O�����g�ݒ�i���A�����[�h�j
		;---------------------------------------
		jmp		0:.real							; CS = 0x0000;
.real:	mov		ax, 0x0000						; 
		mov		ds, ax							; DS = 0x0000;
		mov		es, ax							; ES = 0x0000;
		mov		ss, ax							; SS = 0x0000;
		mov		sp, 0x7C00						; SP = 0x7C00;

		;---------------------------------------
		; ���荞�݃}�X�N�̐ݒ�i���A�����[�h�p�j
		;---------------------------------------
		outp	0x20, 0x11						; out(0x20, 0x11); // MASTER.ICW1 = 0x11;
		outp	0x21, 0x08						; out(0x21, 0x20); // MASTER.ICW2 = 0x08;
		outp	0x21, 0x04						; out(0x21, 0x04); // MASTER.ICW3 = 0x04;
		outp	0x21, 0x01						; out(0x21, 0x01); // MASTER.ICW4 = 0x01;

		outp	0xA0, 0x11						; out(0xA0, 0x11); // SLAVE.ICW1  = 0x11;
		outp	0xA1, 0x10						; out(0xA1, 0x28); // SLAVE.ICW2  = 0x10;
		outp	0xA1, 0x02						; out(0xA1, 0x02); // SLAVE.ICW3  = 0x02;
		outp	0xA1, 0x01						; out(0xA1, 0x01); // SLAVE.ICW4  = 0x01;

		outp	0x21, 0b_1011_1000				; // ���荞�ݗL���FFDD/�X���[�uPIC/KBC/�^�C�}�[
		outp	0xA1, 0b_1011_1110				; // ���荞�ݗL���FHDD/RTC

		sti										; // ���荞�݋���

		;---------------------------------------
		; �t�@�C���ǂݍ���
		;---------------------------------------
		cdecl	read_file						; read_file();

		;---------------------------------------
		; ���荞�݃}�X�N�̐ݒ�i�v���e�N�g���[�h�p�j
		;---------------------------------------
		cli										; // ���荞�݋֎~

		outp	0x20, 0x11						; // MASTER.ICW1 = 0x11;
		outp	0x21, 0x20						; // MASTER.ICW2 = 0x20;
		outp	0x21, 0x04						; // MASTER.ICW3 = 0x04;
		outp	0x21, 0x01						; // MASTER.ICW4 = 0x01;

		outp	0xA0, 0x11						; // SLAVE.ICW1  = 0x11;
		outp	0xA1, 0x28						; // SLAVE.ICW2  = 0x28;
		outp	0xA1, 0x02						; // SLAVE.ICW3  = 0x02;
		outp	0xA1, 0x01						; // SLAVE.ICW4  = 0x01;

		outp	0x21, 0b_1111_1000				; // ���荞�ݗL���F�X���[�uPIC/KBC/�^�C�}�[
		outp	0xA1, 0b_1111_1110				; // ���荞�ݗL���FRTC

		;---------------------------------------
		; 16�r�b�g�v���e�N�g���[�h�Ɉڍs
		;---------------------------------------
		mov		eax, cr0						; // PE�r�b�g���Z�b�g
		or		eax, 1							; CR0 |= PE;
		mov		cr0, eax						; 

		jmp		$ + 2							; ��ǂ݂��N���A

		;---------------------------------------
		; 32�r�b�g�v���e�N�g���[�h�Ɉڍs
		;---------------------------------------
		DB		0x66							; 32bit �I�[�o�[���C�h
[BITS 32]
		jmp		0x0008:.bit32					; CS = 32�r�b�gCS;
.bit32:	mov		ax, 0x0010						; DS = 32�r�b�gDS;
		mov		ds, ax							;
		mov		es, ax							;
		mov		ss, ax							;

		;---------------------------------------
		; ���W�X�^�ݒ�̕��A
		;---------------------------------------
		mov		esp, [.esp_saved]				; // ESP���W�X�^�𕜋A
		mov		eax, [.cr0_saved]				; // CR0���W�X�^�𕜋A
		mov		cr0, eax						; 
		lidt	[.idtr_save]					; // IDTR�𕜋A

		sti 									; // ���荞�݋���

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		popa

		;---------------------------------------
		; �y�X�^�b�N�t���[���̔j���z
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

.idtr_real:
		dw 		0x3FF							; idt_limit
		dd 		0								; idt location

.idtr_save:
		dw 		0								; ���~�b�g
		dd 		0								; �x�[�X

.cr0_saved:
		dd		0

.esp_saved:
		dd		0

;************************************************************************
;	�p�f�B���O
;************************************************************************
		times BOOT_SIZE - ($ - $$) - 16	db	0	; �p�f�B���O

		dd 		TO_REAL_MODE					; ���A�����[�h�ڍs�v���O����

;************************************************************************
;	�p�f�B���O
;************************************************************************
		times BOOT_SIZE - ($ - $$)		db	0	; �p�f�B���O


; TO_REAL_MODE:
;         push    ebp
;         mov     ebp, esp

;         pusha

;         cli

;         mov     eax, cr0
;         mov     [.cr0_saved], eax
;         mov     [.esp_saved], esp
;         ; IDTRを保存した後、リアルモードのものに差し替え
;         sidt    [.idtr_save]
;         lidt    [.idtr_real]

;         jmp     0x0018:.bit16 ; 0x0018=コードセグメントセレクタ(8byte * 3番目 = 24 = 0x0018)

; [BITS 16]
; .bit16:
;         mov     ax, 0x0020 ; 0x0020=データセグメントセレクタ(8byte * 4番目 = 32 = 0x0020)
;         mov     ds, ax
;         mov     es, ax
;         mov     ss, ax

;         mov     eax, cr0
;         and     eax, 0x7FFF_FFFE
;         mov     cr0, eax
;         jmp     $ + 2

;         ; セグメント設定(リアルモード)
;         jmp     0:.real
; .real:
;         mov     eax, 0x0000
;         mov     ds, ax
;         mov     es, ax
;         mov     ss, ax
;         mov     sp, 0x7C00

;         ; 割り込みマスクの設定(リアルモード用)
;         outp    0x20, 0x11
;         outp    0x21, 0x08
;         outp    0x21, 0x04
;         outp    0x21, 0x01

;         outp    0xA0, 0x11
;         outp    0xA1, 0x10
;         outp    0xA1, 0x02
;         outp    0xA1, 0x01

;         outp    0x21, 0b1011_1000
;         outp    0xA1, 0b1011_1111

;         sti

;         cdecl   read_file

;         cli ; 割り込み禁止

;         ; 割り込みマスクの設定(プロテクトモード用)
;         outp    0x20, 0x11
;         outp    0x21, 0x20
;         outp    0x21, 0x04
;         outp    0x21, 0x01

;         outp    0xA0, 0x11
;         outp    0xA1, 0x28
;         outp    0xA1, 0x02
;         outp    0xA1, 0x01

;         outp    0x21, 0b1111_1000
;         outp    0xA1, 0b1111_1110


;         ; プロテクトモードへの復帰
;         mov     eax, cr0
;         or      eax, 1
;         mov     cr0, eax
;         jmp     $ + 2
;         db      0x66
; [BITS 32]
;         jmp     0x0008:.bit32
; .bit32:
;         mov     ax, 0x0010
;         mov     ds, ax
;         mov     es, ax
;         mov     ss, ax

;         mov     esp, [.esp_saved]
;         mov     eax, [.cr0_saved]
;         mov     cr0, eax
;         lidt    [.idtr_save]

;         sti

;         popa

;         mov     esp, ebp
;         pop     ebp

;         ret

; .idtr_real:
;         dw      0x3FF 
;         dd      0
; .idtr_save:
;         dw      0
;         dd      0
; .cr0_saved:
;         dd      0
; .esp_saved:
;         dd      0

;         times   BOOT_SIZE - ($ - $$) - 16       db      0
;         dd      TO_REAL_MODE
;         times   BOOT_SIZE - ($ - $$)   db 0 ; 8K byte