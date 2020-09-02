#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: encoder

# Tool invocations
encoder: util.o task1b.o start.o
	ld -m elf_i386 start.o task1b.o util.o -o encoder

# Depends on the source and header files
util.o: util.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
task1b.o: task1b.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector task1b.c -o task1b.o
start.o:start.s
	nasm -f elf32 start.s -o start.o
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o encoder
