BOOT_SIZE   equ     (1024 * 8) ; ブートプログラムのサイズ(8KB)
KERNEL_SIZE equ     (1024 * 8) ; カーネルのサイズ
SECT_SIZE   equ     (512) ; セクタサイズ

BOOT_SECT   equ     (BOOT_SIZE / SECT_SIZE) ; ブートプログラムのセクタ数
KERNEL_SECT equ     (KERNEL_SIZE / SECT_SIZE) ; カーネルのセクタ数

BOOT_LOAD   equ     0x7C00 ; ブートプログラムのロード位置
BOOT_END    equ     (BOOT_LOAD + BOOT_SIZE)

KERNEL_LOAD equ     0x0010_1000 ; カーネルのロード位置

E820_RECORD_SIZE    equ     20

VECT_BASE   equ     0x0010_0000 ; 割り込みベクタテーブルの位置

RING_ITEM_SIZE  equ (1 << 4) ; リングバッファのサイズ
RING_INDEX_MASK equ RING_ITEM_SIZE - 1 ; リングバッファのインデックスを有効な範囲内に収めるためのマスク

STACK_BASE      equ     0x0010_3000 ; タスク用スタックエリア
STACK_SIZE      equ     1024 ; スタックサイズ(1KB)

; アドレスの高い方から低い方へとスタックが伸びる
SP_TASK_0       equ     STACK_BASE + (STACK_SIZE * 1) ; タスク0のスタックポインタの初期値
SP_TASK_1       equ     STACK_BASE + (STACK_SIZE * 2) ; タスク0のスタックポインタの初期値
SP_TASK_2       equ     STACK_BASE + (STACK_SIZE * 3) ; タスク0のスタックポインタの初期値
SP_TASK_3       equ     STACK_BASE + (STACK_SIZE * 4) ; タスク0のスタックポインタの初期値
SP_TASK_4       equ     STACK_BASE + (STACK_SIZE * 5) ; タスク0のスタックポインタの初期値
SP_TASK_5       equ     STACK_BASE + (STACK_SIZE * 6) ; タスク0のスタックポインタの初期値
SP_TASK_6       equ     STACK_BASE + (STACK_SIZE * 7) ; タスク0のスタックポインタの初期値

PARAM_TASK_4    equ     0x0010_8000
PARAM_TASK_5    equ     0x0010_9000
PARAM_TASK_6    equ     0x0010_A000

CR3_BASE        equ     0x0010_5000 ; ページ変換テーブル(タスク3用)
CR3_TASK_4      equ     0x0020_0000 ; ページ変換テーブル(タスク4用)
CR3_TASK_5      equ     0x0020_2000 ; ページ変換テーブル(タスク5用)
CR3_TASK_6      equ     0x0020_4000 ; ページ変換テーブル(タスク6用)

FAT_SIZE        equ     (1024 * 128)
ROOT_SIZE       equ     (1024 * 16)

FAT1_START      equ     KERNEL_SIZE
FAT2_START      equ     FAT1_START + FAT_SIZE
ROOT_START      equ     FAT2_START + FAT_SIZE
FILE_START      equ     ROOT_START + ROOT_SIZE

ATTR_ARCHIVE    equ     0x20
ATTR_VOLUME_ID  equ     0x08