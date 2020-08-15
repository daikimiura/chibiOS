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
