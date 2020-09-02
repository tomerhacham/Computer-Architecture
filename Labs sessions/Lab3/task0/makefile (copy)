#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: hexaPrint

# Tool invocations
hexaPrint: hexaPrint.o
	gcc -g -m32 -Wall -o hexaPrint hexaPrint.o

# Depends on the source and header files
hexaPrint.o: hexaPrint.c
	gcc -m32 -g -Wall -c -o hexaPrint.o hexaPrint.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o run
