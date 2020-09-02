#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: task2Assignment1

# Tool invocations
task2Assignment1: main2.o asm2.o
	gcc -m32 -Wall -g -o task2Assignment1 main2.o asm2.o

# Depends on the source and header files
main2.o: main_task2Assignment1.c
	gcc -m32 -c -Wall -g -o main2.o main_task2Assignment1.c

asm2.o: asm_task2Assignment1.s
	nasm -f elf32 asm_task2Assignment1.s -o asm2.o
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o task2Assignment1
