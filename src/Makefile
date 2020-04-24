all:
	nasm boot.S -o boot.img

clean:
	rm -f boot.img

dis:
	objdump -D -b binary -m i8086 boot.img

run:
	qemu-system-i386 boot.img
