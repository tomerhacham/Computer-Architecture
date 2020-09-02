all: myELF

myELF: task3.o
	ld -m elf_i386 task3.o -o myELF

task3.o: task3.s
	nasm -f elf32 task3.s -o task3.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o myELF