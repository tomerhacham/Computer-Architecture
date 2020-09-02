all: myELF

myELF: task2.o
	ld -m elf_i386 task2.o -o myELF

task2.o: task2.s
	nasm -f elf32 task2.s -o task2.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o myELF