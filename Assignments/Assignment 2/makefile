#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: calc

# Tool invocations


# Depends on the source and header files


calc: calc.s
	nasm -f elf calc.s -o calc.o
	gcc -m32 -Wall -g calc.o -o calc
	
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o calc
