#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: flame2

# Tool invocations
flame2: util.o task2c.o start.o
	ld -m elf_i386 start.o task2c.o util.o -o flame2

# Depends on the source and header files
util.o: util.c
	gcc -m32 -Wall -ansi -c -g -nostdlib -fno-stack-protector util.c -o util.o
task2c.o: task2c.c
	gcc -m32 -Wall -ansi -c -g -nostdlib -fno-stack-protector task2c.c -o task2c.o
start.o:start.s
	nasm -f elf32 start.s -o start.o
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o flame2
