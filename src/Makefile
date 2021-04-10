all:
	# build boot
	nasm -f elf32 -g3 -F dwarf boot.S -o boot.o
	ld -Ttext=0x7c00 -melf_i386 boot.o -o boot.elf
	objcopy -O binary boot.elf boot.bin
	# build kernel
	nasm -f elf32 -g3 -F dwarf kernel.S -o kernel.o
	ld -Ttext=0x00101000 -melf_i386 kernel.o -o kernel.elf
	objcopy -O binary kernel.elf kernel.bin
	# concat boot and kernel
	cat boot.bin kernel.bin > boot.img

clean:
	rm -f *.o *.elf *.bin *.img

dis:
	objdump -D -b binary -m i8086 boot.img

run:
	qemu-system-i386 boot.img

debug:
	qemu-system-i386 -s -S boot.img & \
	gdb kernel.elf \
		-ex 'target remote localhost:1234' \
		-ex 'set pagination off' \
		-ex 'layout src' \
		-ex 'layout regs' \
		-ex 'break kernel' \
		-ex 'continue'
