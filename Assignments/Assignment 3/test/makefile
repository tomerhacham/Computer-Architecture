#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: test

# Tool invocations
# Depends on the source and header files
test: test.s
	nasm -f elf test.s -o test.o
	gcc -m32 -Wall -g test.o -o test
	
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o test
