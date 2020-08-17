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
