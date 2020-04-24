all:
	nasm boot.S -o boot.img -l boot.lst

clean:
	rm -f boot.img boot.lst

dis:
	objdump -D -b binary -m i8086 boot.img

run:
	qemu-system-i386 boot.img

debug:
	qemu-system-i386 -s -S boot.img & \
	gdb -ix gdb_init_real_mode/gdbinit_real_mode.txt --eval-command="target remote localhost:1234"
