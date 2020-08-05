kernel_filename := kernel.s
kernel_file_exists := $(shell ls | grep ${kernel_filename})

run:
ifeq (${kernel_file_exists}, ${kernel_filename})
	nasm boot.s -o boot.bin -l boot.lst
	nasm kernel.s -o kernel.bin -l kernel.lst
	cat boot.bin kernel.bin > boot.img
else
	nasm boot.s -o boot.bin -l boot.img
endif
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c