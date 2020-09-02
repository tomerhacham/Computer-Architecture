all: myELF

myELF: task1.o
	ld -m elf_i386 task1.o -o myELF

task1.o: task1.s
	nasm -f elf32 task1.s -o task1.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o myELF